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
    import tango.stdc.stdio;
}
import tango.net.Socket;
import mom_client;
import amqp_base;
import amqp;
import amqp_framing;
import amqp_private;
import amqp_connection;
import amqp_socket;
import amqp_api;
import amqp_mem;
private
{
    import tango.core.Thread;
}
class librabbitmq_client : mom_client
{
    amqp_connection_state_t* conn;
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
props._flags = AMQP_BASIC_CONTENT_TYPE_FLAG | AMQP_BASIC_DELIVERY_MODE_FLAG;
props.content_type = amqp_cstring_bytes("text/plain");
props.delivery_mode = 2;
int result_publish = amqp_basic_publish(conn,1,amqp_cstring_bytes(exchange),amqp_cstring_bytes(routingkey),0,0,&props,amqp_cstring_bytes(messagebody));
return result_publish;
}
    void listener();
}
