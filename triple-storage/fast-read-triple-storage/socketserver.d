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
import ListTriple;
import ListStrings;

void main()
{
	const int port = 8086;

	SocketConduit _request;

	void run_request_preparer()
	{
		SocketConduit request = _request;

		ListStrings input_chunks = new ListStrings();
		uint all_load_count = 0;
		size_t size_buff = 64;

		char[] read_chunk = new char[size_buff];

		int len = request.input.read(read_chunk);
		input_chunks.add(read_chunk);
		all_load_count += len;
		while(len >= size_buff)
		{
			//				Cout(read_chunk[0 .. len]).newline;
			read_chunk = new char[size_buff];
			len = request.input.read(read_chunk);
			input_chunks.add(read_chunk);
			all_load_count += len;
		}

		Stdout.format("get {} chunks, total count:{}", input_chunks.size,
				all_load_count).newline;

		// write a response
		request.output.write("<html><font color=red>Андрюха на!</font></html>");
		request.output.write(input_chunks.first_element.content);
		request.output.write(input_chunks.first_element.next_element.content);
		request.close();

	}

	void run_listener()
	{
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
