module server;

private import tango.core.Thread;
private import tango.io.Console;
private import std.c.string;

import Integer = tango.text.convert.Integer;

private import tango.io.Stdout;
import Text = tango.text.Util;
import tango.time.StopWatch;

import HashMap;
import TripleStorage;
//import ListStrings;

import librabbitmq_listen;

void main()
{	
	TripleStorage ts = new TripleStorage ();

	char[] hostname = "services.magnetosoft.ru\u0000";
	int port = 5672;
	
	librabbitmq client = new librabbitmq (hostname, port, &get_message);
	
	(new Thread(&client.listener)).start;
	Thread.sleep(0.250);
}
	
void get_message (byte* txt, ulong size)
{
// найдем факты содержащие одну из команд агента (store<put, get, subscription, subscription, freez, unfreez, get_agent_ontology)
// далее поочередно их выполним
// если результатов много, то следует разбить их на несколько сообщений

//	printf("DATA: %.*s\n", size, cast(void*)txt);
	
	Stdout.format("!!!! txt={}, size={}", str_2_char_array(cast(char *)txt, size), size).newline;	

}

private char[] str_2_char_array(char* str, ulong len)
{
	if (str is null)
		return "null";
		
	char[] res = new char[len];

	for(uint i = 0; i < len; i++)
	{
		res[i] = *(str + i);
	}

	return res;
}