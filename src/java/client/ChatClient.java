/* ChatClient.java */
import java.io.*;
import java.net.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

public class ChatClient extends JFrame {

    /* Declarations Section */

    private static int port = 8550;
    private static String host = "localhost";
    private static String clientName;
    private static Socket server = null;
    private static PrintWriter outWriter = null;
    private static chatMsg sMessage = new chatMsg();

    private final static DataPipe dataPipe = new DataPipe();

    private static JButton register, sendTo, connect, newchat;
    private static JTextField inPut, subject;
    private static JTextArea display;

    public ChatClient(final DataPipe dataPipe, final PrintWriter out) throws Exception {

        /* Constructor, Variable Initialization */

        super("-Assign2- Java Chat Client");

        subject = new JTextField("Default Subject");
        display = new JTextArea();
        inPut = new JTextField("Chat Here");
        connect = new JButton("Connect");
        newchat = new JButton("New Chat");
        register = new JButton("Register");
        sendTo = new JButton("Send");

        connect.setEnabled(true);
        register.setEnabled(false);
        newchat.setEnabled(false);
        sendTo.setEnabled(false);
        display.setEditable(false);

        inPut.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                try { // If we are registered go ahead and send our message
                    if (clientName != null) {
                        sMessage.setType(sMessage.MSG);
                        sMessage.setMessage(inPut.getText());
                        sMessage.sendMsg(outWriter);
                        inPut.setText("");
                    }
                } catch (Exception a) {
                    a.printStackTrace();
                }
            }
        });

        connect.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                try {
                    doConnect(); // if we successfully connect allow registration.
                    if (server != null) {
                        register.setEnabled(true);
                        connect.setEnabled(false);
                    }
                } catch (Exception a) {
                    a.printStackTrace();
                }
            }
        });

        register.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                if (clientName == null) {
                    try {
                        clientName = sendReg(dataPipe);
                        if (clientName != null) {
                            register.setText("Unregister");
                            newchat.setEnabled(true);
                            sendTo.setEnabled(true);
                        }
                    } catch (Exception a) {
                        a.printStackTrace();
                    }
                } else {
                    sMessage.setType(sMessage.UNR);
                    sMessage.setMessage(clientName);
                    sMessage.sendMsg(outWriter);
                    register.setText("Register");
                    newchat.setEnabled(false);
                    clientName = null;
                    sendTo.setEnabled(false);
                }
            }
        });

        newchat.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String chtString = subject.getText();
                sMessage.setType(sMessage.NEWC);
                sMessage.setMessage(chtString);
                sMessage.sendMsg(outWriter);
                subject.setText(chtString);
                display.setText("");
            }
        });

        sendTo.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                try {
                    sMessage.setType(sMessage.MSG);
                    sMessage.setMessage(inPut.getText());
                    sMessage.sendMsg(outWriter);
                    inPut.setText("");
                } catch (Exception a) {
                    a.printStackTrace();
                }
            }
        });

        Panel panelButton = new Panel();
        Panel panelOutput = new Panel();
        Panel panelInput = new Panel();
        getContentPane().add(panelButton, BorderLayout.NORTH);
        getContentPane().add(panelOutput, BorderLayout.CENTER);
        getContentPane().add(panelInput, BorderLayout.SOUTH);

        panelButton.setLayout(new GridLayout(1, 4));
        panelButton.add(connect);
        panelButton.add(register);
        panelButton.add(newchat);
        panelButton.add(sendTo);
        
        panelOutput.setLayout(new GridLayout(0, 1));
        panelOutput.add(new JScrollPane(display));
        
        panelInput.setLayout(new GridLayout(0, 1));
        panelInput.add(subject);
        panelInput.add(inPut);

        setSize(500, 300);
        setVisible(true);

    }

    /*
     * String sendReg communicates with the server to establish a username and
     * confirm that it is unique.
     */

    private static String sendReg(DataPipe dataPipe) throws IOException {
        String regString = JOptionPane.showInputDialog("Register to " + host + "\n provide a user ID");
        sMessage.setType(sMessage.REG);
        sMessage.setMessage(regString);
        dataPipe.flush(); // lose any unwanted old data
        sMessage.sendMsg(outWriter);
        String sFlag = dataPipe.getResponse(); // query our data pipe for a
        System.out.println(sFlag); // response
        if (sFlag.equals("SRS: OK"))
            return regString;
        else
            return null;
    }

    /*
     * void doConnect Connect to server and return a socket.
     */
    private void doConnect() throws IOException {
        String conString = JOptionPane.showInputDialog("Please Provide Server IP:PORT", host + ":" + port);
        String[] hostPort = conString.split (":");
        host=hostPort[0];
        port=Integer.parseInt(hostPort[1]);
        try {
            server = new Socket(host, port);
        } catch (UnknownHostException e) {
            System.err.println(e);
            System.exit(1);
            e.printStackTrace();
        } catch (IOException e) {
            System.err.println(e);
            System.exit(1);
            e.printStackTrace();
        }

        // Output stream to server
        outWriter = new PrintWriter(server.getOutputStream(), true);

        // Create a thread to read messages from the server
        ClientInputThread sc = new ClientInputThread(server, display, subject, dataPipe);
        Thread t = new Thread(sc);
        t.start();
    }

    public static void main(String[] args) throws IOException {

        ChatClient newClient = null; // gui Init

        try {
            newClient = new ChatClient(dataPipe, outWriter);
        } catch (Exception e1) {
            e1.printStackTrace();
        }
        newClient.addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e) {
                if (clientName != null) { // if we are still registered then unregister
                    sMessage.setType(sMessage.UNR);
                    sMessage.setMessage(clientName);
                    sMessage.sendMsg(outWriter);
                }
                System.exit(0);
            }
        });
    }
}

