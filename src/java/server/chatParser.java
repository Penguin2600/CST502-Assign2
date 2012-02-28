import java.util.Enumeration;
import java.util.Hashtable;

class chatParser {
    private String clientName;
    private ServerInputThread conn;
    private chatMsg sMessage = new chatMsg();

    // USER <-> Connection Map
    private static Hashtable<String, ServerInputThread> users = new Hashtable<String, ServerInputThread>();

    public chatParser(ServerInputThread c) {
        clientName = null;
        conn = c;
    }

    // Adds "registers" a user to the hash table returns false if the name is
    // already in the table.
    private static boolean register(String name, ServerInputThread c) {
        if (users.containsKey(name)) {
            return false;
        } else {
            users.put(name, c);
            return true;
        }
    }

    // removes "unregisters" a user from the hash table.
    private static boolean unregister(String unname) {
        if (users.containsKey(unname)) {
            users.remove(unname); // remove the user and connection from the
                                  // hash table.
            System.out.println("Unregistered " + unname);
            return true;
        } else { // user isn't in the hash table somehow.
            System.out.println("Request to unregister " + unname + " Failed");
            return false;
        }
    }

    private void log(String msg) {
        System.err.println(msg);
    }

    public boolean isRegistered() {
        return !(clientName == null);
    }

    // Check requested username against hash table, return accordingly.
    private String initUser(String msg) {
        if (msg.startsWith("REG")) {
            String tempName = msg.substring(4);
            if (register(tempName, this.conn)) {
                log("User: " + tempName + " has registered.");
                clientName = tempName;
                return sMessage.OK;
            } else {
                return sMessage.BID;
            }
        } else {
            return sMessage.NID;
        }
    }

    // Send message to all connections.
    private boolean sendAll(String msg, boolean withname) {
        Enumeration<String> e = users.keys();

        while (e.hasMoreElements()) {
            ServerInputThread c = users.get(e.nextElement());
            if (withname){
                c.sendMsg(clientName + ": " + msg);
            }else{
                c.sendMsg(msg);
            }
        }
        return true;
    }

    public String handle(String msg) {
        if (!isRegistered())
            return initUser(msg);

        if (msg.startsWith(sMessage.MSG)) {
            if (msg.substring(4) != null) {
                sendAll(msg.substring(4),true);
                return sMessage.OK;
            } else {
                return sMessage.INV;
            }
        
        } else if (msg.startsWith(sMessage.NEWC)) {
            if (msg.substring(4) != null) {
                sMessage.setSubject(msg.substring(4));
                sendAll(sMessage.NEWC+" "+sMessage.getSubject(),false); //send new chat message to all
                return sMessage.OK;
            } else {
                return sMessage.INV;
            }


        } else if (msg.startsWith(sMessage.UNR)) {
            String reqName = msg.substring(4);
            if (reqName.equals(clientName)) { // make sure we aren't unregistering
                                        // others
                if (unregister(msg.substring(4))) { // remove the hash table entry
                    clientName = null; // complete deregistration by blanking name
                }
            }
            return sMessage.OK;
        } else {
            return sMessage.INV;
        }
    }
}