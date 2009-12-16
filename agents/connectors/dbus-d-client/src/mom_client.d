interface mom_client
{
	void set_callback(void function(byte* txt, ulong size) _message_acceptor);

	int send(char* routingkey, char* messagebody);

	void listener();
	
//	void set_listen_queue (char* listen_queue);
	
//	char* listen (char* listen_queue);
}