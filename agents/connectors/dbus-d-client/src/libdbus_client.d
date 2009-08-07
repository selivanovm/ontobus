private import tango.io.Stdout;
private import std.c.string;
private import std.c.stdio;

import libdbus_headers;

class libdbus_client
{
	void function(byte* txt, ulong size) message_acceptor;

	this(void function(byte* txt, ulong size) _message_acceptor)
	{
		message_acceptor = _message_acceptor;

	}
	
	/**
	 * Connect to the DBUS bus and send a broadcast signal
	 */
	int send(char* routingkey, char* sigvalue)
	{
		DBusMessage* msg;
		DBusMessageIter args;
		DBusConnection* conn;
		DBusError err;
		int ret;
		dbus_uint32_t serial = 0;

		printf("Sending signal with value %s\n", sigvalue);

		// initialise the error value
		dbus_error_init(&err);

		// connect to the DBUS system bus, and check for errors
		conn = dbus_bus_get(DBusBusType.DBUS_BUS_SESSION, &err);
		if(dbus_error_is_set(&err))
		{
			fprintf(stderr, "Connection Error (%s)\n", err.message);
			dbus_error_free(&err);
		}
		if(conn is null)
		{
			return -1;
		}

		// register our name on the bus, and check for errors
		ret = dbus_bus_request_name(conn, "test.signal.source", dbus_shared.DBUS_NAME_FLAG_REPLACE_EXISTING, &err);
		if(dbus_error_is_set(&err))
		{
			fprintf(stderr, "Name Error (%s)\n", err.message);
			dbus_error_free(&err);
		}
		if(ret != dbus_shared.DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER)
		{
			return -1;
		}

		// create a signal & check for errors 
		msg = dbus_message_new_signal("/test/signal/Object", // object name of the signal
				"test.signal.Type", // interface name of the signal
				"Test"); // name of the signal
		if(msg is null)
		{
			fprintf(stderr, "Message Null\n");
			return -1;
		}

		// append arguments onto signal
		dbus_message_iter_init_append(msg, &args);
		if(!dbus_message_iter_append_basic(&args, dbus_shared.DBUS_TYPE_STRING, &sigvalue))
		{
			fprintf(stderr, "Out Of Memory!\n");
			return -1;
		}

		//    int i = 0;

		//    for (i = 0; i < 1000000; i++)
		{

			// send the message and flush the connection
			if(!dbus_connection_send(conn, msg, &serial))
			{
				fprintf(stderr, "Out Of Memory!\n");
				return -1;
			}

		}

		dbus_connection_flush(conn);

		printf("Signal Sent\n");

		// free the message 
		dbus_message_unref(msg);
	}

	/**
	 * Listens for signals on the bus
	 */
	void listener()
	{
		DBusMessage* msg;
		DBusMessageIter args;
		DBusConnection* conn;
		DBusError err;
		int ret;
		char* sigvalue;

		printf("Listening for signals\n");

		// initialise the errors
		dbus_error_init(&err);

		// connect to the bus and check for errors
		conn = dbus_bus_get(DBusBusType.DBUS_BUS_SESSION, &err);
		if(dbus_error_is_set(&err))
		{
			fprintf(stderr, "Connection Error (%s)\n", err.message);
			dbus_error_free(&err);
		}
		if(conn is null)
		{
			return -1;
		}

		// request our name on the bus and check for errors
		ret = dbus_bus_request_name(conn, "test.signal.sink", dbus_shared.DBUS_NAME_FLAG_REPLACE_EXISTING, &err);
		if(dbus_error_is_set(&err))
		{
			fprintf(stderr, "Name Error (%s)\n", err.message);
			dbus_error_free(&err);
		}
		if(dbus_shared.DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER != ret)
		{
			return -1;
		}

		// add a rule for which messages we want to see
		dbus_bus_add_match(conn, "type='signal',interface='test.signal.Type'", &err); // see signals from the given interface
		dbus_connection_flush(conn);
		if(dbus_error_is_set(&err))
		{
			fprintf(stderr, "Match Error (%s)\n", err.message);
			return -1;
		}
		printf("Match rule sent\n");

		// loop listening for signals being emmitted
		while(true)
		{

			// non blocking read of the next available message
			dbus_connection_read_write(conn, 0);
			msg = dbus_connection_pop_message(conn);

			// loop again if we haven't read a message
			if(msg is null)
			{
				//         sleep(1);
				continue;
			}

			// check if the message is a signal from the correct interface and with the correct name
			if(dbus_message_is_signal(msg, "test.signal.Type", "Test"))
			{

				// read the parameters
				if(!dbus_message_iter_init(msg, &args))
					fprintf(stderr, "Message Has No Parameters\n");
				else if(dbus_shared.DBUS_TYPE_STRING != dbus_message_iter_get_arg_type(&args))
					fprintf(stderr, "Argument is not string!\n");
				else
					dbus_message_iter_get_basic(&args, &sigvalue);

				message_acceptor(cast (byte*)sigvalue, strlen (sigvalue));
				
				printf("Got Signal with value %s\n", sigvalue);
			}

			// free the message
			dbus_message_unref(msg);
		}
	}

}