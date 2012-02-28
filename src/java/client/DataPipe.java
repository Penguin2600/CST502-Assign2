public class DataPipe {
    private String serverResponse = null;

    public DataPipe() {
    }
    
    public synchronized void flush() { 
        serverResponse = null;
    }

    public synchronized void putResponse(String s) { 
        serverResponse = s;
        //System.out.println(s+" at putResponse");//for debugging
        notifyAll();
    }

    public synchronized String getResponse() {
        try {
            while (serverResponse == null) {
               // System.out.println("waiting for SRS"); // for debugging
                wait(); 
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        String x=serverResponse;
        serverResponse=null;
        //System.out.println(x+ " at getResponse"); // for debuggung
        return x;

    }

}
