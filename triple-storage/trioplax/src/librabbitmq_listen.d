private import tango.io.Stdout;
private import std.c.string;

import librabbitmq_headers;

class librabbitmq
{
	char[] hostname;
	int port;
	void function(char* from, byte* txt, ulong size) message_acceptor;
	
	this(char[] _hostname, int _port, void function(char *from, byte* txt, ulong size) _message_acceptor)
	{
		hostname = _hostname;
		port = _port;
		message_acceptor = _message_acceptor;
	}

	void listener()
	{
		amqp_connection_state_t_ conn;

		conn = amqp_new_connection();
		Stdout.format("conn={:X4} ", &conn).newline;

		int sockfd;
		sockfd = amqp_open_socket(cast(char*) hostname, port);

		if(sockfd < 0)
			Stdout.format("connection faled, errcode={} ", sockfd).newline;
		else
			Stdout.format("connection is ok, code={}", sockfd).newline;

		amqp_set_sockfd(&conn, sockfd);

		char* vhost = cast(char*) "/\u0000";
		char* login = cast(char*) "guest\u0000";
		char* passw = cast(char*) "guest\u0000";
		char* exchange = cast(char*) "ex1\u0000";
		char* bindingkey = cast(char*) "guest\u0000";

		amqp_rpc_reply_t_ res_login;
		res_login = amqp_login(&conn, vhost, 131072, amqp_sasl_method_enum.AMQP_SASL_METHOD_PLAIN, login, passw);

		Stdout.format("login state={}", res_login.reply_type).newline;

		amqp_table_t_ arguments;
		arguments.num_entries = 0;
		arguments.entries = null;

		amqp_rpc_reply_t_ result;
		amqp_bytes_t_ queuename;

		{
			amqp_queue_declare_t s;

			s.ticket = 0;
			s.queue = amqp_cstring_bytes("QEUE1");
			s.passive = 0;
			s.durable = 0;
			s.exclusive = 0;
			s.auto_delete = 1;
			s.nowait = 0;
			s.arguments = arguments;

			result = amqp_simple_rpc(&conn, 1, amqp_def.AMQP_QUEUE_DECLARE_METHOD,
					amqp_def.AMQP_QUEUE_DECLARE_OK_METHOD, &s);

			Stdout.format("result declare={:X4}", &result).newline;

			amqp_queue_declare_ok_t* r = cast(amqp_queue_declare_ok_t*) result.reply.decoded;

			queuename = amqp_bytes_malloc_dup(r.queue);

			if(queuename.bytes is null)
			{
				Stdout.format("Err in: Copying queue name");
				return 0;
			}

		}

		{

			amqp_queue_bind_t s;
			s.ticket = 0;
			s.queue = queuename , s.exchange = amqp_cstring_bytes(exchange) , s.routing_key = amqp_cstring_bytes(
					bindingkey) , s.nowait = 0 , s.arguments = arguments;

			result = amqp_simple_rpc(&conn, 1, amqp_def.AMQP_QUEUE_BIND_METHOD, amqp_def.AMQP_QUEUE_BIND_OK_METHOD, &s);
			Stdout.format("result bind={:X4}, queuename={}", &result, cast(char*) queuename.bytes).newline;
		}

		{
			amqp_bytes_t_ consumer_tag;
			consumer_tag.len = 0;
			consumer_tag.bytes = null;

			amqp_basic_consume_t s;

			s.ticket = 0;
			s.queue = queuename;
			s.consumer_tag = consumer_tag;
			s.no_local = 0;
			s.no_ack = 1;
			s.exclusive = 0;
			s.nowait = 0;

			result = amqp_simple_rpc(&conn, 1, amqp_def.AMQP_BASIC_CONSUME_METHOD,
					amqp_def.AMQP_BASIC_CONSUME_OK_METHOD, &s);
			Stdout.format("result consume={:X4}", &result).newline;
		}

		{
			amqp_frame_t_ frame;
			int result_listen;

			amqp_basic_deliver_t* d;
			amqp_basic_properties_t* p;
			size_t body_target;
			size_t body_received;

			while(1)
			{
				amqp_maybe_release_buffers(&conn);
				result_listen = amqp_simple_wait_frame(&conn, &frame);

				char* ptr = cast(char*) &frame;

				amqp_method_number_t* ptr_frame_payload_method_id = cast(uint*) (cast(void*) &frame + 4);
				uint* ptr_frame_payload_method_decoded = cast(uint*) (cast(void*) &frame + 8);
				size_t* ptr_frame_payload_body_fragment_len = cast(uint*) (cast(void*) &frame + 4);
				uint* ptr_frame_payload_body_fragment_bytes = cast(uint*) (cast(void*) &frame + 8);
				uint16_t* ptr_frame_payload_properties_class_id = cast(uint16_t*) (cast(void*) &frame + 6); // ? uint64_t
				uint16_t* ptr_frame_payload_properties_body_size = cast(uint16_t*) (cast(void*) &frame + 8);
				uint* ptr_frame_payload_properties_decoded = cast(uint*) (cast(void*) &frame + 10);

				//      printf("Result %d\n", result);
				if(result_listen <= 0)
					break;

				//			Stdout.format("Frame type {}, channel {}", frame.frame_type, frame.channel).newline;
				if(frame.frame_type != amqp_def.AMQP_FRAME_METHOD)
					continue;

				if(*ptr_frame_payload_method_id != amqp_def.AMQP_BASIC_DELIVER_METHOD)
					continue;

				d = cast(amqp_basic_deliver_t*) *ptr_frame_payload_method_decoded;
				//			printf("Delivery %llu, exchange %.*s routingkey %.*s\n", d.delivery_tag,
				//					cast(int) d.exchange.len, cast(char*) d.exchange.bytes,
				//					cast(int) d.routing_key.len, cast(char*) d.routing_key.bytes);

				result_listen = amqp_simple_wait_frame(&conn, &frame);
				if(result_listen <= 0)
					break;
				//			printf("wait 2 ");
				//			for(int i = 0; i < frame.sizeof; i++)
				//				printf("%0*x ", 2, *(ptr + i));
				//			printf("\n");

				//			Stdout.format("result listen 2={} frame_type={}", result_listen, frame.frame_type).newline;

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
				//      printf("----\n");

				body_target = *ptr_frame_payload_properties_body_size;
				body_received = 0;

				Stdout.format("result body_target={} class_id={}", body_target, *ptr_frame_payload_properties_class_id).newline;

				while(body_received < body_target)
				{
					result_listen = amqp_simple_wait_frame(&conn, &frame);
					if(result_listen <= 0)
						break;

					if(frame.frame_type != amqp_def.AMQP_FRAME_BODY)
					{
						Stdout.format("Expected body!, frame.type={}", frame.frame_type).newline;
						//          abort();
						return 0;
					}

					body_received += *ptr_frame_payload_body_fragment_len;
//					Stdout.format(
//							"body_received={} *ptr_frame_payload_body_fragment_bytes={} *ptr_frame_payload_body_fragment_len={}",
//							body_received, *ptr_frame_payload_body_fragment_bytes, *ptr_frame_payload_body_fragment_len).newline;
					assert(body_received <= body_target);

//					amqp_dump(cast(void*) *ptr_frame_payload_body_fragment_bytes, *ptr_frame_payload_body_fragment_len);
//					printf("data: %.*s\n", *ptr_frame_payload_body_fragment_len,
//							cast(void*) *ptr_frame_payload_body_fragment_bytes);
					
					byte* message = cast(byte*) *ptr_frame_payload_body_fragment_bytes; 
					
					message_acceptor(message, *ptr_frame_payload_body_fragment_len);
				}

			//			if(body_received != body_target)
			//			{
			//				break;
			//			}

			}

		}

	}

}