using System;
using System.Diagnostics;
using System.IO;
using System.Net.Sockets;
using System.Threading;

sealed class Launcher {
    static string Dir() {
        return AppDomain.CurrentDomain.BaseDirectory;
    }

    static void Log(string s) {
        try {
            File.AppendAllText(
                Path.Combine(Dir(), "netplay-server", "launcher.log"),
                DateTime.Now.ToString("HH:mm:ss") + " " + s + "\r\n");
        } catch { }
    }

    static bool PortOpen() {
        try {
            using (var c = new TcpClient()) {
                var r = c.BeginConnect("127.0.0.1", 21337, null, null);
                if (!r.AsyncWaitHandle.WaitOne(800)) {
                    return false;
                }
                c.EndConnect(r);
                return true;
            }
        } catch { return false; }
    }

    static bool OwnServerRunning() {
        try {
            foreach (var p in Process.GetProcessesByName("node")) {
                try {
                    if (p.MainModule != null &&
                        p.MainModule.FileName.ToLower().IndexOf("bleach vs naruto") >= 0) {
                        return true;
                    }
                } catch { }
            }
        } catch { }
        return PortOpen();
    }

    static void StartServer() {
        try {
            string dir = Dir();
            string node = Path.Combine(dir, "node", "node.exe");
            string srv = Path.Combine(dir, "netplay-server", "server.js");
            if (!File.Exists(node) || !File.Exists(srv)) {
                Log("offline: thieu node/server.js, choi offline");
                return;
            }
            if (OwnServerRunning()) {
                Log("server da chay, dung chung");
                return;
            }
            var psi = new ProcessStartInfo(node, "\"" + srv + "\" 21337");
            psi.WorkingDirectory = dir;
            psi.CreateNoWindow = true;
            psi.UseShellExecute = false;
            psi.WindowStyle = ProcessWindowStyle.Hidden;
            Process p = Process.Start(psi);
            try {
                File.WriteAllText(Path.Combine(dir, "netplay-server", "server.pid"),
                    p.Id.ToString());
            } catch { }
            for (int i = 0; i < 12; i++) {
                Thread.Sleep(500);
                if (PortOpen()) {
                    Log("server OK pid=" + p.Id);
                    return;
                }
                try {
                    if (p.HasExited) {
                        Log("server thoat som, choi offline");
                        return;
                    }
                } catch { }
            }
            Log("server khong len kip, choi offline");
        } catch (Exception ex) {
            Log("loi server: " + ex.Message + " -> choi offline");
        }
    }

    static void Main() {
        string dir = Dir();
        StartServer();
        string player = Path.Combine(dir, "FlashPlayer.exe");
        string swf = Path.Combine(dir, "FighterTester.swf");
        if (!File.Exists(player) || !File.Exists(swf)) {
            return;
        }
        try {
            Process.Start(new ProcessStartInfo(player, "\"" + swf + "\"") { WorkingDirectory = dir });
        } catch { }
    }
}
