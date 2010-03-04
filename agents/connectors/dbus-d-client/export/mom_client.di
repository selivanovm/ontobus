// D import file generated from 'src/mom_client.d'
interface mom_client
{
    void set_callback(void function(byte* txt, ulong size, mom_client from_client) _message_acceptor);
    void listener();
    int send(char* routingkey, char* messagebody);
    char* get_message();
}
