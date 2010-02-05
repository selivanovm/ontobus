private import tango.io.Stdout;
private import tango.stdc.string;
private import tango.stdc.stdio;

private import tango.core.Thread;

import libdbus_headers;
import mom_client;

class libdbus_client: mom_client
{
	private float sleep_between_look_queue = 0.01; // in seconds
	
	private DBusConnection* conn = null;
	private DBusError err;

	private char* reciever_name = null;
	private char* see_rule_for_listener = null;
	private char* interface_name = null;
	private char* name_of_the_signal = "message";

	private char* service_name = null; //
	private char* dest_object_name_of_the_signal = null;
	private char* service_interface_name = null; //
	private char* service_name_of_the_signal = "message";

	void function(byte* txt, ulong size, mom_client from_client) message_acceptor;

	this()
	{
	}

	void setServiceName(char[] im)
	{
		service_name = (im ~ ".signal.source\0").ptr;
		service_interface_name = (im ~ ".signal.Type\0").ptr;
	}

	void setListenFrom(char[] listen_from)
	{
		reciever_name = (listen_from ~ ".signal.sink\0").ptr;
		see_rule_for_listener = ("type='signal',interface='" ~ listen_from ~ ".signal.Type'\0").ptr;
		interface_name = (listen_from ~ ".signal.Type\0").ptr;
	}

	//	void setSender(char[] to)
	//	{
	//		dest_object_name_of_the_signal = ("/" ~ to ~ "/signal/Object\0").ptr;
	//	}

	void connect()
	{
		int ret;

		if(err.name is null)
		{
			// initialise the error value
			dbus_error_init(&err);
		}

		if(conn is null)
		{
			// connect to the DBUS system bus, and check for errors
			conn = dbus_bus_get(DBusBusType.DBUS_BUS_SESSION, &err);
			if(dbus_error_is_set(&err))
			{
				fprintf(stderr, "Connection Error (%s)\n", err.message);
				dbus_error_free(&err);
			}
			if(conn is null)
			{
				fprintf(stderr, "Connection is null (%s)\n", err.message);
				return -1;
			}
			fprintf(stderr, "Connection is ok\n");
		}

		// register our name on the bus, and check for errors
		ret = dbus_bus_request_name(conn, service_name, dbus_shared.DBUS_NAME_FLAG_REPLACE_EXISTING, &err);
		if(dbus_error_is_set(&err))
		{
			fprintf(stderr, "Name Error (%s)\n", err.message);
			dbus_error_free(&err);
		}
		if(ret != dbus_shared.DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER)
		{
			fprintf(stderr, "ret != dbus_shared.DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER\n");
			return -1;
		}

		if(reciever_name !is null)
		{
			// request our name on the bus and check for errors
			ret = dbus_bus_request_name(conn, reciever_name, dbus_shared.DBUS_NAME_FLAG_REPLACE_EXISTING, &err);
			if(dbus_error_is_set(&err))
			{
				fprintf(stderr, "Name Error (%s)\n", err.message);
				dbus_error_free(&err);
			}
			if(dbus_shared.DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER != ret)
			{
				return -1;
			}
		}

	}

	void set_callback(void function(byte* txt, ulong size, mom_client from_client) _message_acceptor)
	{
		message_acceptor = _message_acceptor;
	}

	char[] add_to_dest_object_name_of_the_signal = "/signal/Object\0";

	/**
	 * Connect to the DBUS bus and send a broadcast signal
	 */
	int send(char* routingkey, char* sigvalue)
	{
		//		printf("Signal Sent to %s\n", routingkey);

		DBusMessage* msg;
		DBusMessageIter args;
		int ret;
		dbus_uint32_t serial = 0;

		int len_routingkey = strlen(routingkey);

		char[] dest_object_name_of_the_signal = new char[strlen(routingkey) + 1 + add_to_dest_object_name_of_the_signal.length];
		//		printf("Signal Sent dest_object_name_of_the_signal.length=%d\n", dest_object_name_of_the_signal);
		dest_object_name_of_the_signal[0] = '/';
		strncpy(dest_object_name_of_the_signal.ptr + 1, routingkey, len_routingkey);
		//		printf("Signal Sent %d=\n", 1 + len_routingkey + add_to_dest_object_name_of_the_signal.length);
		strncpy(dest_object_name_of_the_signal.ptr + 1 + len_routingkey, add_to_dest_object_name_of_the_signal.ptr,
				add_to_dest_object_name_of_the_signal.length);

		//		printf("Sending signal to %s, with value %s\n", dest_object_name_of_the_signal.ptr, sigvalue);

		// create a signal & check for errors 
		msg = dbus_message_new_signal(dest_object_name_of_the_signal.ptr, // object name of the signal
				service_interface_name, // interface name of the signal
				service_name_of_the_signal); // name of the signal
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

		// send the message and flush the connection
		if(!dbus_connection_send(conn, msg, &serial))
		{
			fprintf(stderr, "Out Of Memory!\n");
			return -1;
		}

		dbus_connection_flush(conn);

		//		printf("Signal Sent\n");

		// free the message 
		dbus_message_unref(msg);
//		printf("dbus_message_unref ok\n");

		return 0;
	}

	char* get_message()
	{
		DBusError err;

		if(err.name is null)
		{ // initialise the errors
			dbus_error_init(&err);
		}

		DBusMessage* msg;
		DBusMessageIter args;

		char* sigvalue;

		// add a rule for which messages we want to see
		dbus_bus_add_match(conn, see_rule_for_listener, &err); // see signals from the given interface
		dbus_connection_flush(conn);
		if(dbus_error_is_set(&err))
		{
			fprintf(stderr, "Match Error (%s)\n", err.message);
			return null;
		}
		printf("Match rule sent [%s]\n", see_rule_for_listener);

		// loop listening for signals being emmitted
		while(true)
		{

			// non blocking read of the next available message
			dbus_connection_read_write(conn, 0);
			msg = dbus_connection_pop_message(conn);

			// loop again if we haven't read a message
			if(msg is null)
			{
				Thread.sleep(sleep_between_look_queue);
				continue;
			}

			//				printf("msg=%s", msg);

			// check if the message is a signal from the correct interface and with the correct name
			if(dbus_message_is_signal(msg, interface_name, name_of_the_signal))
			{

				// read the parameters
				if(!dbus_message_iter_init(msg, &args))
					fprintf(stderr, "Message Has No Parameters\n");
				else if(dbus_shared.DBUS_TYPE_STRING != dbus_message_iter_get_arg_type(&args))
					fprintf(stderr, "Argument is not string!\n");
				else
					dbus_message_iter_get_basic(&args, &sigvalue);

				//					printf("Got Signal with value %s\n", sigvalue);
			}

			// free the message
			dbus_message_unref(msg);
		} // while read

       return sigvalue;
	}

	/**
	 * Listens for signals on the bus
	 */
	void listener()
	{
		printf("Listening for signals\n");

		while(true)
		{
			DBusError err;

			if(err.name is null)
			{ // initialise the errors
				dbus_error_init(&err);
			}

			DBusMessage* msg;
			DBusMessageIter args;

			char* sigvalue;

			// add a rule for which messages we want to see
			dbus_bus_add_match(conn, see_rule_for_listener, &err); // see signals from the given interface
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
					Thread.sleep(sleep_between_look_queue);
					continue;
				}

				//				printf("msg=%s", msg);

				// check if the message is a signal from the correct interface and with the correct name
				if(dbus_message_is_signal(msg, interface_name, name_of_the_signal))
				{

					// read the parameters
					if(!dbus_message_iter_init(msg, &args))
						fprintf(stderr, "Message Has No Parameters\n");
					else if(dbus_shared.DBUS_TYPE_STRING != dbus_message_iter_get_arg_type(&args))
						fprintf(stderr, "Argument is not string!\n");
					else
						dbus_message_iter_get_basic(&args, &sigvalue);

					message_acceptor(cast(byte*) sigvalue, strlen(sigvalue), this);

					//					printf("Got Signal with value %s\n", sigvalue);
				}

				// free the message
				dbus_message_unref(msg);
			} // while read
		} // while
	}

}