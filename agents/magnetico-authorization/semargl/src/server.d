module server;

private import tango.core.Thread;
private import tango.io.Console;
private import tango.stdc.string;
private import std.string;
private import tango.stdc.posix.stdio;

import Integer = tango.text.convert.Integer;

private import tango.io.Stdout;
import Text = tango.text.Util;
import tango.time.StopWatch;

import HashMap;
import TripleStorage;
import authorization;

import mom_client;
import librabbitmq_client;
import script_util;
import RightTypeDef;
import fact_tools;

librabbitmq_client client = null;

Authorization az = null;

void main(char[][] args)
{
	az = new Authorization();

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
	*(message + message_size) = 0;
	printf("get new message %s\n", message);

	auto elapsed = new StopWatch();

	double time;

	//	char check_right = 0;

	//	char* user_id;
	//	char* queue_name;
	char* list_docid;
	char* docId;
	uint targetRightType = RightType.READ;

	uint param_count = 0;

	elapsed.start;

	char* queue_name = cast(char*) (new char[40]);
	char* user = cast(char*) (new char[40]);
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
		// замапим предикаты фактов на конкретные переменные put_id, fact_id, arg_id
		int put_id = -1;
		int arg_id = -1;
		int operation_id = -1;

		for(int i = 0; i < count_elements.facts; i++)
		{
			if(put_id < 0 && strcmp(fact_p[i], "put") == 0 && strcmp(fact_s[i], "subject") == 0)
			{
				put_id = i;
			//				Stdout.format("found comand {}, id ={} ", toString(fact_p[i]), i).newline;
			}
			else
			{
				if(arg_id < 0 && strcmp(fact_p[i], "argument") == 0)
				{
					arg_id = i;
				//					Stdout.format("found comand {}, id ={} ", toString(fact_p[i]), i).newline;
				}
				else
				{

					if(operation_id < 0 && strcmp(fact_p[i], "name") == 0 && strcmp(fact_s[i], "operation") == 0)
					{
						operation_id = i;
					//						Stdout.format("found operation {}, id ={} ", toString(fact_p[i]), i).newline;
					}

				}
			}
		}

		if(put_id >= 0 && arg_id > 0 && operation_id > 0)
		{
			if(strcmp(fact_o[operation_id], "create") == 0)
			{
				//			Stdout.format("команда на добавление").newline;

				ulong uuid = getUUID();

				for(int i = 0; i < count_facts; i++)
				{
					if(is_fact_in_object[i] == arg_id && i != operation_id)
					{
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

						//					Stdout.format("add triple <{}><{}><{}>", toString(cast(char*) fact_s[i]), toString(
						//							cast(char*) fact_p[i]), toString(cast(char*) fact_o[i])).newline;
						az.addAuthorizeData(toString(fact_s[i]), toString(fact_p[i]), toString(fact_o[i]));
					}
				}
			}
			else
			{
				if(strcmp(fact_o[operation_id], "update") == 0)
				{
				}

				else
				{
					if(strcmp(fact_o[operation_id], "delete") == 0)
					{
					}
				}

			}

			time = elapsed.stop;
			/*
			 for(int i = 0; i < count_facts; i++)
			 {
			 Stdout.format("s = {:X2} {:X4} {}", i, fact_s[i], toString(cast(char*) fact_s[i])).newline;
			 Stdout.format("p = {:X2} {:X4} {}", i, fact_p[i], toString(cast(char*) fact_p[i])).newline;
			 Stdout.format("o = {:X2} {:X4} {}", i, fact_o[i], toString(cast(char*) fact_o[i])).newline;
			 Stdout.format("is_fact_in_object = {:X2} {}\n", i, is_fact_in_object[i]).newline;
			 }
			 */
			Stdout.format("time = {:d6} ms. ( {:d6} sec.)", time * 1000, time).newline;
		}

		if(*(message + 0) == '<' && *(message + 13) == 'h')
		{
			/*
			 <subject><authorize><uid1>.
			 <uid1><from>"hsearch--594463104-1245681854398098000".
			 <uid1><right>"r".
			 <uid1><category>"DOCUMENT".
			 <uid1><targetId>"61b807a9-e350-45a1-a0ed-10afa8f987a4".
			 <uid1><elements>"a8df72cae40b43deb5dfbb7d8af1bb34,da08671d0c50416481f32705a908f1ab,4107206856ea4a7b8d8b4b80444f7f85".	  
			 */

			//			Stdout.format("this request on authorization").newline;
			char* command_uid = null;

			// это команда authorize?
			int authorize_id = -1;
			int from_id = 0;
			int right_id = 0;
			int category_id = 0;
			int targetId_id = 0;
			int elements_id = 0;
			int set_from_id = 0;

			//			Stdout.format("this request on authorization #1").newline;

			for(int i = 0; i < count_facts; i++)
			{
				if(strcmp(fact_p[i], "authorize") == 0 && strcmp(fact_s[i], "subject") == 0)
				{
					command_uid = fact_o[i];
					authorize_id = i;
					//					Stdout.format("found comand authorize, id ={} ", i).newline;
					break;
				}
			}

			//			Stdout.format("this request on authorization #2").newline;

			if(authorize_id >= 0)
			{
				for(int i = 0; i < count_facts; i++)
				{
					if(strcmp(fact_p[i], "from") == 0)
					{
						from_id = i;
					}
					else if(strcmp(fact_p[i], "right") == 0)
					{
						right_id = i;
					}
					else if(strcmp(fact_p[i], "category") == 0)
					{
						category_id = i;
					}
					else if(strcmp(fact_p[i], "targetId") == 0)
					{
						targetId_id = i;
					}
					else if(strcmp(fact_p[i], "elements") == 0)
					{
						elements_id = i;
					}
					else if(strcmp(fact_p[i], "set_from") == 0)
					{
						set_from_id = i;
					}
				}
			}

			char* autz_elements;

			if(elements_id != 0)
			{
				autz_elements = fact_o[elements_id];
			}

			//			queue_name = fact_o[from_id];
			strcpy(queue_name, fact_o[set_from_id]);
			strcpy(user, fact_o[targetId_id]);

			char* check_right = fact_o[right_id];

			// результат поместим в то же сообщение
			char* result = cast(char*) message;
			char* result_ptr = result;

			//			printf("!!!! user_id=%s, elements=%s\n", user_id, autz_elements);

			uint*[] hierarhical_departments = null;
			hierarhical_departments = getDepartmentTreePath(user, az.getTripleStorage());
			//			Stdout.format("!!!! load_hierarhical_departments, count={}", hierarhical_departments.length).newline;

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

			//			Stdout.format("this request on authorization #1.1 {}", targetRightType).newline;

			bool calculatedRight_isAdmin;
			calculatedRight_isAdmin = scripts.S01UserIsAdmin.calculate(user, null, targetRightType,
					az.getTripleStorage());

			uint count_prepared_doc = 0;
			uint count_authorized_doc = 0;
			uint doc_pos = 0;
			uint prev_doc_pos = 0;

			*result_ptr = '<';
			strcpy(result_ptr + 1, command_uid);
			result_ptr += strlen(command_uid) + 1;
			strcpy(result_ptr, "><result:data>\"");
			result_ptr += 15;

			for(uint i = 0; true; i++)
			{
				char prev_state_byte = *(autz_elements + i);

				//				Stdout.format("this request on authorization #1.2, {}{}", i, *(autz_elements + i)).newline;
				if(*(autz_elements + i) == ',' || *(autz_elements + i) == 0)
				{
					*(autz_elements + i) = 0;

					docId = cast(char*) (autz_elements + doc_pos);
					//					printf("docId:%s\n", docId);

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
						strcpy(result_ptr, docId);
						result_ptr += strlen(docId);
						*result_ptr = ',';
						result_ptr++;
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

			strcpy(result_ptr, "\".");

			time = elapsed.stop;

			Stdout.format(
					"count auth in count docs={}, authorized count docs={}, calculate right time = {:d6} ms. ( {:d6} sec.), cps={}",
					count_prepared_doc, count_authorized_doc, time * 1000, time, count_prepared_doc / time).newline;

			printf("result:%s\n", result);
			printf("queue_name:%s\n", queue_name);

			elapsed.start;

			client.send(queue_name, result);

			time = elapsed.stop;

			Stdout.format("send result time = {:d6} ms. ( {:d6} sec.)", time * 1000, time).newline;

			az.getTripleStorage().print_stat();
		}
	}

//	printf("!!!! queue_name=%s\n", queue_name);
//	Stdout.format("!!!! check_right={}", check_right).newline;
//	printf("!!!! list_docid=%s\n", list_docid);

//	Stdout.format("\nIN: list_docid={}", str_2_char_array(cast(char*) list_docid, doclistid_length)).newline;
}
