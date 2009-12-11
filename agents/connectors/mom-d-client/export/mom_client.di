// D import file generated from 'src/mom_client.d'
interface mom_client
{
    void set_callback(void function(byte* txt, ulong size) _message_acceptor);
    int send(char* routingkey, char* messagebody);
    void listener();
}
