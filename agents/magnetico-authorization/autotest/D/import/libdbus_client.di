// D import file generated from 'src/libdbus_client.d'
private
{
    import tango.io.Stdout;
}
private
{
    import tango.stdc.string;
}
private
{
    import tango.stdc.stdio;
}
private
{
    import tango.core.Thread;
}
import libdbus_headers;
import mom_client;
class libdbus_client : mom_client
{
    private
{
    DBusConnection* conn = null;
}
    private
{
    DBusError err;
}
    private
{
    char* reciever_name = null;
}
    private
{
    char* see_rule_for_listener = null;
}
    private
{
    char* interface_name = null;
}
    private
{
    char* name_of_the_signal = "message";
}
    private
{
    char* sender_name = null;
}
    private
{
    char* dest_object_name_of_the_signal = null;
}
    private
{
    char* sender_interface_name = null;
}
    private
{
    char* sender_name_of_the_signal = "message";
}
    void function(byte* txt, ulong size) message_acceptor;
    this()
{
}
    void setReciever(char[] reciever)
{
reciever_name = (reciever ~ ".signal.sink\x00").ptr;
see_rule_for_listener = ("type='signal',interface='" ~ reciever ~ ".signal.Type'\x00").ptr;
interface_name = (reciever ~ ".signal.Type\x00").ptr;
}
    void setSender(char[] sender, char[] to)
{
sender_name = (sender ~ ".signal.source\x00").ptr;
dest_object_name_of_the_signal = ("/" ~ to ~ "/signal/Object\x00").ptr;
sender_interface_name = (sender ~ ".signal.Type\x00").ptr;
}
    void connect();
    void set_callback(void function(byte* txt, ulong size) _message_acceptor)
{
message_acceptor = _message_acceptor;
}
    int send(char* routingkey, char* sigvalue);
    void listener();
}
