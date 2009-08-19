// D import file generated from 'src/librabbitmq_client.d'
private
{
    import tango.io.Stdout;
}
private
{
    import tango.stdc.string;
}
import librabbitmq_headers;
import mom_client;
class librabbitmq_client : mom_client
{
    amqp_connection_state_t_ conn;
    char* vhost = "auth\x00";
    char* login = "search-client\x00";
    char* passw = "123\x00";
    char* queue = "auth";
    char* bindingkey = cast(char*)"\x00";
    char* exchange = "";
    char[] hostname;
    int port;
    void function(byte* txt, ulong size) message_acceptor;
    this(char[] _hostname, int _port)
{
hostname = _hostname;
port = _port;
}
    void set_callback(void function(byte* txt, ulong size) _message_acceptor)
{
message_acceptor = _message_acceptor;
}
    int send(char* routingkey, char* messagebody)
{
amqp_basic_properties_t props;
props._flags = amqp_def.AMQP_BASIC_CONTENT_TYPE_FLAG;
props.content_type = amqp_cstring_bytes("text/plain");
int result_publish = amqp_basic_publish(&conn,amqp_cstring_bytes(exchange),amqp_cstring_bytes(routingkey),0,0,&props,amqp_cstring_bytes(messagebody));
return 0;
}
    void listener();
}
