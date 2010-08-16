module autotest;

private import tango.io.Stdout;

private import Predicates;
private import mom_client;
private import Log;
private import fact_tools;

//private import tango.io.File;
private import tango.io.device.File;

//private import Text = tango.text.Util;
private import tango.text.Text;
//private import tango.text.Regex;
private import portions_read;
private import tango.stdc.string;
private import tango.stdc.stringz;
private import tango.stdc.stdio;

void function(byte* txt, ulong size, mom_client from_client) message_acceptor;

private char* output_data = null;
private int count_commands = 0;
private long count_repeat;
private bool nocompare;

private static mom_client im;

bool stop_on_next_command = false;

class autotest: mom_client
{
	char[] message_log_file_name;

	this(char[] _message_log_file_name, long _count_repeat, bool _nocompare)
	{
		count_repeat = _count_repeat;
		nocompare = _nocompare;
		message_log_file_name = _message_log_file_name;
		log.trace("open message_log file [{}]", message_log_file_name);
		im = this;
	}

	void set_callback(void function(byte* txt, ulong size, mom_client from_client) _message_acceptor)
	{
		message_acceptor = _message_acceptor;
	}

	int send(char* routingkey, char* messagebody)
	{

		if(nocompare == false)
		{
			//			printf("\nCOMPARE OUTPUT message from file: %s\n", output_data);
			//			printf("\nCOMPARE OUTPUT message accepted : %s\n", messagebody);

			log.trace("autotest:messages comparing");
			// сравним оба ответа по тексту 
			if(strcmp(output_data, messagebody) == 0)
			{
				return 0;
			}

			char* messagebody_copy = cast(char*) new byte[strlen(messagebody) + 1];
			strcpy(messagebody_copy, messagebody);

			char* output_data_copy = cast(char*) new byte[strlen(output_data) + 1];
			strcpy(output_data_copy, output_data);

			log.trace("autotest:messages text not compare");

			// тексты сообщений не совпадают, но размер как минимум должен совпадать, даже если факты идут в другом порядке
			if (strlen(messagebody) != strlen(output_data))
			{
				log_info_and_set_exit_flag (messagebody, output_data);
				return 0;
			}

			
			// тексты сообщений не совпадают, но пофактно они могут совпадать, просто порядок разный
			// а значит, сравним оба ответа предварительно разобрав их на факты

			log.trace("autotest:parse recieved message");

			char* recieved_fact_s[];
			char* recieved_fact_p[];
			char* recieved_fact_o[];
			uint recieved_is_fact_in_object[];

			Counts count_elements = calculate_count_facts(messagebody_copy, strlen(messagebody_copy));
			recieved_fact_s = new char*[count_elements.facts];
			recieved_fact_p = new char*[count_elements.facts];
			recieved_fact_o = new char*[count_elements.facts];
			recieved_is_fact_in_object = new uint[count_elements.facts];

			log.trace("autotest:parse original message");

			uint count_recieved_facts = extract_facts_from_message(messagebody_copy, strlen(messagebody_copy),
					count_elements, recieved_fact_s, recieved_fact_p, recieved_fact_o, recieved_is_fact_in_object);

			char* original_fact_s[];
			char* original_fact_p[];
			char* original_fact_o[];
			uint original_is_fact_in_object[];

			count_elements = calculate_count_facts(output_data_copy, strlen(output_data_copy));
			original_fact_s = new char*[count_elements.facts];
			original_fact_p = new char*[count_elements.facts];
			original_fact_o = new char*[count_elements.facts];
			original_is_fact_in_object = new uint[count_elements.facts];
			int count_original_fact_ok = 0;

			uint count_original_facts = extract_facts_from_message(output_data_copy, strlen(output_data_copy),
					count_elements, original_fact_s, original_fact_p, original_fact_o, original_is_fact_in_object);

			bool compare_is_ok;

			log.trace("autotest:compare facts count_recieved_facts={}, count_original_facts={}", count_recieved_facts,
					count_original_facts);

			if(count_recieved_facts == count_original_facts)
			{

				for(int i = 0; i < count_original_facts; i++)
				{
					compare_is_ok = false;
					for(int j = 0; j < count_original_facts; j++)
					{
						//						log.trace("autotest:compare facts i={}, j={}", i, j);
						if(strcmp(original_fact_p[i], RESULT_DATA.ptr) == 0)
						{
							if(strcmp(original_fact_s[i], recieved_fact_s[j]) == 0 && strcmp(original_fact_p[i],
									recieved_fact_p[j]) == 0)
							{
								count_original_fact_ok++;
								compare_is_ok = true;
								break;
							}

						} else
						{
							if(strcmp(original_fact_s[i], recieved_fact_s[j]) == 0 && strcmp(original_fact_p[i],
									recieved_fact_p[j]) == 0 && strcmp(original_fact_o[i], recieved_fact_o[j]) == 0)
							{
								count_original_fact_ok++;
								compare_is_ok = true;
								break;
							}
						}

					}
					if(compare_is_ok == false)
					{
						log.trace("facts <{}><{}>\"{}\" not found in recieved message",
								fromStringz(original_fact_s[i]), fromStringz(original_fact_p[i]), fromStringz(
										original_fact_o[i]));
						break;
					}
				}
			}

			if(count_original_fact_ok != count_original_facts)
			{
				log_info_and_set_exit_flag (messagebody, output_data);
			}

		}
		return 0;
	}

	private void log_info_and_set_exit_flag (char *messagebody, char* output_data)
	{
		stop_on_next_command = true;

		auto style = File.ReadWriteOpen;
		style.share = File.Share.Read;
		style.open = File.Open.Create;
		File file = new File("recieved_message", style);
		file.output.write(fromStringz(messagebody));
		file.close();

		File file2 = new File("original_message", style);
		file2.output.write(fromStringz(output_data));
		file2.close();

		File file3 = new File("original_recieved_message", style);
		file3.output.write(fromStringz(output_data));
		file3.output.write("\r\n");
		file3.output.write(fromStringz(messagebody));
		file3.close();
	}
	
	char* get_message()
	{
		throw new Exception("not implemented");
	}

	void listener()
	{
		log.trace("autotest listen!");

		for(long i = 0; i < count_repeat; i++)
		{
			parse_file(message_log_file_name, "\r", "\r\n\r\n\r\n", &prepare_block);
		}

		log.trace("autotest listen end, count commands: {}", count_commands);
	}

}

void prepare_block(char* line, ulong line_length)
{
	line[line_length] = 0;

	char* end_io_block = strstr(line, "\r\n\r\n\r\n");
	if(end_io_block !is null)
		*end_io_block = 0;

	//	log.trace("read new block {}", line[0 .. (end_io_block-line)]);

	char* input_data = strstr(line, "INPUT");

	if(input_data !is null)
	{
		input_data += 7;
	}

	output_data = strstr(input_data, "OUTPUT");

	if(output_data is null)
	{
		printf("\nINPUT %s\n", input_data);
		throw new Exception("OUTPUT message not found");
	}

	if(output_data !is null)
	{
		*output_data = 0;
		output_data += 8;
	}

	char* end_input_block = strstr(input_data + 2, "\r\n");
	if(end_input_block !is null)
		*end_input_block = 0;
	else
		end_input_block = end_io_block;

	int size = end_input_block - input_data;

	if(size < 0)
		throw new Exception("autotest:prepare_block, size < 0");

	//		printf("\nINPUT %d: %s\n", size, input_data);

	//		printf("\nOUTPUT: %s\n", output_data);

	if(strstr(input_data, CREATE.ptr) !is null && strstr(input_data, "<>") !is null && output_data !is null)
	{
		//				log.trace("#i1 result_data_header={}", result_data_header);
		//						printf("\nINPUT %d: %s\n", size, input_data);

		//						printf("\nOUTPUT: %s\n", output_data);

		// это команда на создание записи авторизации

		char* result_id = strstr(output_data, result_data_header.ptr);
		if(result_id !is null)
			result_id += result_data_header.length;

		//				printf("\nresult_id: %s\n", result_id);
		//				log.trace("#i1-1 result_id = {}", result_id);

		int size_id = strlen(result_id) - 2;
		//		log.trace("#i1-2");
		char[] result_id_text = result_id[0 .. size_id];
		//		log.trace("#i1-3");
		char[] qqq = input_data[0 .. size];
		//		log.trace("#i1-4");

		//		auto rr = Regex(result_id_text).replaceAll ("<>", "<" ~ result_id_text ~ ">");
		//		printf("\nresult: %s\n", rr.ptr);

		auto input_data_text = new Text!(char)(qqq);
		//		while(strstr(input_data_text.toString().ptr, "<>") !is null)
		//		{
		input_data_text.search("{<>").next; //???
		input_data_text.replace("{<><" ~ NEW_UID ~ ">\"" ~ result_id_text ~ "\".<>");
		//		}
		//		log.trace("#i1-5");

		input_data = toStringz(input_data_text.toString());
		size = strlen(input_data);

		//				printf("\nresult: %s\n", input_data);
		//		log.trace("#i2");
	}

	if(count_commands % 100 == 0)
	{
		Stdout.format("\r\nautotest: count messages {}", count_commands).newline;
	}

	if(stop_on_next_command == true)
		throw new Exception("out messages not compare with original");

	log.trace("message:{}", count_commands);
	message_acceptor(cast(byte*) input_data, size, im);
	count_commands++;
}
