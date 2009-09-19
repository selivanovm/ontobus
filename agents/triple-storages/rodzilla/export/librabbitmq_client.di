// D import file generated from 'src/librabbitmq_client.d'
private
{
    import tango.io.Stdout;
}
private
{
    import std.c.string;
}
import librabbitmq_headers;
class librabbitmq_client
{
    amqp_connection_state_t_ conn;
    char* vhost = "store\x00";
    char* exchange = "";
    char* login = "ba\x00";
    char* passw = "123456\x00";
    char* bindingkey = cast(char*)"\x00";
    char* queue = "store";
    char[] hostname;
    int port;
    void function(byte* txt, ulong size) message_acceptor;
    this(char[] _hostname, int _port, void function(byte* txt, ulong size) _message_acceptor)
{
hostname = _hostname;
port = _port;
message_acceptor = _message_acceptor;
}
    void send(char* routingkey, char* messagebody)
{
amqp_basic_properties_t props;
props._flags = amqp_def.AMQP_BASIC_CONTENT_TYPE_FLAG;
props.content_type = amqp_cstring_bytes("text/plain");
int result_publish = amqp_basic_publish(&conn,amqp_cstring_bytes(exchange),amqp_cstring_bytes(routingkey),0,0,&props,amqp_cstring_bytes(messagebody));
}
    void listener();
}
