module server;

private import tango.core.Thread;
private import tango.io.Console;

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
	
	librabbitmq client = new librabbitmq (hostname, port);
	
	(new Thread(&client.listener)).start;
	Thread.sleep(0.250);
}
