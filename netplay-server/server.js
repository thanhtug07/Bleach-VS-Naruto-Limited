// BVN netplay relay server (headless TCP, no dependencies).
// - Game port 21337: JSON-lines protocol, 1 room = 2 players max.
// - Flash policy: served on the SAME port (no admin rights needed).
//   Flash asks 843 first, then falls back to the target port.
// Run: npm start   (or: node server.js [port])
'use strict';
const net = require('net');

const PORT = parseInt(process.argv[2] || '21337', 10);
const POLICY_XML =
  '<?xml version="1.0"?>' +
  '<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">' +
  '<cross-domain-policy>' +
  '<allow-access-from domain="*" to-ports="*" />' +
  '</cross-domain-policy>\0';

// rooms[roomCode] = { hostId, players: [{ socketId, username, role }], isStarted }
const rooms = {};
// clientBySocket: socket -> { username, roomCode, role, buffer }
const clients = new Map();

function makeRoomCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no confusing 0/O/1/I
  for (let attempt = 0; attempt < 50; attempt++) {
    let code = '';
    for (let i = 0; i < 6; i++) {
      code += chars[Math.floor(Math.random() * chars.length)];
    }
    if (!rooms[code]) {
      return code;
    }
  }
  return 'RM' + Date.now().toString(36).toUpperCase().slice(-4);
}

function send(sock, obj) {
  if (!sock.destroyed) {
    sock.write(JSON.stringify(obj) + '\n');
  }
}

function roomSnapshot(roomCode) {
  const room = rooms[roomCode];
  if (!room) {
    return null;
  }
  return {
    roomCode,
    isStarted: room.isStarted,
    players: room.players.map((p) => ({
      username: p.username,
      role: p.role,
      pick: p.pick || null,
    })),
  };
}

function broadcast(roomCode, obj, exceptSock) {
  const room = rooms[roomCode];
  if (!room) {
    return;
  }
  for (const p of room.players) {
    const cli = [...clients.entries()].find(([, c]) => c.socketId === p.socketId);
    if (cli && cli[0] !== exceptSock) {
      send(cli[0], obj);
    }
  }
}

function destroyRoom(roomCode, reason) {
  const room = rooms[roomCode];
  if (!room) {
    return;
  }
  delete rooms[roomCode];
  console.log(`[room ${roomCode}] destroyed (${reason || 'done'})`);
}

function leaveRoom(sock) {
  const cli = clients.get(sock);
  if (!cli || !cli.roomCode) {
    return;
  }
  const roomCode = cli.roomCode;
  const room = rooms[roomCode];
  cli.roomCode = null;
  cli.role = null;
  if (!room) {
    return;
  }
  room.players = room.players.filter((p) => p.socketId !== cli.socketId);
  if (room.players.length === 0) {
    destroyRoom(roomCode, 'empty');
    return;
  }
  // Notify the remaining peer and tear the room down (spec: 1v1 session ends).
  broadcast(roomCode, { t: 'peer_left', username: cli.username || '???' });
  destroyRoom(roomCode, 'peer left');
}

function handleMessage(sock, msg) {
  const cli = clients.get(sock);
  if (!cli) {
    return;
  }
  if (!msg || typeof msg.t !== 'string') {
    send(sock, { t: 'error', message: 'Bad message.' });
    return;
  }
  switch (msg.t) {
    case 'hello': {
      const name = String(msg.username || '').trim().slice(0, 16);
      if (!name) {
        send(sock, { t: 'error', message: 'Username required.' });
        return;
      }
      cli.username = name;
      send(sock, { t: 'welcome', username: name });
      break;
    }
    case 'create': {
      if (!cli.username) {
        send(sock, { t: 'error', message: 'Say hello first.' });
        return;
      }
      if (cli.roomCode) {
        leaveRoom(sock);
      }
      const code = makeRoomCode();
      rooms[code] = {
        hostId: cli.socketId,
        players: [{ socketId: cli.socketId, username: cli.username, role: 'host' }],
        isStarted: false,
      };
      cli.roomCode = code;
      cli.role = 'host';
      send(sock, { t: 'room_created', roomCode: code });
      send(sock, { t: 'room_updated', room: roomSnapshot(code) });
      console.log(`[room ${code}] created by ${cli.username}`);
      break;
    }
    case 'join': {
      if (!cli.username) {
        send(sock, { t: 'error', message: 'Say hello first.' });
        return;
      }
      const code = String(msg.roomCode || '').trim().toUpperCase();
      const room = rooms[code];
      if (!room) {
        send(sock, { t: 'error', message: 'Room not found. Check the code.' });
        return;
      }
      if (room.isStarted) {
        send(sock, { t: 'error', message: 'Match already started.' });
        return;
      }
      if (room.players.length >= 2) {
        send(sock, { t: 'error', message: 'Room is full.' });
        return;
      }
      if (cli.roomCode) {
        leaveRoom(sock);
      }
      room.players.push({ socketId: cli.socketId, username: cli.username, role: 'guest' });
      cli.roomCode = code;
      cli.role = 'guest';
      broadcast(code, { t: 'room_updated', room: roomSnapshot(code) });
      console.log(`[room ${code}] ${cli.username} joined`);
      break;
    }
    case 'quickjoin': {
      // Matchmaking: join any waiting room with exactly 1 player.
      if (!cli.username) {
        send(sock, { t: 'error', message: 'Say hello first.' });
        return;
      }
      const open = Object.keys(rooms).find(
        (code) => !rooms[code].isStarted && rooms[code].players.length === 1
      );
      if (!open) {
        send(sock, { t: 'error', message: 'Chưa có phòng trống. Hãy tạo phòng mới.' });
        return;
      }
      if (cli.roomCode) {
        leaveRoom(sock);
      }
      const rq = rooms[open];
      rq.players.push({ socketId: cli.socketId, username: cli.username, role: 'guest' });
      cli.roomCode = open;
      cli.role = 'guest';
      broadcast(open, { t: 'room_updated', room: roomSnapshot(open) });
      console.log(`[room ${open}] ${cli.username} quick-joined`);
      break;
    }
    case 'start': {
      const room = cli.roomCode ? rooms[cli.roomCode] : null;
      if (!room || cli.role !== 'host') {
        send(sock, { t: 'error', message: 'Only the host can start.' });
        return;
      }
      if (room.players.length < 2) {
        send(sock, { t: 'error', message: 'Need 2 players to start.' });
        return;
      }
      room.isStarted = true;
      const seed = Math.floor(Math.random() * 0x7fffffff);
      for (const p of room.players) {
        const entry = [...clients.entries()].find(([, c]) => c.socketId === p.socketId);
        if (entry) {
          send(entry[0], {
            t: 'game_started',
            roomCode: cli.roomCode,
            seed,
            youAre: p.role,
            peer: room.players.find((q) => q.socketId !== p.socketId).username,
          });
        }
      }
      console.log(`[room ${cli.roomCode}] started (seed ${seed})`);
      break;
    }
    case 'pick': {
      // Lobby loadout sync: fighter/assist/map picks, rebroadcast in room_updated.
      const room = cli.roomCode ? rooms[cli.roomCode] : null;
      if (!room || room.isStarted) {
        return;
      }
      const me = room.players.find((p) => p.socketId === cli.socketId);
      if (!me) {
        return;
      }
      const clean = (v) => String(v || '').trim().slice(0, 32);
      me.pick = { fighter: clean(msg.fighter), assist: clean(msg.assist), map: clean(msg.map) };
      broadcast(cli.roomCode, { t: 'room_updated', room: roomSnapshot(cli.roomCode) });
      break;
    }
    case 'input': {
      // Low-latency relay: forward raw input to the opponent, nothing else.
      const room = cli.roomCode ? rooms[cli.roomCode] : null;
      if (!room || !room.isStarted) {
        return;
      }
      if (msg.type !== 'keydown' && msg.type !== 'keyup') {
        return;
      }
      const key = String(msg.key || '').slice(0, 8);
      const frame = Number(msg.frame) | 0;
      broadcast(cli.roomCode, { t: 'opponent_input', type: msg.type, key, frame }, sock);
      break;
    }
    case 'leave': {
      leaveRoom(sock);
      send(sock, { t: 'left' });
      break;
    }
    default: {
      send(sock, { t: 'error', message: 'Unknown message.' });
    }
  }
}

let nextId = 1;
const server = net.createServer((sock) => {
  sock.setNoDelay(true);
  const cli = { socketId: nextId++, username: null, roomCode: null, role: null, buffer: '' };
  clients.set(sock, cli);
  let checkedPolicy = false;
  sock.on('data', (chunk) => {
    // Flash policy handshake arrives first as plain XML (no JSON).
    if (!checkedPolicy) {
      checkedPolicy = true;
      const head = cli.buffer + chunk.toString('utf8');
      if (head.indexOf('<policy-file-request/>') !== -1) {
        sock.write(POLICY_XML);
        sock.end();
        return;
      }
    }
    cli.buffer += chunk.toString('utf8');
    let idx;
    while ((idx = cli.buffer.indexOf('\n')) !== -1) {
      const line = cli.buffer.slice(0, idx).trim();
      cli.buffer = cli.buffer.slice(idx + 1);
      if (!line) {
        continue;
      }
      let msg;
      try {
        msg = JSON.parse(line);
      } catch (e) {
        send(sock, { t: 'error', message: 'Bad JSON.' });
        continue;
      }
      handleMessage(sock, msg);
    }
  });
  const cleanup = () => {
    if (clients.has(sock)) {
      leaveRoom(sock);
      clients.delete(sock);
    }
  };
  sock.on('close', cleanup);
  sock.on('error', () => {});
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`BVN netplay server listening on 0.0.0.0:${PORT} (policy served on same port)`);
});
