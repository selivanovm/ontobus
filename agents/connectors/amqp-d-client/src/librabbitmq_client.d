private import tango.io.Stdout;
private import tango.stdc.string;
private import tango.stdc.posix.stdio;

import librabbitmq_headers;
import mom_client;

private import tango.core.Thread;

class librabbitmq_client: mom_client
{
	amqp_connection_state_t_ conn;
	char[] vhost;// = "magnetico\0";
	char[] login;// = "ba\0";
	char[] passw;// = "123456\0";
	char* bindingkey = null;
	char* exchange = cast(char*) "\0";

	int waiting_for_login = 5;

	char[] hostname;
	int port;
	void function(byte* txt, ulong size) message_acceptor;

	this(char[] _hostname, int _port, char[] _login, char[] _passw, char[] _queue, char[] _vhost)
	{
		hostname = _hostname;
		port = _port;
		login = _login;
		passw = _passw;
		bindingkey = cast(char*)_queue;
		vhost = _vhost;
	}

	void set_callback(void function(byte* txt, ulong size) _message_acceptor)
	{
		message_acceptor = _message_acceptor;
	}

	int send(char* routingkey, char* messagebody)
	{
		amqp_basic_properties_t props;

		props._flags = amqp_def.AMQP_BASIC_CONTENT_TYPE_FLAG | amqp_def.AMQP_BASIC_DELIVERY_MODE_FLAG;
		props.content_type = amqp_cstring_bytes("text/plain");
		props.delivery_mode = 2; // persistent delivery mode

		int result_publish = amqp_basic_publish(&conn, 1, amqp_cstring_bytes(exchange), amqp_cstring_bytes(routingkey), 0, 0, &props,
				amqp_cstring_bytes(messagebody));

		return result_publish;
	}

	void listener()
	{
		//		amqp_connection_state_t_ conn;

		while(true)
		{
			bool is_connect_succsess = false;
			while(!is_connect_succsess)
			{
				Stdout.format("\nlistener:connect to AMQP server {}:{}", hostname, port).newline;

				conn = amqp_new_connection();

				int sockfd;
				sockfd = amqp_open_socket(cast(char*) hostname, port);

				if(sockfd < 0)
					Stdout.format("connection faled, errcode={} ", sockfd).newline;
				else
					Stdout.format("connection is ok, code={}", sockfd).newline;

				if(sockfd == 4)
				{
					Stdout.format("connection={:X4} ", &conn).newline;

					amqp_set_sockfd(&conn, sockfd);

					amqp_rpc_reply_t_ res_login;

					res_login = amqp_login(&conn, cast(char*) vhost, 0, 131072, 0, amqp_sasl_method_enum.AMQP_SASL_METHOD_PLAIN, cast(char*) login,
							cast(char*) passw);
					Stdout.format("login state={}", res_login.reply_type).newline;

					if(res_login.reply_type == 1)
					{
						is_connect_succsess = true;
						amqp_channel_open(&conn, 1);
					}

				}
				if(!is_connect_succsess)
					Thread.sleep(waiting_for_login);
			}

			amqp_table_t_ arguments;
			arguments.num_entries = 0;
			arguments.entries = null;

			amqp_rpc_reply_t_ result;
			amqp_bytes_t_ queuename;

			try
			{
				//				#define AMQP_EMPTY_BYTES ((amqp_bytes_t) { .len = 0, .bytes = NULL }) 
				amqp_bytes_t AMQP_EMPTY_BYTES;
				AMQP_EMPTY_BYTES.len = 0;
				AMQP_EMPTY_BYTES.bytes = null;

				//				#define AMQP_EMPTY_TABLE ((amqp_table_t) { .num_entries = 0, .entries = NULL }) 
				amqp_table_t AMQP_EMPTY_TABLE;
				AMQP_EMPTY_TABLE.num_entries = 0;
				AMQP_EMPTY_TABLE.entries = null;

				amqp_queue_declare_ok_t_* r = amqp_queue_declare(&conn, 1, AMQP_EMPTY_BYTES, 0, 0, 0, 1, AMQP_EMPTY_TABLE);
				//				die_on_amqp_error(amqp_rpc_reply, "Declaring queue");
				queuename = amqp_bytes_malloc_dup(r.queue);
				if(queuename.bytes is null)
				{
					throw new Exception("Declaring queue:Copying queue name");
				}
				Stdout.format("declare ok").newline;
			}
			catch(Exception ex)
			{
				printf("bindingkey=[%s] \n", bindingkey);
				Stdout.format("Exception in:{}, amqp_queue_declare\n", ex).newline;;
				throw ex;
			}

			try
			{
				//				#define AMQP_EMPTY_TABLE ((amqp_table_t) { .num_entries = 0, .entries = NULL }) 
				amqp_table_t AMQP_EMPTY_TABLE;
				AMQP_EMPTY_TABLE.num_entries = 0;
				AMQP_EMPTY_TABLE.entries = null;

				amqp_queue_bind(&conn, 1, queuename, amqp_cstring_bytes(exchange), amqp_cstring_bytes(bindingkey), AMQP_EMPTY_TABLE);

				Stdout.format("Binding queue ok").newline;
			}
			catch(Exception ex)
			{
				Stdout.format("Exception in: Binding queue");
				throw ex;
			}

			try
			{
				//				#define AMQP_EMPTY_BYTES ((amqp_bytes_t) { .len = 0, .bytes = NULL }) 
				amqp_bytes_t AMQP_EMPTY_BYTES;
				AMQP_EMPTY_BYTES.len = 0;
				AMQP_EMPTY_BYTES.bytes = null;

				amqp_basic_consume(&conn, 1, queuename, AMQP_EMPTY_BYTES, 0, 1, 0);

				Stdout.format("Consuming ok").newline;
			}
			catch(Exception ex)
			{
				Stdout.format("Exception in: Consuming");
				throw ex;
			}

			{
				amqp_frame_t_ frame;
				int result_listen;

				amqp_basic_deliver_t* d;
				amqp_basic_properties_t* p;
				size_t body_target;
				size_t body_received;

				while(true)
				{
					amqp_maybe_release_buffers(&conn);
//					printf("amqp_simple_wait_frame\n");
					result_listen = amqp_simple_wait_frame(&conn, &frame);
//					printf("Result %d\n", result);
					if(result_listen <= 0)
					{
						Stdout.format("result_listen {} <= 0, -> break", result_listen).newline;
						break;
						//continue;
					}

					//	Stdout.format("Frame type {}, channel {}", frame.frame_type, frame.channel).newline;
					if(frame.frame_type != amqp_def.AMQP_FRAME_METHOD)
						continue;

					char* ptr = cast(char*) &frame;

					amqp_method_number_t* ptr_frame_payload_method_id = cast(uint*) (cast(void*) &frame + 4);
					uint* ptr_frame_payload_method_decoded = cast(uint*) (cast(void*) &frame + 8);
					size_t* ptr_frame_payload_body_fragment_len = cast(uint*) (cast(void*) &frame + 4);
					uint* ptr_frame_payload_body_fragment_bytes = cast(uint*) (cast(void*) &frame + 8);
					uint16_t* ptr_frame_payload_properties_class_id = cast(uint16_t*) (cast(void*) &frame + 6); // ? uint64_t
					uint16_t* ptr_frame_payload_properties_body_size = cast(uint16_t*) (cast(void*) &frame + 8);
					uint* ptr_frame_payload_properties_decoded = cast(uint*) (cast(void*) &frame + 10);

					if(*ptr_frame_payload_method_id != amqp_def.AMQP_BASIC_DELIVER_METHOD)
						continue;

					d = cast(amqp_basic_deliver_t*) *ptr_frame_payload_method_decoded;
					/*
					 printf("Delivery %u, exchange %.*s routingkey %.*s\n",
					 (unsigned) d->delivery_tag,
					 (int) d->exchange.len, (char *) d->exchange.bytes,
					 (int) d->routing_key.len, (char *) d->routing_key.bytes);
					 */

					result_listen = amqp_simple_wait_frame(&conn, &frame);
					if(result_listen <= 0)
					{
						Stdout.format("result_listen2 {} <= 0, -> break", result_listen).newline;
						break;
					}

					if(frame.frame_type != amqp_def.AMQP_FRAME_HEADER)
					{
						Stdout.format("Expected header! frame.frame_type={}", frame.frame_type).newline;
						return 0;
						//        abort();
					}

					p = cast(amqp_basic_properties_t*) *ptr_frame_payload_properties_decoded;

					if(p._flags & amqp_def.AMQP_BASIC_CONTENT_TYPE_FLAG)
					{
						//      printf("Content-type: %.*s\n",
						//             (int) p->content_type.len, (char *) p->content_type.bytes);
					}

					body_target = *ptr_frame_payload_properties_body_size;
					body_received = 0;

					//					Stdout.format("result body_target={} class_id={}", body_target,
					//							*ptr_frame_payload_properties_class_id).newline;

					while(body_received < body_target)
					{
						result_listen = amqp_simple_wait_frame(&conn, &frame);
						if(result_listen <= 0)
						{
							Stdout.format("result_listen3 {} <= 0, -> break", result_listen).newline;
							break;
						}

						if(frame.frame_type != amqp_def.AMQP_FRAME_BODY)
						{
							Stdout.format("Expected body!, frame.type={}", frame.frame_type).newline;
							//          abort();
							return 0;
						}

						body_received += *ptr_frame_payload_body_fragment_len;
						/*
						 Stdout.format("body_received={} *ptr_frame_payload_body_fragment_bytes={} *ptr_frame_payload_body_fragment_len={}", 
						 body_received, *ptr_frame_payload_body_fragment_bytes, *ptr_frame_payload_body_fragment_len).newline;
						 */

						assert(body_received <= body_target);

						/*
						 amqp_dump(cast(void*) *ptr_frame_payload_body_fragment_bytes, *ptr_frame_payload_body_fragment_len);
						 printf("data: %.*s\n", *ptr_frame_payload_body_fragment_len, cast(void*) *ptr_frame_payload_body_fragment_bytes);
						 */

						byte* message = cast(byte*) *ptr_frame_payload_body_fragment_bytes;

						message_acceptor(message, *ptr_frame_payload_body_fragment_len);
					}

					//			if(body_received != body_target)
					//			{
					/* Can only happen when amqp_simple_wait_frame returns <= 0 */
					/* We break here to close the connection */
					//				break;
					//			}
				}
			}

		}

	}

}
/*
 void die_on_amqp_error(amqp_rpc_reply_t_ x, char *context) 
 { 
 fprintf(stderr, "!!!0"); 
 
 switch (x.reply_type) { 
 case AMQP_RESPONSE_NORMAL: 
 return; 
 
 case AMQP_RESPONSE_NONE: 
 fprintf(stderr, "%s: missing RPC reply type!", context); 
 break; 
 
 case AMQP_RESPONSE_LIBRARY_EXCEPTION: 
 fprintf(stderr, "%s: %s\n", context, 
 x.library_errno ? strerror(x.library_errno) : "(end-of-stream)"); 
 break; 
 
 case AMQP_RESPONSE_SERVER_EXCEPTION: 
 switch (x.reply.id) { 
 case AMQP_CONNECTION_CLOSE_METHOD: { 
 fprintf(stderr, "!!!1"); 

 
 amqp_connection_close_t *m = (amqp_connection_close_t_ *) x.reply.decoded; 
 fprintf(stderr, "%s: server connection error %d, message: %.*s", 
 context, 
 m.reply_code, 
 (int) m.reply_text.len, (char *) m.reply_text.bytes);
 
 
 break; 
 } 
 case AMQP_CHANNEL_CLOSE_METHOD: { 
 fprintf(stderr, "!!!2"); 
 
 amqp_channel_close_t *m = (amqp_channel_close_t *) x.reply.decoded; 
 fprintf(stderr, "%s: server channel error %d, message: %.*s", 
 context, 
 m.reply_code, 
 (int) m.reply_text.len, (char *) m.reply_text.bytes); 
 
 break; 
 } 
 default: 
 fprintf(stderr, "%s: unknown server error, method id 0x%08X", context, x.reply.id); 
 break; 
 } 
 break; 
 } 
 
 exit(1); 
 }
 */
