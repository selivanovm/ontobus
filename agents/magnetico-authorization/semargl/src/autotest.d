import mom_client;
private import Log;

class autotest: mom_client
{
	void set_callback(void function(byte* txt, ulong size) _message_acceptor)
	{
	}

	int send(char* routingkey, char* messagebody)
	{
		return 0;
	}

	void listener()
	{
		log.trace ("autotest listen!");
	}
}