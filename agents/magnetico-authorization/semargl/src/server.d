module server;

private import tango.core.Thread;
private import tango.io.Console;
private import std.c.string;

import Integer = tango.text.convert.Integer;

private import tango.io.Stdout;
import Text = tango.text.Util;
import tango.time.StopWatch;

import HashMap;
import TripleStorage;
import authorization;

import librabbitmq_client;
import script_util;
import RightTypeDef;

librabbitmq_client client = null;

Authorization az = null;

void main(char[][] args)
{
	az = new Authorization();

	char[] hostname = "192.168.150.197\0";
	//char[] hostname = "192.168.150.44\0";
	//	char[] hostname = "services.magnetosoft.ru\0";
	int port = 5672;

	Stdout.format("connect to AMQP server ({}:{})", hostname, port).newline;
	client = new librabbitmq_client(hostname, port, &get_message);

	(new Thread(&client.listener)).start;
	Thread.sleep(0.250);
}

private void prepare_message(char* message, ulong message_size)
{
	byte count_open_brakets = 0;
	byte count_fact_fragment = 0;
	byte count_facts = 0;

	for(int i = message_size; i > 0; i--)
	{
		char* cur_char = cast(char*) (message + i);

		if(*cur_char == '.')
			count_facts++;

		if(*cur_char == '{')
			count_open_brakets++;
	}

	char* facts_s[] = new char*[count_facts];
	char* facts_p[] = new char*[count_facts];
	char* facts_o[] = new char*[count_facts];
	uint is_fact_in_object[] = new uint[count_facts];
	uint stack_brackets[] = new uint[count_open_brakets];

	count_facts = 0;

	bool is_open_quotes = false;
	count_open_brakets = 0;

	for(int i = 0; i < message_size; i++)
	{
		char* cur_char_ptr = cast(char*) (message + i);
		char cur_char = *cur_char_ptr;

		if(cur_char == '"')
		{
			if(is_open_quotes == false)
				is_open_quotes = true;
			else
			{
				is_open_quotes = false;
				*cur_char_ptr = 0;
			}
		}

		if(cur_char == '{')
		{
			count_open_brakets++;
			stack_brackets[count_open_brakets] = count_facts;
		}

		if(cur_char == '<' || cur_char == '{' || (cur_char == '"' && is_open_quotes == true))
		{
			if(count_fact_fragment == 0)
			{
				is_fact_in_object[count_facts] = stack_brackets[count_open_brakets];
				facts_s[count_facts] = cur_char_ptr + 1;
			}
			if(count_fact_fragment == 1)
			{
				facts_p[count_facts] = cur_char_ptr + 1;
			}
			if(count_fact_fragment == 2)
			{
				facts_o[count_facts] = cur_char_ptr + 1;
			}

			count_fact_fragment++;
			if(count_fact_fragment > 2)
			{
				count_fact_fragment = 0;
				count_facts++;
			}

		}

		if(cur_char == '>')
			*cur_char_ptr = 0;

	//			if(*cur_char == '}')
	//				count_open_brakets--;

	//			if(*cur_char == '.' && count_open_brakets == 0)
	//			if(*cur_char == '.')
	//			{
	//				*cur_char = 0;
	//				count_fact_fragment = 0;
	//				count_facts++;
	//			}
	}

}

void get_message(byte* message, ulong message_size)
{
	*(message + message_size) = 0;
	printf("get new message %s\n", message);

	auto elapsed = new StopWatch();

	double time;

	char check_right = 0;

	char* user_id;
	char* queue_name;
	char* list_docid;
	char* docId;
	uint targetRightType = RightType.READ;

	uint param_count = 0;

	/*
		<subject><authorize><uid1>.
		<uid1><from>"hsearch--594463104-1245681854398098000".
		<uid1><right>"r".
		<uid1><category>"DOCUMENT".
		<uid1><targetId>"61b807a9-e350-45a1-a0ed-10afa8f987a4".
		<uid1><elements>"a8df72cae40b43deb5dfbb7d8af1bb34,da08671d0c50416481f32705a908f1ab,4107206856ea4a7b8d8b4b80444f7f85".	  
	 */
	
	elapsed.start;

	// разберемся что за команда пришла
	// если первый символ = [<], значит пришли факты
	if(*(message + 0) == '<' && *(message + 10) == 'p')
	{
		Stdout.format("this is facts on update").newline;

		prepare_message ();		
		
		// это команда put?
		int put_id = -1;
		uint arg_id = 0;
		for(int i = 0; i < count_facts; i++)
		{
			if(strcmp(facts_p[i], "put") == 0 && strcmp(facts_s[i], "subject") == 0)
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
				if(strcmp(facts_p[i], "argument") == 0/* && strcmp(facts_s[i], facts_o[put_id]) == 0*/)
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
					//					Stdout.format("add triple <{}><{}><{}>", str_2_char_array(facts_s[i]), str_2_char_array(facts_p[i]), str_2_char_array(facts_o[i])).newline;
					az.addAuthorizeData(str_2_char_array(facts_s[i]), str_2_char_array(facts_p[i]), str_2_char_array(
							facts_o[i]));
				//					TripleStorage ts = az.getTripleStorage();
				//					ts.addTriple (str_2_char_array(facts_s[i]), str_2_char_array(facts_p[i]), str_2_char_array(facts_o[i]));
				}
			}

		}

		time = elapsed.stop;

		for(int i = 0; i < count_facts; i++)
		{
			Stdout.format("s = {:X2} {:X4} {}", i, facts_s[i], str_2_char_array(cast(char*) facts_s[i])).newline;
			Stdout.format("p = {:X2} {:X4} {}", i, facts_p[i], str_2_char_array(cast(char*) facts_p[i])).newline;
			Stdout.format("o = {:X2} {:X4} {}", i, facts_o[i], str_2_char_array(cast(char*) facts_o[i])).newline;
			Stdout.format("is_fact_in_object = {:X2} {}\n", i, is_fact_in_object[i]).newline;
		}

		Stdout.format("time = {:d6} ms. ( {:d6} sec.)", time * 1000, time).newline;
	}
	else if(*(message + 0) == '<' && *(message + 13) == 'h')
	{
		Stdout.format("this request on authorization").newline;
		// иначе считаем это списком ID документов на авторизацию

		//	uint prev_pos = 0;
		uint*[] hierarhical_departments = null;

		bool calculatedRight_isAdmin;

		uint doclistid_pos = 0;
		uint doclistid_length = 0;

		uint count_prepared_doc = 0;
		uint count_authorized_doc = 0;

		uint doc_pos = 0;
		uint prev_doc_pos = 0;

		for(uint i = 0; i < message_size; i++)
		{
			if(*(message + i) == ':' || param_count == 0)
			{

				if(param_count == 0)
				{
					queue_name = cast(char*) (message + i);
				}
				else
				{
					*(message + i) = 0;
				}

				if(param_count == 1)
				{
					//				queue_name_size = i - prev_pos;
					user_id = cast(char*) (message + i + 1);
				}
				if(param_count == 2)
				{
					//				user_name_size = i;
					check_right = *(message + i + 1);

					{
						printf("!!!! user_id=%s\n", user_id);

						hierarhical_departments = getDepartmentTreePath(user_id, az.getTripleStorage());
						Stdout.format("!!!! load_hierarhical_departments, count={}", hierarhical_departments.length).newline;

						if(check_right == 'r')
							targetRightType = RightType.READ;

						calculatedRight_isAdmin = S01UserIsAdmin.calculate(user_id, null, targetRightType,
								az.getTripleStorage());

					//					if (calculatedRight)
					//					Stdout.format("!!!! user is Admin").newline;
					//					else
					//						Stdout.format("!!!! user is not Admin").newline;

					}
				}
				if(param_count == 3)
				{
					doclistid_pos = i + 1;
					doc_pos = doclistid_pos;
					prev_doc_pos = doc_pos;
					list_docid = cast(char*) (message + doclistid_pos);
					doclistid_length = message_size - doclistid_pos;
				}

				param_count++;
			//			prev_pos = i;
			}

			if(*(message + i) == ',' && param_count == 4)
			{
				*(message + i) = 0;

				docId = cast(char*) (message + doc_pos);

				count_prepared_doc++;
				//							printf("!!+! docId=%s\n", docId);
				bool calculatedRight = az.authorize(docId, user_id, targetRightType, hierarhical_departments);
				//			Stdout.format("prev_doc_pos={}, doc_pos={}, right = {}", prev_doc_pos, doc_pos, calculatedRight).newline;

				if(calculatedRight == false)
				{
					for(uint j = doc_pos; j < message_size && *(message + j) != 0; j++)
					{
						*(message + j) = ' ';
					}
					*(message + i) = ' ';
				}
				else
				{
					*(message + i) = ',';
					count_authorized_doc++;
				}

				prev_doc_pos = doc_pos;
				doc_pos = i + 1;
			}
		}

		if(docId !is null)
		{
			docId = cast(char*) (message + doc_pos);

			count_prepared_doc++;
			printf("!!+! docId=%s\n", docId);
			bool calculatedRight = az.authorize(docId, user_id, targetRightType, hierarhical_departments);
			//			Stdout.format("prev_doc_pos={}, doc_pos={}, right = {}", prev_doc_pos, doc_pos, calculatedRight).newline;

			if(calculatedRight == false)
			{
				for(uint j = doc_pos; j < message_size && *(message + j) != 0; j++)
				{
					*(message + j) = ' ';
				}
			//				*(message + i) = ' ';
			}
			else
			{
				count_authorized_doc++;
			//				*(message + i) = ',';
			}

			//			prev_doc_pos = doc_pos;
			//			doc_pos = i + 1;
			time = elapsed.stop;

			Stdout.format(
					"count auth in count docs={}, authorized count docs={}, calculate right time = {:d6} ms. ( {:d6} sec.)",
					count_prepared_doc, count_authorized_doc, time * 1000, time).newline;

			elapsed.start;

			client.send(queue_name, list_docid);

			time = elapsed.stop;

			Stdout.format("send result time = {:d6} ms. ( {:d6} sec.)", time * 1000, time).newline;
		}

		az.getTripleStorage().print_stat();
	}
//	printf("!!!! queue_name=%s\n", queue_name);
//	Stdout.format("!!!! check_right={}", check_right).newline;
//	printf("!!!! list_docid=%s\n", list_docid);

//	Stdout.format("\nIN: list_docid={}", str_2_char_array(cast(char*) list_docid, doclistid_length)).newline;
}

private char[] str_2_char_array(char* str)
{
	uint str_length = 0;
	char* tmp_ptr = str;
	while(*tmp_ptr != 0)
	{
		//			Stdout.format("@={}", *tmp_ptr).newline;
		tmp_ptr++;
	}

	str_length = tmp_ptr - str;

	char[] res = new char[str_length];

	uint i;
	for(i = 0; i < str_length; i++)
	{
		res[i] = *(str + i);
	}
	res[i] = 0;

	return res;
}
