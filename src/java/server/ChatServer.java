/* ChatServer.java */
import java.net.ServerSocket;
import java.net.Socket;

import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;

import java.util.Enumeration;
import java.util.Hashtable;

public class ChatServer {
    private static int port = 8550; // port

    public static void main(String[] args) throws IOException {

        ServerSocket server = null;
        try {
            server = new ServerSocket(port); // start listening
            System.out.println("Server started on port " + port);
        } catch (IOException e) {
            System.err.println(e);
            System.exit(1);
        }

        Socket client = null;
        while (true) {
            try {
                client = server.accept();
            } catch (IOException e) {
                System.err.println(e);
                System.exit(1);
            }
            System.out.println("got connection from " + client.getRemoteSocketAddress().toString());
            // If a client connects pass the socket to a new thread for
            // concurrency.
            Thread t = new Thread(new ServerInputThread(client));
            t.start();
        }
    }
}
