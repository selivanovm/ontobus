module server;

private import tango.core.Thread;
private import tango.io.Console;
private import tango.stdc.string;
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
import str_tool;

librabbitmq_client client = null;

Authorization az = null;

void main(char[][] args)
{
	az = new Authorization();

	//char[] hostname = "192.168.150.197\0";
	//char[] hostname = "192.168.150.44\0";
	char[] hostname = "services.magnetosoft.ru\0";
	int port = 5672;

	Stdout.format("connect to AMQP server ({}:{})", hostname, port).newline;
	client = new librabbitmq_client(hostname, port);
	client.set_callback (&get_message);

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
	
	char* queue_name = cast(char*)(new char [40]); 
	char* user = cast(char*)(new char [40]); 
	char* fact_s[];
	char* fact_p[];
	char* fact_o[];
	uint is_fact_in_object[];
	
	// разберемся что за команда пришла
	// если первый символ = [<], значит пришли факты
	
	if(*(message + 0) == '<' && *(message + (message_size-1)) == '.')
	{
		Counts count_elements = calculate_count_facts(cast(char*) message, message_size);
		fact_s = new char* [count_elements.facts];
		fact_p = new char* [count_elements.facts];
		fact_o = new char* [count_elements.facts];
		is_fact_in_object = new uint [count_elements.facts];		
		uint count_facts = extract_facts_from_message(cast(char*) message, message_size, count_elements, fact_s, fact_p, fact_o, is_fact_in_object);
		
		
		if(*(message + 0) == '<' && *(message + 10) == 'p')
		{
			Stdout.format("this is facts on update").newline;

		// это команда put?
		int put_id = -1;
		uint arg_id = 0;
		for(int i = 0; i < count_elements.facts; i++)
		{
			if(strcmp(fact_p[i], "put") == 0 && strcmp(fact_s[i], "subject") == 0)
			{
				put_id = i;
				//				Stdout.format("found comand put, id ={} ", i).newline;	
				break;
			}
		}

		if(put_id >= 0)
		{
			for(int i = 0; i < count_facts; i++)
			{
				if(strcmp(fact_p[i], "argument") == 0/* && strcmp(facts_s[i], facts_o[put_id]) == 0*/)
				{
					//					Stdout.format("found argument put, factid={}", i).newline;
					arg_id = i;
					break;
				}
			}
		}

		if(arg_id != 0)
		{
			for(int i = 0; i < count_facts; i++)
			{
				if(is_fact_in_object[i] == arg_id)
				{
				//	Stdout.format("add triple <{}><{}><{}>", str_2_char_array(facts_s[i]), str_2_char_array(facts_p[i]), str_2_char_array(facts_o[i])).newline;
					az.addAuthorizeData(str_2_chararray(fact_s[i]), str_2_chararray(fact_p[i]), str_2_chararray(fact_o[i]));
				//	TripleStorage ts = az.getTripleStorage();
					//	ts.addTriple (str_2_char_array(facts_s[i]), str_2_char_array(facts_p[i]), str_2_char_array(facts_o[i]));
				}
			}

		}

		time = elapsed.stop;

		for(int i = 0; i < count_facts; i++)
		{
			Stdout.format("s = {:X2} {:X4} {}", i, fact_s[i], str_2_chararray(cast(char*) fact_s[i])).newline;
			Stdout.format("p = {:X2} {:X4} {}", i, fact_p[i], str_2_chararray(cast(char*) fact_p[i])).newline;
			Stdout.format("o = {:X2} {:X4} {}", i, fact_o[i], str_2_chararray(cast(char*) fact_o[i])).newline;
			Stdout.format("is_fact_in_object = {:X2} {}\n", i, is_fact_in_object[i]).newline;
		}

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
					if(strcmp(fact_p[i], "right") == 0)
					{
						right_id = i;
					}
					if(strcmp(fact_p[i], "category") == 0)
					{
						category_id = i;
					}
					if(strcmp(fact_p[i], "targetId") == 0)
					{
						targetId_id = i;
					}
					if(strcmp(fact_p[i], "elements") == 0)
					{
						elements_id = i;
					}
				}
			}

			char* autz_elements;

			if(elements_id != 0)
			{
				autz_elements = fact_o[elements_id];
			}

//			queue_name = fact_o[from_id];
			strcpy (queue_name, fact_o[from_id]);
			strcpy (user, fact_o[targetId_id]);
			
			char* check_right = fact_o[right_id];
			
			// результат поместим в то же сообщение
			char* result = cast (char*)message;
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
			calculatedRight_isAdmin = scripts.S01UserIsAdmin.calculate(user, null, targetRightType, az.getTripleStorage());

			uint count_prepared_doc = 0;
			uint count_authorized_doc = 0;
			uint doc_pos = 0;
			uint prev_doc_pos = 0;

			*result_ptr = '<';
			strcpy (result_ptr+1, command_uid);
			result_ptr += strlen (command_uid) + 1;
			strcpy (result_ptr, "><result:data>\"");
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
						strcpy (result_ptr, docId);
						result_ptr += strlen (docId);
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
			
			strcpy (result_ptr, "\".");

			time = elapsed.stop;

			Stdout.format(
					"count auth in count docs={}, authorized count docs={}, calculate right time = {:d6} ms. ( {:d6} sec.), cps={}",
					count_prepared_doc, count_authorized_doc, time * 1000, time, count_prepared_doc/time).newline;
			
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


