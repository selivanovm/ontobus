module server;

private import tango.core.Thread;
private import tango.io.Console;
private import tango.stdc.string;
private import tango.stdc.stdlib;
private import tango.stdc.posix.stdio;
private import tango.stdc.stringz;
private import Log;

private import tango.io.FileScan;
private import tango.io.FileConduit;
private import tango.io.stream.MapStream;

private import Integer = tango.text.convert.Integer;

private import tango.io.Stdout;
private import Text = tango.text.Util;
private import tango.time.StopWatch;
private import tango.time.WallClock;
private import tango.time.Clock;

private import tango.text.locale.Locale;

private import autotest;

private char* result_buffer = null;
private char* queue_name = null;
private char* user = null;

private bool logging_io_messages = true;
private Locale layout;

void main(char[][] args)
{
	char[] autotest_file = null;
	long count_repeat = 1;
	bool nocompare = false;

	if(args.length > 0)
	{
		for(int i = 0; i < args.length; i++)
		{
			if(args[i] == "-autotest" || args[i] == "-a")
			{
				log.trace("autotest mode");
				autotest_file = args[i + 1];
				log.trace("autotest file = {}", autotest_file);
			}
			if(args[i] == "-repeat" || args[i] == "-r")
			{
				count_repeat = atoll(toStringz(args[i + 1]));
				log.trace("repeat = {}", count_repeat);
			}
			if(args[i] == "-nocompare" || args[i] == "-n")
			{
				nocompare = true;
				log.trace("no compare");
			}
		}
	}

	result_buffer = cast(char*) new char[200 * 1024];
	queue_name = cast(char*) (new char[40]);
	user = cast(char*) (new char[40]);

	char[][char[]] props = load_props();
	char[] hostname = props["amqp_server_address"] ~ "\0";
	int port = atoi((props["amqp_server_port"] ~ "\0").ptr);
	char[] vhost = props["amqp_server_vhost"] ~ "\0";
	char[] login = props["amqp_server_login"] ~ "\0";
	char[] passw = props["amqp_server_password"] ~ "\0";
	char[] queue = props["amqp_server_queue"] ~ "\0";

	autotest at = new autotest (autotest_file, count_repeat, nocompare, hostname, port, vhost, "", login, passw); 
	at.prepare_file ();
	

}

//void send_result_and_logging_messages(char* queue_name, char* result_buffer)
//{
//	auto elapsed = new StopWatch();
//	double time;
//
//	log.trace("queue_name:{}", fromStringz(queue_name));
//	elapsed.start;
//	client.send(queue_name, result_buffer);
//
//	time = elapsed.stop;
//	log.trace("send result time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
//
//	if(logging_io_messages)
//	{
//		elapsed.start;
//
//		auto tm = WallClock.now;
//		auto dt = Clock.toDate(tm);
//		File.append("io_messages.log", layout("{:yyyy-MM-dd HH:mm:ss},{} OUTPUT\r\n", tm, dt.time.millis));
//		File.append("io_messages.log", fromStringz(result_buffer));
//		File.append("io_messages.log", "\r\n\r\n\r\n");
//
//		time = elapsed.stop;
//		log.trace("logging output message, time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
//	}
//}

private long count_prepared_messages = 0;


// Loads server properties
private char[][char[]] load_props()
{
	char[][char[]] result;
	FileConduit props_conduit;

	auto props_path = new FilePath("./semargl.properties");

	if(!props_path.exists)
	// props file doesn't exists, so create new one with defaults
	{
		result["amqp_server_address"] = "localhost";
		result["amqp_server_port"] = "5672";
		result["amqp_server_exchange"] = "";
		result["amqp_server_login"] = "ba";
		result["amqp_server_password"] = "123456";
		result["amqp_server_routingkey"] = "";
		result["amqp_server_queue"] = "semargl-a";
		result["amqp_server_vhost"] = "magnetico";

		props_conduit = new FileConduit(props_path.toString(), FileConduit.ReadWriteCreate);
		auto output = new MapOutput!(char)(props_conduit.output);

		output.append(result);
		output.flush;
		props_conduit.close;
	}
	else
	{
		props_conduit = new FileConduit(props_path.toString(), FileConduit.ReadExisting);
		auto input = new MapInput!(char)(props_conduit.input);
		result = result.init;
		input.load(result);
		props_conduit.close;
	}

	return result;
}
