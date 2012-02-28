import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;


class ServerInputThread implements Runnable {
    private Socket client;
    private BufferedReader in = null;
    private PrintWriter out = null;

    ServerInputThread(Socket client) {
        this.client = client;
        try {
            in = new BufferedReader(new InputStreamReader(client.getInputStream()));
            out = new PrintWriter(client.getOutputStream(), true);
        } catch (IOException e) {
            System.err.println(e);
            return;
        }
    }

    public void run() {
        String msg, response;
        chatParser Cserver = new chatParser(this);
        try {
            while ((msg = in.readLine()) != null) {
                System.out.println(msg);
                response = Cserver.handle(msg);
                out.println("SRS: " + response); // send acknowledgment.
            }
        } catch (IOException e) {
            System.err.println(e); 
        }
    }

    public void sendMsg(String msg) {
        out.println(msg);
    }
}
