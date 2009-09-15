module server;

private import tango.core.Thread;
private import tango.io.Console;
private import tango.stdc.string;
private import std.string;
private import tango.stdc.posix.stdio;
private import Log;

private import Integer = tango.text.convert.Integer;

private import tango.io.Stdout;
private import Text = tango.text.Util;
private import tango.time.StopWatch;

private import HashMap;
private import TripleStorage;
private import authorization;

private import mom_client;
private import librabbitmq_client;
private import script_util;
private import RightTypeDef;
private import fact_tools;

librabbitmq_client client = null;

Authorization az = null;

char* result_buffer = null;
char* queue_name = null;
char* user = null;

void main(char[][] args)
{
	az = new Authorization();

	result_buffer = cast(char*) new char[10 * 1024];
	queue_name = cast(char*) (new char[40]);
	user = cast(char*) (new char[40]);

	//char[] hostname = "192.168.150.197\0";
	//	char[] hostname = "192.168.150.44\0";
	//	char[] hostname = "192.168.150.196\0";
	char[] hostname = "services.magnetosoft.ru\0";
	int port = 5672;
	char[] vhost = "magnetico\0";
	char[] login = "ba\0";
	char[] passw = "123456\0";
	char[] queue = "semargl";

	Stdout.format("connect to AMQP server ({}:{} vhost={}, queue={})", hostname, port, queue, vhost).newline;
	client = new librabbitmq_client(hostname, port, login, passw, queue, vhost);
	client.set_callback(&get_message);

	(new Thread(&client.listener)).start;
	Thread.sleep(0.250);
}

void get_message(byte* message, ulong message_size)
{
	synchronized
	{

		*(message + message_size) = 0;

		log.trace("\n\nget new message \n{}", getString(cast(char*) message));

		auto elapsed = new StopWatch();
		elapsed.start;

		double time;

		//	char check_right = 0;

		//	char* user_id;
		//	char* queue_name;
		char* list_docid;
		char* docId;
		uint targetRightType = RightType.READ;

		uint param_count = 0;


		char* fact_s[];
		char* fact_p[];
		char* fact_o[];
		uint is_fact_in_object[];

		// разберемся что за команда пришла
		// если первый символ = [<], значит пришли факты

		if(*(message + 0) == '<' && *(message + (message_size - 1)) == '.')
		{
			//		Stdout.format("this is facts...").newline;

			Counts count_elements = calculate_count_facts(cast(char*) message, message_size);
			fact_s = new char*[count_elements.facts];
			fact_p = new char*[count_elements.facts];
			fact_o = new char*[count_elements.facts];
			is_fact_in_object = new uint[count_elements.facts];
			uint count_facts = extract_facts_from_message(cast(char*) message, message_size, count_elements, fact_s,
					fact_p, fact_o, is_fact_in_object);
			// 				
			// замапим предикаты фактов на конкретные переменные put_id, arg_id
			int put_id = -1;
			int delete_by_element_id = -1;
			int arg_id = -1;

			for(int i = 0; i < count_facts; i++)
			{
				//				log.trace("look triple <{}><{}><{}>", toString(cast(char*) fact_s[i]), toString(
				//						cast(char*) fact_p[i]), toString(cast(char*) fact_o[i]));

				if(put_id < 0 && strcmp(fact_o[i], "magnet-ontology/authorization/functions#put") == 0 && strcmp(
						fact_p[i], "magnet-ontology#subject") == 0)
				{
					put_id = i;
					Stdout.format("found comand {}, id ={} ", toString(fact_o[i]), i).newline;
				}
				else
				{
					if(arg_id < 0 && strcmp(fact_p[i], "magnet-ontology/transport#argument") == 0)
					{
						arg_id = i;
						Stdout.format("found comand {}, id ={} ", toString(fact_p[i]), i).newline;
					}
					else
					{
						if(delete_by_element_id < 0 && strcmp(fact_o[i],
								"magnet-ontology/authorization/functions#delete_by_element_id") == 0 && strcmp(
								fact_p[i], "magnet-ontology#subject") == 0)
						{
							delete_by_element_id = i;
							Stdout.format("found comand {}, id ={} ", toString(fact_o[i]), i).newline;
						}
					}

				}

			}

			if(delete_by_element_id >= 0 && arg_id > 0)
			{
				log.trace("команда на удаление");

				az.getTripleStorage.getTriples (fact_o[arg_id], null, null, false);
				
//				az.getTripleStorage.removeTriple ();
				
				for(int i = 0; i < count_facts; i++)
				{
					if(is_fact_in_object[i] == arg_id)
					{
						// нужно определиться что именно удаляем, документ! или отдельный факт?
//						az.getTripleStorage (('D', toString(fact_s[i]), toString(fact_p[i]), toString(fact_o[i]));
					}
				}
				time = elapsed.stop;
				log.trace("time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
			}

			if(put_id >= 0 && arg_id > 0)
			{
				log.trace("команда на добавление");

				ulong uuid = getUUID();

				for(int i = 0; i < count_facts; i++)
				{
					if(is_fact_in_object[i] == arg_id)
					{
						/*						
						 // отфильтруем все факты-аргументы					
						 if(strcmp(fact_s[i], "0000000000000000") == 0)
						 longToHex(uuid, fact_s[i]);
						 else
						 {
						 if(strlen(fact_s[i]) == 0)
						 {
						 fact_s[i] = cast(char*) new char[16];
						 longToHex(uuid, fact_s[i]);
						 }
						 }
						 */
						log.trace("add triple <{}><{}><{}>", toString(cast(char*) fact_s[i]), toString(
								cast(char*) fact_p[i]), toString(cast(char*) fact_o[i]));
						az.logginTriple('A', toString(fact_s[i]), toString(fact_p[i]), toString(fact_o[i]));
					}
				}
				
				time = elapsed.stop;
				log.trace("time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
			}


			//			log.trace("# fact_p[0]={}, fact_o[0]={}", getString(fact_p[0]), getString(fact_o[0]));

			if(strcmp(fact_o[0], "magnet-ontology/authorization/functions#authorize") == 0 && strcmp(fact_p[0],
					"magnet-ontology#subject") == 0)
			{
				/* пример сообщения:
				 <3516df90-522a-476a-9470-8293daf2014a><magnet-ontology#subject><magnet-ontology/authorization/functions#authorize>.
				 <3516df90-522a-476a-9470-8293daf2014a><magnet-ontology/transport#argument>
				 {
				 <><magnet-ontology/authorization/acl#rights>"u".
				 <><magnet-ontology/authorization/acl#category>"DOCUMENT".
				 <><magnet-ontology/authorization/acl#elementId>"c49cc462c6eb4e7ca50da4075b1a44fe".
				 <><magnet-ontology/authorization/acl#targetSubsystemElement>"544c820e-ad22-4f3e-9eca-2e0d92ac0db9".
				 }.
				 <c5c8ce35-8082-4169-8c76-f0f40f4a85f3><magnet-ontology#subject><magnet-ontology/transport#set_from>.
				 <c5c8ce35-8082-4169-8c76-f0f40f4a85f3><magnet-ontology/transport#argument>"client-3516df90-522a-476a-9470-8293daf2014a".
				 <3516df90-522a-476a-9470-8293daf2014a><magnet-ontology/transport/message#reply_to>"client-3516df90-522a-476a-9470-8293daf2014a".  
				 */

				//			Stdout.format("this request on authorization").newline;
				char* command_uid = null;

				// это команда authorize?
				int authorize_id = 0;
				int from_id = 0;
				int right_id = 0;
				int category_id = 0;
				int targetId_id = 0;
				int elements_id = 0;
				int reply_to_id = 0;
				command_uid = fact_s[0];

				log.trace("this request on authorization #1");

				//			Stdout.format("this request on authorization #2").newline;

				if(authorize_id >= 0)
				{
					for(int i = 0; i < count_facts; i++)
					{
						if(strcmp(fact_p[i], "magnet-ontology/transport#set_from") == 0)
						{
							from_id = i;
						}
						else if(strcmp(fact_p[i], "magnet-ontology/authorization/acl#rights") == 0)
						{
							right_id = i;
						}
						else if(strcmp(fact_p[i], "magnet-ontology/authorization/acl#category") == 0)
						{
							category_id = i;
						}
						else if(strcmp(fact_p[i], "magnet-ontology/authorization/acl#targetSubsystemElement") == 0)
						{
							targetId_id = i;
						}
						else if(strcmp(fact_p[i], "magnet-ontology/authorization/acl#elementId") == 0)
						{
							elements_id = i;
						}
						else if(strcmp(fact_p[i], "magnet-ontology/transport/message#reply_to") == 0)
						{
							reply_to_id = i;
						}
					}
				}

				char* autz_elements;

				if(elements_id != 0)
				{
					autz_elements = fact_o[elements_id];
				}

				strcpy(queue_name, fact_o[reply_to_id]);
				strcpy(user, fact_o[targetId_id]);

				char* check_right = fact_o[right_id];

				char* result_ptr = cast(char*) result_buffer;

				//						printf("!!!! user_id=%s, elements=%s\n", user_id, autz_elements);

				uint*[] hierarhical_departments = null;
				hierarhical_departments = getDepartmentTreePath(user, az.getTripleStorage());
				//						log.trace("!!!! load_hierarhical_departments, count={}", hierarhical_departments.length);

				for(byte j = 0; *(check_right + j) != 0 && j < 4; j++)
				{
					if(*(check_right + j) == 'c')
						targetRightType = RightType.CREATE;
					else if(*(check_right + j) == 'r')
						targetRightType = RightType.READ;
					else if(*(check_right + j) == 'u')
						targetRightType = RightType.UPDATE;
					else if(*(check_right + j) == 'w')
						targetRightType = RightType.WRITE;
					else if(*(check_right + j) == 'd')
						targetRightType = RightType.DELETE;
				}

				//						Stdout.format("this request on authorization #1.1.0 {}, command_uid={}, command_len={}", targetRightType, getString (command_uid), strlen(command_uid)).newline;

				//				bool calculatedRight_isAdmin;
				//				calculatedRight_isAdmin = scripts.S01UserIsAdmin.calculate(user, null, targetRightType,
				//						az.getTripleStorage());

				uint count_prepared_doc = 0;
				uint count_authorized_doc = 0;
				uint doc_pos = 0;
				uint prev_doc_pos = 0;

				//			Stdout.format("this request on authorization #1.1.1 {}, command_uid={}, command_len={}", targetRightType, getString (command_uid), strlen(command_uid)).newline;

				*result_ptr = '<';
				strcpy(result_ptr + 1, command_uid);
				result_ptr += strlen(command_uid) + 1;
				strcpy(result_ptr, "><magnet-ontology/transport#result:data>\"");
				result_ptr += 41;

				for(uint i = 0; true; i++)
				{
					char prev_state_byte = *(autz_elements + i);

					//								Stdout.format("this request on authorization #1.2, {} {}", i, *(autz_elements + i)).newline;

					if(*(autz_elements + i) == ',' || *(autz_elements + i) == 0)
					{
						*(autz_elements + i) = 0;

						docId = cast(char*) (autz_elements + doc_pos);
						//					printf("docId:%s\n", docId);

						//					Stdout.format("this request on authorization #1.3, {} docId={}", i, getString (autz_elements + doc_pos)).newline;

						count_prepared_doc++;
						bool calculatedRight = az.authorize(docId, user, targetRightType, hierarhical_departments);
						//					Stdout.format("right = {}", calculatedRight).newline;

						//					if(calculatedRight == false)
						//					{
						//						for(uint j = doc_pos; *(autz_elements + j) != 0; j++)
						//						{
						//							*(autz_elements + j) = ' ';
						//						}
						//						*(autz_elements + i) = ' ';
						//					}
						//					else
						if(calculatedRight == true)
						{
							if(count_prepared_doc > 1)
							{
								*result_ptr = ',';
								result_ptr++;
							}

							strcpy(result_ptr, docId);
							result_ptr += strlen(docId);

							//						Stdout.format("this request on authorization #1.4 true").newline;
							//						*(autz_elements + i) = ',';
							count_authorized_doc++;
						}

						prev_doc_pos = doc_pos;
						doc_pos = i + 1;
					}
					if(prev_state_byte == 0)
					{
						*(autz_elements + i) = 0;
						break;
					}
				}

				strcpy(result_ptr, "\".\0");

				time = elapsed.stop;

				log.trace(
						"count auth in count docs={}, authorized count docs={}, calculate right time = {:d6} ms. ( {:d6} sec.), cps={}",
						count_prepared_doc, count_authorized_doc, time * 1000, time, count_prepared_doc / time);

				log.trace("queue_name:{}", getString(queue_name));
				log.trace("result:{}", getString(result_buffer));

				elapsed.start;

				client.send(queue_name, result_buffer);

				time = elapsed.stop;

				log.trace("send result time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);

			//			az.getTripleStorage().print_stat();

			}
		}

	//	printf("!!!! queue_name=%s\n", queue_name);
	//	Stdout.format("!!!! check_right={}", check_right).newline;
	//	printf("!!!! list_docid=%s\n", list_docid);

	//	Stdout.format("\nIN: list_docid={}", str_2_char_array(cast(char*) list_docid, doclistid_length)).newline;
	}
}
