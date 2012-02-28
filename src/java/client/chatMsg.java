import java.io.PrintWriter;

public class chatMsg {

    private String type = "OK";
    private String subject = null;
    private String message = null;

    public final String OK  = "OK";
    public final String MSG = "MSG";
    public final String REG = "REG";
    public final String UNR = "UNR";
    public final String NEWC = "NEWC";
    public final String NID = "NEEDID";
    public final String BID = "BADID";
    public final String INV = "INVALID";

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }

    public void sendMsg(PrintWriter outWriter) {
        outWriter.println(this.type + " " + this.message);
        outWriter.flush();
    }

}
