// D import file generated from 'src/librabbitmq_client.d'
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
    import tango.stdc.stringz;
}
private
{
    import tango.stdc.posix.stdio;
}
import librabbitmq_headers;
import mom_client;
private
{
    import tango.core.Thread;
}
class librabbitmq_client : mom_client
{
    amqp_connection_state_t_ conn;
    char[] vhost;
    char[] login;
    char[] passw;
    char* bindingkey = null;
    char* exchange = cast(char*)"\x00";
    int waiting_for_login = 5;
    char[] hostname;
    int port;
    void function(byte* txt, ulong size) message_acceptor;
    this(char[] _hostname, int _port, char[] _login, char[] _passw, char[] _queue, char[] _vhost)
{
hostname = _hostname;
port = _port;
login = _login;
passw = _passw;
bindingkey = cast(char*)_queue;
vhost = _vhost;
}
    void set_callback(void function(byte* txt, ulong size) _message_acceptor)
{
message_acceptor = _message_acceptor;
}
    int send(char* routingkey, char* messagebody)
{
amqp_basic_properties_t props;
props._flags = amqp_def.AMQP_BASIC_CONTENT_TYPE_FLAG | amqp_def.AMQP_BASIC_DELIVERY_MODE_FLAG;
props.content_type = amqp_cstring_bytes("text/plain");
props.delivery_mode = 2;
int result_publish = amqp_basic_publish(&conn,1,amqp_cstring_bytes(exchange),amqp_cstring_bytes(routingkey),0,0,&props,amqp_cstring_bytes(messagebody));
return result_publish;
}
    void listener();
}
