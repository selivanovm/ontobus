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
    char* service_name = null;
}
    private
{
    char* dest_object_name_of_the_signal = null;
}
    private
{
    char* service_interface_name = null;
}
    private
{
    char* service_name_of_the_signal = "message";
}
    void function(byte* txt, ulong size, mom_client from_client) message_acceptor;
    this()
{
}
    void setServiceName(char[] im)
{
service_name = (im ~ ".signal.source\x00").ptr;
service_interface_name = (im ~ ".signal.Type\x00").ptr;
}
    void setListenFrom(char[] listen_from)
{
reciever_name = (listen_from ~ ".signal.sink\x00").ptr;
see_rule_for_listener = ("type='signal',interface='" ~ listen_from ~ ".signal.Type'\x00").ptr;
interface_name = (listen_from ~ ".signal.Type\x00").ptr;
}
    void connect();
    void set_callback(void function(byte* txt, ulong size, mom_client from_client) _message_acceptor)
{
message_acceptor = _message_acceptor;
}
    char[] add_to_dest_object_name_of_the_signal = "/signal/Object\x00";
    int send(char* routingkey, char* sigvalue);
    void listener();
}
