module socketserver;

private import tango.core.Thread;
private import tango.io.Console;

private
	import tango.net.ServerSocket, tango.net.SocketConduit;

import Integer = tango.text.convert.Integer;

private import tango.io.Stdout;
import Text = tango.text.Util;
import tango.time.StopWatch;

import HashMap;
import TripleStorage;
import ListStrings;

void main()
{
	const int port = 5672;

	SocketConduit _request;
	TripleStorage ts;
	
	void run_request_preparer()
	{
		SocketConduit request = _request;

		ListStrings input_chunks = new ListStrings();
		uint all_load_count = 0;
		size_t size_buff = 512;

		char[] read_chunk = new char[size_buff];

		int len = request.input.read(read_chunk);
		if(len > 0)
		{
			read_chunk.length = len;
			input_chunks.add(read_chunk);
			all_load_count += len;
		} else
		{
			while(len >= size_buff)
			{
				//				Cout(read_chunk[0 .. len]).newline;
				read_chunk = new char[size_buff];
				len = request.input.read(read_chunk);
				if(len > 0)
				{
					read_chunk.length = len;
					input_chunks.add(read_chunk);
					all_load_count += len;
				}
			}
		}
		//		read_chunk[len] = 0;

		Stdout.format("get {} chunks, total count:{}", input_chunks.size, all_load_count).newline;

		// write a response

		ListElementString next_element = input_chunks.first_element;

		while(next_element !is null)
		{
			request.output.write(next_element.content);
			//			request.output.write(next_element.content);
			Stdout.format(next_element.content);
			next_element = next_element.next_element;
		}
		Stdout.newline;
		request.close();

	}

	void run_listener()
	{
		ts = new TripleStorage ();
		auto server = new ServerSocket(new InternetAddress(port));

		while(true)
		{
			// wait for new request
			_request = server.accept;
			(new Thread(&run_request_preparer)).start;
		}
	}

	// start server in a separate thread, and wait for it to start
	Stdout.format("start server on port:{}", port).newline;
	(new Thread(&run_listener)).start;
	Thread.sleep(0.250);

}
