// The contents of this file are subject to the Mozilla Public License
// Version 1.1 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS"
// basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
// License for the specific language governing rights and limitations
// under the License.
//
// The Original Code is RabbitMQ.
//
// The Initial Developers of the Original Code are LShift Ltd,
// Cohesive Financial Technologies LLC, and Rabbit Technologies Ltd.
//
// Portions created before 22-Nov-2008 00:00:00 GMT by LShift Ltd,
// Cohesive Financial Technologies LLC, or Rabbit Technologies Ltd
// are Copyright (C) 2007-2008 LShift Ltd, Cohesive Financial
// Technologies LLC, and Rabbit Technologies Ltd.
//
// Portions created by LShift Ltd are Copyright (C) 2007-2009 LShift
// Ltd. Portions created by Cohesive Financial Technologies LLC are
// Copyright (C) 2007-2009 Cohesive Financial Technologies
// LLC. Portions created by Rabbit Technologies Ltd are Copyright
// (C) 2007-2009 Rabbit Technologies Ltd.
//
// All Rights Reserved.
//
// Contributor(s): Mikhail Selivanov(Magnetosoft LLC).       
//
import tango.io.Stdout;
import tango.stdc.stdio;
import tango.stdc.stdlib;
import tango.net.Socket;
import tango.stdc.string: strlenn = strlen;
import tango.stdc.stringz;

import amqp_base;
import amqp;
import amqp_framing;
import amqp_framing_;
import amqp_private;
import amqp_connection;
import amqp_socket;
import amqp_api;
import amqp_mem;

import example_utils;

private import tango.core.Thread;

bool wait_send = false;

char* listen_queue = null;

class amqp_messages
{
	private char[] hostname;
	private int port;
	private char[] vhost;
	private char[] login;
	private char[] passw;
	private char[] exchange;

	private amqp_connection_state_t* conn;
	private Socket socket;

	this(char[] _hostname, int _port, char[] _vhost, char[] _exchange, char[] _login, char[] _passw)
	{
		hostname = _hostname;
		port = _port;
		vhost = _vhost;
		login = _login;
		passw = _passw;
		exchange = _exchange;
	}

	public void connect()
	{

		socket = amqp_open_socket(hostname, port);
		conn = amqp_new_connection(socket);

		//Stdout.format("{} {} {}", hostname, port, conn).newline;

		//Stdout.format("main #2 {}", conn).newline;

		die_on_amqp_error(amqp_login(conn, toStringz(vhost), 0, 131072, 0, amqp_sasl_method_enum.AMQP_SASL_METHOD_PLAIN, toStringz(login), toStringz(
				passw)), "Logging in");

		//Stdout.format("main #3").newline;

		amqp_channel_open(conn, 1);

		//Stdout.format("main #4").newline;

		die_on_amqp_error(amqp_rpc_reply, "Opening channel");

		//Stdout.format("main #5").newline;

		amqp_exchange_declare(conn, 1, amqp_cstring_bytes(toStringz(exchange)), amqp_cstring_bytes("direct"), 0, 0, 0, AMQP_EMPTY_TABLE);

		Stdout.format("connect, conn={}", conn).newline;
	}

	public void send(char[] routingkey, char* messagebody)
	{
		synchronized
		{
			while(result_out !is null)
			{
				Thread.yield();
			};

//			if (wait_send == true)
//				Stdout.format("waiting, while wait_send == true").newline;

			while(wait_send == true)
			{
				Thread.yield();
			};
//			Stdout.format("go, while wait_send != true").newline;
			

			wait_send = true;

//			Stdout.format("send start, conn={}", conn).newline;

			amqp_basic_properties_t props;
			props._flags = AMQP_BASIC_CONTENT_TYPE_FLAG | AMQP_BASIC_DELIVERY_MODE_FLAG;
			props.content_type = amqp_cstring_bytes("text/plain");
			props.delivery_mode = 2; // persistent delivery mode
			//Stdout.format("main #6").newline;
			die_on_error(amqp_basic_publish(conn, 1, amqp_cstring_bytes(toStringz(exchange)), amqp_cstring_bytes(toStringz(routingkey)), 0, 0,
					&props, amqp_cstring_bytes(messagebody)), "Publishing");

			wait_send = false;
//			Stdout.format("send end, conn={}", conn).newline;
		}
	}

	public void close()
	{
		//Stdout.format("main #7").newline;

		die_on_amqp_error(amqp_channel_close(conn, 1, AMQP_REPLY_SUCCESS), "Closing channel");
		//Stdout.format("main #8").newline;
		die_on_amqp_error(amqp_connection_close(conn, AMQP_REPLY_SUCCESS), "Closing connection");
		//Stdout.format("main #9").newline;
		amqp_destroy_connection(conn);
		//Stdout.format("main #10").newline;

		//die_on_error(close(cast(socket_t)sockfd), "Closing socket");
		//Stdout.format("main #RETURN").newline;
	}

	public void set_listen_queue(char[] bindingkey)
	{
		synchronized
		{
//			Stdout.format("set_listen_queue {}", bindingkey).newline;
			listen_queue = toStringz(bindingkey);
			
			amqp_bytes_t queuename;
			{
//				Stdout.format("Declaring queue, conn={}", conn).newline;

				amqp_queue_declare_ok_t* r = amqp_queue_declare(conn, 1, AMQP_EMPTY_BYTES, 0, 0, 0, 1, AMQP_EMPTY_TABLE);
				die_on_amqp_error(amqp_rpc_reply, "Declaring queue");
				queuename = amqp_bytes_malloc_dup((*r).queue);
				if(queuename.bytes is null)
				{
					die_on_error(-ENOMEM, "Copying queue name");
				}
			}

//			Stdout.format("Binding queue").newline;
			amqp_queue_bind(conn, 1, queuename, amqp_cstring_bytes(toStringz(exchange)), amqp_cstring_bytes(listen_queue), AMQP_EMPTY_TABLE);
			die_on_amqp_error(amqp_rpc_reply, "Binding queue");

			amqp_basic_consume(conn, 1, queuename, AMQP_EMPTY_BYTES, 0, 1, 0);
			die_on_amqp_error(amqp_rpc_reply, "Consuming");
			
		}
	}

	public char* result_out = null;

	public void listen()
	{
		synchronized
		{
			while(result_out !is null)
			{Thread.yield();
			};


			{
				amqp_frame_t frame;
				int result;

				amqp_basic_deliver_t* d;
				amqp_basic_properties_t* p;
				size_t body_target;
				size_t body_received;

				for(short i = 0; i < 1; i++)
				{
					amqp_maybe_release_buffers(conn);
					result = amqp_simple_wait_frame(conn, &frame);
//					printf("Result %d\n", result);
					if(result <= 0)
						break;

//					printf("Frame type %d, channel %d\n", frame.frame_type, frame.channel);
					if(frame.frame_type != AMQP_FRAME_METHOD)
						continue;

//					printf("Method %s\n", amqp_method_name(frame.payload.method.id));
					if(frame.payload.method.id != AMQP_BASIC_DELIVER_METHOD)
						continue;

					//printf("main #1\n");

					d = cast(amqp_basic_deliver_t*) frame.payload.method.decoded;

					//printf("main #2\n");

					//Stdout.format("Delivery {}, exchange {} routingkey {}",
					//		    cast(uint64_t) (*d).delivery_tag, getString(cast(char *) (*d).exchange.bytes, cast(uint) (*d).exchange.len),
					//	    getString(cast(char *) (*d).routing_key.bytes, cast(uint) (*d).routing_key.len)).newline;

					//printf("main #3\n");

					/*      printf("Delivery %u, exchange %.*s routingkey %.*s\n",
					 cast(uint64_t) (*d).delivery_tag,
					 cast(int) (*d).exchange.len, cast(char *) (*d).exchange.bytes,
					 cast(int) (*d).routing_key.len, cast(char *) (*d).routing_key.bytes);*/

					//printf("main #4\n");

					result = amqp_simple_wait_frame(conn, &frame);
					if(result <= 0)
						break;

					if(frame.frame_type != AMQP_FRAME_HEADER)
					{
						fprintf(stderr, "Expected header!");
						abort();
					}
					p = cast(amqp_basic_properties_t*) frame.payload.properties.decoded;
//					if((*p)._flags & AMQP_BASIC_CONTENT_TYPE_FLAG)
//					{
//						printf("Content-type: %.*s\n", cast(int) (*p).content_type.len, cast(char*) (*p).content_type.bytes);
//					}
//					printf("----\n");

					body_target = frame.payload.properties.body_size;
					body_received = 0;

					while(body_received < body_target)
					{
//						Stdout.format("#L7").newline;

						result = amqp_simple_wait_frame(conn, &frame);
						if(result <= 0)
							break;

						if(frame.frame_type != AMQP_FRAME_BODY)
						{
							fprintf(stderr, "Expected body!");
							abort();
						}

						body_received += frame.payload.body_fragment.len;
						assert(body_received <= body_target);

						/*	amqp_dump(frame.payload.body_fragment.bytes,
						 frame.payload.body_fragment.len);*/

//						Stdout.format("Content: \n{}", getString(cast(char*) frame.payload.body_fragment.bytes, frame.payload.body_fragment.len)).newline;

						result_out = cast(char*) frame.payload.body_fragment.bytes;
					}

//					Stdout.format("#L9").newline;

					if(body_received != body_target)
					{
						/* Can only happen when amqp_simple_wait_frame returns <= 0 */
						/* We break here to close the connection */
						break;
					}

//					Stdout.format("#L9.1").newline;

				}

//				Stdout.format("#L9.2").newline;

			}
//			Stdout.format("#L10 ret").newline;

			return;
		}
	}

}

char[] getString(char* s, uint l)
{
	char[] result = new char[l];
	for(uint i = 0; i < l; i++)
		result[i] = *(s + i);
	return result;
}

public static char[] getString(char* s)
{
	return s ? s[0 .. strlenn(s)] : cast(char[]) null;
}
