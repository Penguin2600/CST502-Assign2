import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Socket;

import javax.swing.JTextArea;
import javax.swing.JTextField;

class ClientInputThread implements Runnable {
    private BufferedReader inReader = null;
    private static JTextArea display = null;
    private static JTextField subject = null;
    private DataPipe dataPipe;

    public ClientInputThread(Socket server, JTextArea d, JTextField s, DataPipe p) throws IOException {
        dataPipe = p;
        display = d;
        subject = s;
        inReader = new BufferedReader(new InputStreamReader(server.getInputStream()));

    }

    public void run() {
        String msg;
        try {
            while ((msg = inReader.readLine()) != null) {

                if (msg.startsWith("SRS")) {
                    dataPipe.putResponse(msg); //server response gord to data store

                } else if (msg.startsWith("NEWC")) {
                    display.setText(""); // new chat begins, set fields
                    subject.setText(msg.substring(6)); // new chat begins, set fields.
                    
                } else {
                    display.append(msg + "\n");
                }
            }
        } catch (IOException e) {
            System.err.println(e);
        }
    }
}
