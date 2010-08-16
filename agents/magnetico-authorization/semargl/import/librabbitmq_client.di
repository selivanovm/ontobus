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
    import tango.net.device.Socket;
}
private 
{
    import tango.stdc.stringz;
}
private 
{
    import tango.stdc.stdio;
}
private 
{
    import mom_client;
}
private 
{
    import amqp_base;
}
private 
{
    import amqp;
}
private 
{
    import amqp_framing;
}
private 
{
    import amqp_private;
}
private 
{
    import amqp_connection;
}
private 
{
    import amqp_socket;
}
private 
{
    import amqp_api;
}
private 
{
    import amqp_mem;
}
private 
{
    import Log;
}
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
    Socket socket;
    char[] hostname;
    int port;
    void function(byte* txt, ulong size, mom_client from_client) message_acceptor;
    this(char[] _hostname, int _port, char[] _login, char[] _passw, char[] _queue, char[] _vhost)
{
hostname = _hostname;
port = _port;
login = _login;
passw = _passw;
bindingkey = cast(char*)_queue;
vhost = _vhost;
}
    void set_callback(void function(byte* txt, ulong size, mom_client from_client) _message_acceptor)
{
message_acceptor = _message_acceptor;
}
    int send(char* routingkey, char* messagebody);
    char* get_message()
{
return null;
}
    void listener();
}
