import tango.io.Stdout;
import tango.stdc.stdio;
import tango.stdc.stdlib;
import tango.stdc.string: strlenn = strlen;

import libdbus_client;
private import tango.core.Thread;

long count_recieve_messages = 0;
libdbus_client client;

int main(char[][] args)
{

	client = new libdbus_client();

	client.setReciever("test1");

	client.setSender("test", "test1");

	client.connect();

	client.set_callback(&event_get_message);

	char[] message = new char[20];

	message[0] = 'T';
	message[1] = 'E';
	message[2] = 'S';
	message[3] = 'T';
	message[4] = 0;

	//	 getString(cast(char *)frame.payload.body_fragment.bytes,

	(new Thread(&client.listener)).start;
	Thread.sleep(0.250);

	client.send("Test", message.ptr);

	return 0;
}

void event_get_message(byte* txt, ulong size, mom_client from_client)
{
	count_recieve_messages++;
	//	Stdout.format("message: \n{}", txt[0..size]).newline;

	if(count_recieve_messages % 1000 == 0)
	{
		printf("count_recieve_messages=%d\n", count_recieve_messages);
	}

	printf("event_get_message=%s\n", txt);

	char[] message = new char[20];

	message[0] = 'T';
	message[1] = 'O';
	message[2] = 'S';
	message[3] = 'T';
	message[4] = 0;

	client.send("Test", message.ptr);
}
