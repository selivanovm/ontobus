package gost19;

import gost19.amqp.messaging.AMQPMessagingManager;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.InputStreamReader;

/**
 *
 * @author itiu
 */
public class semargl_external_tester
{

    public String autotest_file = "io_messages.log";
    public long count_repeat = 1;
    public boolean nocompare = false;
    public String queue = "semargl-test";
    public AMQPMessagingManager mm;
    public long count = 0;
    public long start_time;
    public long stop_time;
    public long count_bytes;
    public int delta = 1000;

    semargl_external_tester() throws Exception
    {
        mm = new AMQPMessagingManager();

        String host = "172.17.1.81";
        Integer port = 5672;
        String virtualHost = "bigarchive";
        String userName = "ba";
        String password = "123456";
        long responceWaitingLimit = 100;

        mm.init(host, port, virtualHost, userName, password, responceWaitingLimit);
    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws Exception
    {

        semargl_external_tester autotest = new semargl_external_tester();

        if (args.length > 0)
        {
            for (int i = 0; i < args.length; i++)
            {
                if (args[i].equals("-autotest") || args[i].equals("-a"))
                {
                    System.out.println("autotest mode");
                    autotest.autotest_file = args[i + 1];
                    System.out.println("autotest file = " + autotest.autotest_file);
                }
                if (args[i].equals("-repeat") || args[i].equals("-r"))
                {
                    autotest.count_repeat = Long.parseLong(args[i + 1]);
                    System.out.println("repeat = " + autotest.count_repeat);
                }
                if (args[i].equals("-nocompare") || args[i].equals("-n"))
                {
                    autotest.nocompare = true;
                    System.out.println("no compare");
                }
            }
        }

        autotest.start_time = System.currentTimeMillis();
        autotest.count_bytes = 0;

        for (int i = 0; i < autotest.count_repeat; i++)
        {
            autotest.load_messages_from_file();
        }

        System.exit(0);
    }

    private void load_messages_from_file() throws Exception
    {
        try
        {
            // Open the file that is the first
            // command line parameter
            FileInputStream fstream = new FileInputStream(autotest_file);
            // Get the object of DataInputStream
            DataInputStream in = new DataInputStream(fstream);
            BufferedReader br = new BufferedReader(new InputStreamReader(in));
            String strLine;
            //Read File Line By Line
            boolean flag_input_message_start = false;
            StringBuffer message = null;

            while ((strLine = br.readLine()) != null)
            {
                if (strLine.indexOf(" OUTPUT") > 0 && flag_input_message_start == true)
                {
                    flag_input_message_start = false;

                    String str_message = message.toString();
//                    System.out.println("\r\r\r\r\r");
//                    System.out.println(message);

                    String templ = "mo/ts/msg#r_t>";
                    int str_pos_beg = str_message.indexOf(templ);
                    if (str_pos_beg <= 0)
                        throw new Exception ("reply_to not found");

                    str_pos_beg += templ.length();
                    str_pos_beg = str_message.indexOf("\"", str_pos_beg);
                    int str_pos_end = str_message.indexOf("\"", str_pos_beg+1);

                    String reply_to = str_message.substring(str_pos_beg + 1, str_pos_end);
                    System.out.println ("reply_to = " + reply_to);
                    if (reply_to.length() < 3)
                        throw new Exception ("reply_to is invalid");

                    str_message = str_message.replaceAll(templ + "\"" + reply_to, templ + "\"me");
                    reply_to = "me";

                    count++;
                    mm.sendMessage(queue, str_message);


                    String out_message = null;
                    
                    while (out_message == null)
                        out_message = mm.getMessage(reply_to, 0);



                    System.out.println ("out_message = " + out_message);

                    count_bytes += str_message.length();

                    if (count % delta == 0)
                    {
                        stop_time = System.currentTimeMillis();

                        double time_in_sec = ((double) (stop_time - start_time)) / 1000;

                        System.out.println("send " + count + " messages, time = " + time_in_sec + ", cps = " + delta / time_in_sec + ", count kBytes = " + count_bytes / 1024);

//                        Thread.currentThread().sleep(100);

                        start_time = System.currentTimeMillis();
                        count_bytes = 0;
                    }

//                    Thread.currentThread().sleep(1000);
                }

                if (flag_input_message_start == true)
                {
                    message = message.append(strLine);
                }

                if (strLine.indexOf(" INPUT") > 0 && flag_input_message_start == false)
                {
                    flag_input_message_start = true;
                    message = new StringBuffer();
                }

            }
            //Close the input stream
            in.close();
        } catch (Exception e)
        {//Catch exception if any
            System.err.println("Error: " + e.getMessage());
        }
    }
}
