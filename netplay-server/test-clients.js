// Fake-client integration test: host + guest full flow against server.js.
// Run: node test-clients.js  (server must be running: npm start)
'use strict';
const net = require('net');

const PORT = parseInt(process.argv[2] || '21337', 10);
let failures = 0;
function check(name, cond) {
  console.log(`${cond ? 'PASS' : 'FAIL'}  ${name}`);
  if (!cond) {
    failures++;
  }
}

function makeClient(username) {
  return new Promise((resolve, reject) => {
    const sock = net.createConnection(PORT, '127.0.0.1', () => {
      const c = { sock, username, buffer: '', inbox: [], waiters: [] };
      sock.setEncoding('utf8');
      sock.on('data', (chunk) => {
        c.buffer += chunk;
        let idx;
        while ((idx = c.buffer.indexOf('\n')) !== -1) {
          const line = c.buffer.slice(0, idx).trim();
          c.buffer = c.buffer.slice(idx + 1);
          if (!line) {
            continue;
          }
          const msg = JSON.parse(line);
          const w = c.waiters.find((x) => x.t === msg.t);
          if (w) {
            c.waiters = c.waiters.filter((x) => x !== w);
            w.resolve(msg);
          } else {
            c.inbox.push(msg);
          }
        }
      });
      sock.on('error', reject);
      resolve(c);
    });
  });
}

function send(c, obj) {
  c.sock.write(JSON.stringify(obj) + '\n');
}

function next(c, t, timeoutMs = 3000) {
  const early = c.inbox.findIndex((m) => m.t === t);
  if (early !== -1) {
    return Promise.resolve(c.inbox.splice(early, 1)[0]);
  }
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error(`timeout waiting ${t}`)), timeoutMs);
    c.waiters.push({
      t,
      resolve: (m) => {
        clearTimeout(timer);
        resolve(m);
      },
    });
  });
}

(async () => {
  const host = await makeClient('HOST_A');
  const guest = await makeClient('GUEST_B');

  send(host, { t: 'hello', username: 'HOST_A' });
  check('host hello/welcome', ((await next(host, 'welcome')).username === 'HOST_A'));
  send(guest, { t: 'hello', username: 'GUEST_B' });
  await next(guest, 'welcome');

  // Join missing room -> error.
  send(guest, { t: 'join', roomCode: 'NOPE12' });
  check('join missing room errors', ((await next(guest, 'error')).message || '').length > 0);

  // Create.
  send(host, { t: 'create' });
  const created = await next(host, 'room_created');
  check('room code format', /^[A-Z0-9]{6}$/.test(created.roomCode));
  const code = created.roomCode;

  // Guest starts alone -> error (not host).
  send(guest, { t: 'start' });
  check('guest cannot start', ((await next(guest, 'error')).message || '').length > 0);

  // Host starts alone -> error (need 2).
  send(host, { t: 'start' });
  check('host cannot start solo', ((await next(host, 'error')).message || '').length > 0);

  // Join + lobby sync both sides (host may have a stale 1-player update first).
  async function nextFull(c) {
    for (;;) {
      const m = await next(c, 'room_updated');
      if (m.room.players.length === 2) {
        return m;
      }
    }
  }
  send(guest, { t: 'join', roomCode: code.toLowerCase() });
  const ruGuest = await nextFull(guest);
  const ruHost = await nextFull(host);
  check('lobby has 2 players (guest view)', ruGuest.room.players.length === 2);
  check(
    'roles host/guest',
    ruHost.room.players.some((p) => p.role === 'host' && p.username === 'HOST_A') &&
      ruHost.room.players.some((p) => p.role === 'guest' && p.username === 'GUEST_B')
  );

  // Quickjoin scenario on a fresh 1-player room.
  const host2 = await makeClient('HOST2');
  send(host2, { t: 'hello', username: 'HOST2' });
  await next(host2, 'welcome');
  // Drain host's stale updates first.
  send(host2, { t: 'create' });
  const created2 = await next(host2, 'room_created');
  await next(host2, 'room_updated'); // drain 1-player snapshot
  const quick = await makeClient('Q');
  send(quick, { t: 'hello', username: 'Q' });
  await next(quick, 'welcome');
  send(quick, { t: 'quickjoin' });
  const qj = await nextFull(quick);
  check('quickjoin lands in waiting room', qj.room.roomCode === created2.roomCode && qj.room.players.length === 2);
  check('quickjoin role guest', qj.room.players.some((p) => p.username === 'Q' && p.role === 'guest'));
  send(quick, { t: 'leave' });
  await next(quick, 'left');
  send(host2, { t: 'leave' });
  quick.sock.end();
  host2.sock.end();

  // Third client rejected (full).
  const third = await makeClient('C');
  send(third, { t: 'hello', username: 'C' });
  await next(third, 'welcome');
  send(third, { t: 'join', roomCode: code });
  check('full room rejected', ((await next(third, 'error')).message || '').length > 0);
  third.sock.end();

  // Picks sync to both sides via room_updated.
  send(host, { t: 'pick', fighter: 'ichigo', assist: 'kon', map: 'GenSe' });
  send(guest, { t: 'pick', fighter: 'naruto', assist: 'gaara', map: '' });
  let ruPick;
  for (;;) {
    ruPick = await nextFull(host);
    const ps = ruPick.room.players;
    if (ps.every((p) => p.pick && p.pick.fighter)) {
      break;
    }
  }
  const hpick = ruPick.room.players.find((p) => p.role === 'host').pick;
  const gpick = ruPick.room.players.find((p) => p.role === 'guest').pick;
  check('host pick synced', hpick && hpick.fighter === 'ichigo' && hpick.map === 'GenSe');
  check('guest pick synced', gpick && gpick.fighter === 'naruto');

  // Start -> both get game_started with same seed, correct roles.
  send(host, { t: 'start' });
  const gsH = await next(host, 'game_started');
  const gsG = await next(guest, 'game_started');
  check('same seed both sides', gsH.seed === gsG.seed);
  check('roles in game_started', gsH.youAre === 'host' && gsG.youAre === 'guest');
  check('peer names exchanged', gsH.peer === 'GUEST_B' && gsG.peer === 'HOST_A');

  // Input relay both directions.
  send(host, { t: 'input', type: 'keydown', key: 'J', frame: 1042 });
  const oi = await next(guest, 'opponent_input');
  check('host->guest relay', oi.type === 'keydown' && oi.key === 'J' && oi.frame === 1042);
  send(guest, { t: 'input', type: 'keyup', key: 'K', frame: 1050 });
  const oi2 = await next(host, 'opponent_input');
  check('guest->host relay', oi2.type === 'keyup' && oi2.key === 'K' && oi2.frame === 1050);

  // Disconnect -> peer_left for the survivor.
  guest.sock.destroy();
  const pl = await next(host, 'peer_left');
  check('peer_left on disconnect', pl.username === 'GUEST_B');

  host.sock.end();
  setTimeout(() => {
    console.log(failures === 0 ? 'ALL TESTS PASSED' : `${failures} FAILURES`);
    process.exit(failures === 0 ? 0 : 1);
  }, 300);
})().catch((e) => {
  console.error('TEST ERROR:', e.message);
  process.exit(1);
});
