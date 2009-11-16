module server;

private import tango.core.Thread;
private import tango.io.Console;
private import tango.stdc.string;
private import tango.stdc.stdlib;
private import tango.stdc.posix.stdio;
private import tango.stdc.stringz;
private import Log;

private import tango.io.FileScan;
private import tango.io.FileConduit;
private import tango.io.stream.MapStream;

private import Integer = tango.text.convert.Integer;

private import tango.io.Stdout;
private import Text = tango.text.Util;
private import tango.time.StopWatch;
private import tango.time.WallClock;
private import tango.time.Clock;

private import HashMap;
private import TripleStorage;
private import authorization;

private import mom_client;
private import librabbitmq_client;
private import script_util;
private import RightTypeDef;
private import fact_tools;
private import tango.text.locale.Locale;
//private import tango.text.convert.Integer;

private import autotest;

private mom_client client = null;

private Authorization az = null;

private char* result_buffer = null;
private char* queue_name = null;
private char* user = null;

private bool logging_io_messages = true;
private Locale layout;

void main(char[][] args)
{
	char[] autotest_file = null;
        long count_repeat = 1;
        bool nocompare = false;

	if(args.length > 0)
	{
		for(int i = 0; i < args.length; i++)
		{
			if(args[i] == "-autotest" || args[i] == "-a")
			{
				log.trace("autotest mode");
				autotest_file = args[i + 1];
				log.trace("autotest file = {}", autotest_file);
			}
			if(args[i] == "-repeat" || args[i] == "-r")
			{
				count_repeat = atoll (toStringz (args[i + 1]));				
				log.trace("repeat = {}", count_repeat);
			}
			if(args[i] == "-nocompare" || args[i] == "-n")
			{
				nocompare = true;
				log.trace("no compare");
			}
		}
	}

	result_buffer = cast(char*) new char[200 * 1024];
	queue_name = cast(char*) (new char[40]);
	user = cast(char*) (new char[40]);

	if(autotest_file is null)
	{
		char[][char[]] props = load_props();
		char[] hostname = props["amqp_server_address"] ~ "\0";
		int port = atoi((props["amqp_server_port"] ~ "\0").ptr);
		char[] vhost = props["amqp_server_vhost"] ~ "\0";
		char[] login = props["amqp_server_login"] ~ "\0";
		char[] passw = props["amqp_server_password"] ~ "\0";
		char[] queue = props["amqp_server_queue"] ~ "\0";

		log.trace("connect to AMQP server ({}:{} vhost={}, queue={})", hostname, port, vhost, queue);
		client = new librabbitmq_client(hostname, port, login, passw, queue, vhost);
		client.set_callback(&get_message);
	}
	else
	{
		log.trace("use direct send command");
		client = new autotest(autotest_file, count_repeat, nocompare);
		client.set_callback(&get_message);
	}

	layout = new Locale;

	az = new Authorization();

	(new Thread(&client.listener)).start;
	Thread.sleep(0.250);
}

void send_result_and_logging_messages(char* queue_name, char* result_buffer)
{
	auto elapsed = new StopWatch();
	double time;

	log.trace("queue_name:{}", getString(queue_name));
	elapsed.start;
	client.send(queue_name, result_buffer);

	time = elapsed.stop;
	log.trace("send result time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);

	if(logging_io_messages)
	{
		elapsed.start;

		auto tm = WallClock.now;
		auto dt = Clock.toDate(tm);
		File.append("io_messages.log", layout("{:yyyy-MM-dd HH:mm:ss},{} OUTPUT\r\n", tm, dt.time.millis));
		File.append("io_messages.log", fromStringz(result_buffer));
		File.append("io_messages.log", "\r\n\r\n\r\n");

		time = elapsed.stop;
		log.trace("logging output message, time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
	}
}

void get_message(byte* message, ulong message_size)
{
	//	printf ("\nget message !%s!\n", message);

	synchronized
	{
		if(*(message + message_size - 1) != '.')
		{
			log.trace("invalid message");
			return;
		}

		*(message + message_size) = 0;

		auto elapsed = new StopWatch();
		auto time_calculate_right = new StopWatch();
		double time;

		if(logging_io_messages == true)
		{
			elapsed.start;
			char[] message_buffer = fromStringz(cast(char*) message);
			auto tm = WallClock.now;
			auto dt = Clock.toDate(tm);
			File.append("io_messages.log", layout("{:yyyy-MM-dd HH:mm:ss},{} INPUT\r\n", tm, dt.time.millis));
			File.append("io_messages.log", message_buffer);
			File.append("io_messages.log", "\r\n\r\n");
			time = elapsed.stop;
			log.trace("logging input message, time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
		}

		elapsed.start;

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
			log.trace("разбор сообщения");

			Counts count_elements = calculate_count_facts(cast(char*) message, message_size);
			fact_s = new char*[count_elements.facts];
			fact_p = new char*[count_elements.facts];
			fact_o = new char*[count_elements.facts];
			is_fact_in_object = new uint[count_elements.facts];

			uint count_facts = extract_facts_from_message(cast(char*) message, message_size, count_elements, fact_s, fact_p, fact_o,
					is_fact_in_object);

			// 				
			// замапим предикаты фактов на конкретные переменные put_id, arg_id
			int delete_subjects_id = -1;
			int get_id = -1;
			int put_id = -1;
			int delete_subjects_by_predicate_id = -1;
			int arg_id = -1;
			int get_authorization_rights_records_id = -1;
			int add_delegates_id = -1;
			int get_delegate_assigners_tree_id = -1;
			int agent_function_id = -1;
			int create_id = -1;

			for(int i = 0; i < count_facts; i++)
			{
				//				log.trace("look triple <{}><{}><{}>", getString(cast(char*) fact_s[i]), toString(
				//						cast(char*) fact_p[i]), getString(cast(char*) fact_o[i]));

				if(put_id < 0 && strcmp(fact_o[i], "magnet-ontology#put") == 0 && strcmp(fact_p[i], "magnet-ontology#subject") == 0)
				{
					put_id = i;
					//					Stdout.format("found comand {}, id ={} ", getString(fact_o[i]), i);
				}
				else
				{
					if(arg_id < 0 && strcmp(fact_p[i], "magnet-ontology/transport#argument") == 0)
					{
						arg_id = i;
						//						Stdout.format("found comand {}, id ={} ", getString(fact_p[i]), i);
					}
					else
					{
						if(delete_subjects_by_predicate_id < 0 && strcmp(fact_o[i], "magnet-ontology#delete_subjects_by_predicate") == 0 && strcmp(
								fact_p[i], "magnet-ontology#subject") == 0)
						{
							delete_subjects_by_predicate_id = i;
							//							Stdout.format("found comand {}, id ={} ", getString(fact_o[i]), i);
						}
						else
						{
							if(get_id < 0 && strcmp(fact_o[i], "magnet-ontology#get") == 0 && strcmp(fact_p[i], "magnet-ontology#subject") == 0)
							{
								get_id = i;
								Stdout.format("found comand {}, id ={} ", getString(fact_o[i]), i);
							}
							else
							{
								if(delete_subjects_id < 0 && strcmp(fact_o[i], "magnet-ontology#delete_subjects") == 0 && strcmp(fact_p[i],
										"magnet-ontology#subject") == 0)
								{
									delete_subjects_id = i;
									log.trace("found comand {}, id ={} ", getString(fact_o[i]), i);
								}
								else
								{
									if(get_id < 0 && strcmp(fact_o[i], "magnet-ontology/authorization/functions#get_authorization_rights_records") == 0 && strcmp(
											fact_p[i], "magnet-ontology#subject") == 0)
									{
										get_authorization_rights_records_id = i;
										//log.trace("found comand {}, id ={} ", getString(fact_o[i]), i);
									}
									else
									{
										if(add_delegates_id < 0 && strcmp(fact_o[i], "magnet-ontology/authorization/functions#add_delegates") == 0 && strcmp(
												fact_p[i], "magnet-ontology#subject") == 0)
										{
											add_delegates_id = i;
											//log.trace("found comand {}, id ={} ", getString(fact_o[i]), i);
										}
										else
										{
											if(get_delegate_assigners_tree_id < 0 && strcmp(fact_o[i],
													"magnet-ontology/authorization/functions#get_delegate_assigners_tree") == 0 && strcmp(fact_p[i],
													"magnet-ontology#subject") == 0)
											{
												get_delegate_assigners_tree_id = i;
												//log.trace("found comand {}, id ={} ", getString(fact_o[i]), i);
											}
											else
											{
												if(put_id < 0 && strcmp(fact_o[i], "magnet-ontology#agent_function") == 0 && strcmp(fact_p[i],
														"magnet-ontology#subject") == 0)
												{
													agent_function_id = i;
												}
												else
												{
													if(put_id < 0 && strcmp(fact_o[i], "magnet-ontology/authorization/functions#create") == 0 && strcmp(
															fact_p[i], "magnet-ontology#subject") == 0)
													{
														create_id = i;
														put_id = i;
													}
												}

											}

										}
									}
								}
							}
						}
					}

				}

			}

			log.trace("разбор сообщения закончен");

			if(agent_function_id >= 0 && arg_id > 0)
			{
				/* пример сообщения: установить в модуле trioplax флаг set_stat_info_logging = true
				 
				 <2014a><magnet-ontology#subject><magnet-ontology#agent_function>.
				 <2014a><magnet-ontology/transport#argument>
				 {<trioplax><set_stat_info_logging>"true".}.
				 <85f3><magnet-ontology#subject><magnet-ontology/transport#set_from>.
				 <85f3><magnet-ontology/transport#argument>"2014a".
				 <2014a><magnet-ontology/transport/message#reply_to>"client-2014a".  
				 */
				int i = 0;
				for(; i < count_facts; i++)
				{
					if(is_fact_in_object[i] == arg_id)
						break;
				}
				log.trace("agent_function s = {} , p = {} , o = {}", getString(fact_s[i]), getString(fact_p[i]), getString(fact_o[i]));

				if(strcmp(fact_s[i], "trioplax") == 0 && strcmp(fact_p[i], "set_stat_info_logging"))
				{
					if(strcmp(fact_o[i], "true") == 0)
						az.getTripleStorage.set_stat_info_logging(true);
					else
						az.getTripleStorage.set_stat_info_logging(false);
				}
				if(strcmp(fact_s[i], "semargl") == 0 && strcmp(fact_p[i], "set_logging_io_messages"))
				{
					if(strcmp(fact_o[i], "true") == 0)
						logging_io_messages = true;
					else
						logging_io_messages = false;
				}
			}

			if(get_id >= 0 && arg_id > 0)
			{
				/* пример сообщения: запрос всех фактов с p=predicate1 и o=object1
				 
				 <2014a><magnet-ontology#subject><magnet-ontology#get>.
				 <2014a><magnet-ontology/transport#argument>
				 {<><predicate1>"object1".}.
				 <85f3><magnet-ontology#subject><magnet-ontology/transport#set_from>.
				 <85f3><magnet-ontology/transport#argument>"2014a".
				 <2014a><magnet-ontology/transport/message#reply_to>"client-2014a".  
				 */

				int reply_to_id = 0;
				for(int i = 0; i < count_facts; i++)
				{
					if(strlen(fact_o[i]) > 0)
					{
						if(strcmp(fact_p[i], "magnet-ontology/transport/message#reply_to") == 0)
						{
							reply_to_id = i;
						}
					}
				}

				int i = 0;
				for(; i < count_facts; i++)
				{
					if(is_fact_in_object[i] == arg_id)
						break;
				}

				//log.trace("function get: query={} ", getString(fact_o[arg_id]));
				log.trace("query s = {} , p = {} , o = {}", getString(fact_s[i]), getString(fact_p[i]), getString(fact_o[i]));

				char* ss = strlen(fact_s[i]) == 0 ? null : fact_s[i];
				char* pp = strlen(fact_p[i]) == 0 ? null : fact_p[i];
				char* oo = strlen(fact_o[i]) == 0 ? null : fact_o[i];

				uint* list_facts = az.getTripleStorage.getTriples(ss, pp, oo);
				//				uint* list_facts = az.getTripleStorage.getTriples(fact_s[i], fact_p[i], fact_o[i], false);

				char* result_ptr = cast(char*) result_buffer;
				char* command_uid = fact_s[0];

				*result_ptr = '<';
				strcpy(result_ptr + 1, command_uid);
				result_ptr += strlen(command_uid) + 1;
				strcpy(result_ptr, "><magnet-ontology/transport#result:data>\"");
				result_ptr += 41;

				if(list_facts !is null)
				{
					uint next_element1 = 0xFF;
					while(next_element1 > 0)
					{
						byte* triple = cast(byte*) *list_facts;
						//						log.trace("list_fact {:X4}", list_facts);
						if(triple !is null)
						{
							char* s = cast(char*) triple + 6;

							char* p = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1);

							char* o = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1 + (*(triple + 2) << 8) + *(triple + 3) + 1);

							//log.trace("get result: <{}><{}><{}>", getString(s), getString(p), getString(o));

							strcpy(result_ptr++, "<");
							strcpy(result_ptr, s);
							result_ptr += strlen(s);
							strcpy(result_ptr, "><");
							result_ptr += 2;
							strcpy(result_ptr, p);
							result_ptr += strlen(p);
							strcpy(result_ptr, "><");
							result_ptr += 2;
							strcpy(result_ptr, o);
							result_ptr += strlen(o);
							strcpy(result_ptr, ">.");
							result_ptr += 2;
						}
						next_element1 = *(list_facts + 1);
						list_facts = cast(uint*) next_element1;
					}
				}

				time = elapsed.stop;
				log.trace("get triples time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);

				strcpy(result_ptr, "\".<");
				result_ptr += 3;
				strcpy(result_ptr, command_uid);
				result_ptr += strlen(command_uid);
				strcpy(result_ptr, "><magnet-ontology/transport#result:state>\"ok\".");
				result_ptr += 46;

				strcpy(queue_name, fact_o[reply_to_id]);

				send_result_and_logging_messages(queue_name, result_buffer);
			}

			if(delete_subjects_id >= 0 && arg_id > 0)
			{
				log.trace("команда на удаление всех фактов у которых субьект, s={}", getString(fact_o[arg_id]));

				int reply_to_id = 0;
				for(int i = 0; i < count_facts; i++)
				{
					if(strlen(fact_o[i]) > 0)
					{
						if(strcmp(fact_p[i], "magnet-ontology/transport/message#reply_to") == 0)
						{
							reply_to_id = i;
						}
					}
				}

				uint* removed_facts = az.getTripleStorage.getTriples(fact_o[arg_id], null, null);

				if(removed_facts !is null)
				{
					uint next_element1 = 0xFF;
					while(next_element1 > 0)
					{
						byte* triple = cast(byte*) *removed_facts;

						if(triple !is null)
						{

							char* s = cast(char*) triple + 6;

							char* p = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1);

							char* o = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1 + (*(triple + 2) << 8) + *(triple + 3) + 1);

							log.trace("remove triple <{}><{}><{}>", getString(s), getString(p), getString(o));

							az.getTripleStorage.removeTriple(getString(s), getString(p), getString(o));
							az.logginTriple('D', getString(s), getString(p), getString(o));

						}

						next_element1 = *(removed_facts + 1);
						removed_facts = cast(uint*) next_element1;
					}

				}

				char* result_ptr = cast(char*) result_buffer;
				char* command_uid = fact_s[0];

				*result_ptr = '<';
				strcpy(result_ptr + 1, command_uid);
				result_ptr += strlen(command_uid) + 1;
				strcpy(result_ptr, "><magnet-ontology/transport#result:state>\"ok\".\0");
				result_ptr += 47;

				strcpy(queue_name, fact_o[reply_to_id]);

				send_result_and_logging_messages(queue_name, result_buffer);
			}

			if(delete_subjects_by_predicate_id >= 0 && arg_id > 0)
			{
				char* arg_p;
				char* arg_o;

				for(ubyte i = 0; i < count_facts; i++)
				{
					if(is_fact_in_object[i] == arg_id)
					{
						arg_p = fact_p[i];
						arg_o = fact_o[i];
						break;
					}
				}

				log.trace("команда на удаление всех фактов у найденных субьектов по заданному предикату (при p={} o={})", getString(arg_p),
						getString(arg_o));

				uint* removed_subjects = az.getTripleStorage.getTriples(null, arg_p, arg_o);

				if(removed_subjects !is null)
				{
					uint next_element0 = 0xFF;
					while(next_element0 > 0)
					{
						byte* triple = cast(byte*) *removed_subjects;

						if(triple !is null)
						{

							char* s = cast(char*) triple + 6;
							log.trace("removed_subjects <{}>", getString(s));

							uint* removed_facts = az.getTripleStorage.getTriples(s, null, null);

							if(removed_facts !is null)
							{
								uint next_element1 = 0xFF;
								while(next_element1 > 0)
								{
									triple = cast(byte*) *removed_facts;

									if(triple !is null)
									{

										s = cast(char*) triple + 6;

										char* p = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1);

										char*
												o = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1 + (*(triple + 2) << 8) + *(triple + 3) + 1);

										log.trace("remove triple <{}><{}><{}>", getString(s), getString(p), getString(o));

										az.getTripleStorage.removeTriple(getString(s), getString(p), getString(o));
										az.logginTriple('D', getString(s), getString(p), getString(o));

									}

									next_element1 = *(removed_facts + 1);
									removed_facts = cast(uint*) next_element1;
								}

							}
						}
						next_element0 = *(removed_subjects + 1);
						removed_subjects = cast(uint*) next_element0;
					}
				}

				time = elapsed.stop;
				log.trace("remove triples time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
			}

			// GET_AUTHORIZATION_RIGHTS_RECORDS
			if(get_authorization_rights_records_id >= 0 && arg_id > 0)
			{
				az.getAuthorizationRightRecords(fact_s, fact_p, fact_o, count_facts, result_buffer);//, client);
			}

			// PUT
			if(put_id >= 0 && arg_id > 0)
			{
				log.trace("команда на добавление");

				int reply_to_id = 0;

				char* uuid = cast(char*) new char[16];
				longToHex(getUUID(), uuid);

				// найдем триплет с elementId
				int element_id = -1;
				for(int i = 0; i < count_facts; i++)
				{
					if(strcmp("magnet-ontology/authorization/acl#elementId", fact_p[i]) == 0)
					{
						element_id = i;
						break;
					}
				}

				// проверим есть ли такая запись в хранилище
				bool is_exists = false;
				if(create_id >= 0 && strlen(fact_o[element_id]) > 0)
				{
					is_exists = true;
					if(element_id >= 0)
					{
						//log.trace("check for elementId = {}", getString(fact_o[element_id]));
						uint* founded_facts = az.getTripleStorage.getTriples(null, "magnet-ontology/authorization/acl#elementId", fact_o[element_id]);
						if(founded_facts !is null)
						{
							bool is_exists_not_null = false;
							uint next_element = 0xFF;
							while(next_element > 0 && is_exists)
							{
								byte* triple = cast(byte*) *founded_facts;
								if(triple !is null)
								{
									is_exists_not_null = true;
									char* s = cast(char*) triple + 6;
									log.trace("check right record with subject = {}", getString(s));
									for(int i = 0; i < count_facts; i++)
									{
										if(i != element_id && is_fact_in_object[i] == arg_id)
										{
											//log.trace("check for existance <{}> <{}> <{}>", getString(s), getString(fact_p[i]), 
											//  getString(fact_o[i]));
											uint* founded_facts2 = az.getTripleStorage.getTriples(s, fact_p[i], fact_o[i]);
											if(founded_facts2 is null)
											{
												// log.trace("#444");
												is_exists = false;
												break;
											}
											else
											{
												// log.trace("#555");
												uint next_element2 = 0xFF;
												bool is_exists2 = false;
												while(next_element2 > 0 && is_exists)
												{
													byte* triple2 = cast(byte*) *founded_facts2;
													if(triple2 !is null)
													{
														char*
																o = cast(char*) (triple2 + 6 + (*(triple2 + 0) << 8) + *(triple2 + 1) + 1 + (*(triple2 + 2) << 8) + *(triple2 + 3) + 1);

														if(strcmp(o, fact_o[i]) == 0)
														{
															is_exists2 = true;
															break;
														}

													}
													next_element2 = *(founded_facts2 + 1);
													founded_facts2 = cast(uint*) next_element2;
												}
												// log.trace("#666 {} {}", is_exists, is_exists2);
												is_exists = is_exists2 && is_exists;
											}
										}
									}
									if(is_exists)
									{

										uint* removed_facts = az.getTripleStorage.getTriples(s, null, null);

										if(removed_facts !is null)
										{
											uint next_element1 = 0xFF;
											while(next_element1 > 0)
											{
												byte* triple2 = cast(byte*) *removed_facts;

												if(triple2 !is null)
												{

													char* ss = cast(char*) triple2 + 6;

													char* pp = cast(char*) (triple2 + 6 + (*(triple2 + 0) << 8) + *(triple2 + 1) + 1);

													char*
															oo = cast(char*) (triple2 + 6 + (*(triple2 + 0) << 8) + *(triple2 + 1) + 1 + (*(triple2 + 2) << 8) + *(triple2 + 3) + 1);

													log.trace("remove triple2 <{}><{}><{}>", getString(ss), getString(pp), getString(oo));

													az.getTripleStorage.removeTriple(getString(ss), getString(pp), getString(oo));
													az.logginTriple('D', getString(ss), getString(pp), getString(oo));

												}

												next_element1 = *(removed_facts + 1);
												removed_facts = cast(uint*) next_element1;
											}

										}

									}

								}
								next_element = *(founded_facts + 1);
								founded_facts = cast(uint*) next_element;
							}
							is_exists = is_exists_not_null && is_exists;
						}
						else
						{
							//log.trace("right record with elementId = {} doesn't exists", fact_o[element_id]);
							is_exists = false;
						}
					}
					else
					{
						//log.trace("elementId isn't present");
					}

					log.trace("is_exists = {}", is_exists);
				}

				for(int i = 0; i < count_facts; i++)
				{
					if(strcmp(fact_p[i], "magnet-ontology/transport/message#reply_to") == 0)
					{
						reply_to_id = i;
					}
					else if(is_fact_in_object[i] == arg_id)
					{
						if(strlen(fact_s[i]) == 0)
							fact_s[i] = uuid;
						else
							uuid = fact_s[i];

						try
						{
							log.trace("add triple <{}><{}><{}>", getString(cast(char*) fact_s[i]), getString(cast(char*) fact_p[i]), getString(
									cast(char*) fact_o[i]));
							az.getTripleStorage.addTriple(getString(fact_s[i]), getString(fact_p[i]), getString(fact_o[i]));
							az.logginTriple('A', getString(fact_s[i]), getString(fact_p[i]), getString(fact_o[i]));
						}
						catch(Exception ex)
						{
							log.trace("faled command add triple <{}><{}><{}>", getString(cast(char*) fact_s[i]), getString(cast(char*) fact_p[i]),
									getString(cast(char*) fact_o[i]));
						}
					}
				}

				time = elapsed.stop;
				log.trace("add triple time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);

				char* result_ptr = cast(char*) result_buffer;
				char* command_uid = fact_s[0];

				*result_ptr = '<';
				strcpy(result_ptr + 1, command_uid);
				result_ptr += strlen(command_uid) + 1;
				strcpy(result_ptr, "><magnet-ontology/transport#result:state>\"ok");
				result_ptr += 44;

				if(uuid !is null)
				{
					strcpy(result_ptr, "\".<");
					result_ptr += 3;
					strcpy(result_ptr, command_uid);
					result_ptr += strlen(command_uid);
					strcpy(result_ptr, "><magnet-ontology/transport#result:data>\"");
					result_ptr += 41;
					strcpy(result_ptr, uuid);
					result_ptr += 16;
				}

				strcpy(result_ptr, "\".\0");

				strcpy(queue_name, fact_o[reply_to_id]);

				send_result_and_logging_messages(queue_name, result_buffer);
			}

			// GET_DELEGATE_ASSIGNERS
			if(get_delegate_assigners_tree_id >= 0 && arg_id > 0)
			{
				az.getDelegateAssignersTree(fact_s, fact_p, fact_o, arg_id, count_facts, result_buffer);//, client);
			}
			//			log.trace("# fact_p[0]={}, fact_o[0]={}", getString(fact_p[0]), getString(fact_o[0]));

			// AUTHORIZE
			if(strcmp(fact_o[0], "magnet-ontology/authorization/functions#authorize") == 0 && strcmp(fact_p[0], "magnet-ontology#subject") == 0)
			{
				log.trace("function authorize");

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

				char* command_uid = null;

				int authorize_id = 0;
				int from_id = 0;
				int right_id = 0;
				int category_id = 0;
				int targetId_id = 0;
				int elements_id = 0;
				int reply_to_id = 0;
				command_uid = fact_s[0];

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

				char*[] hierarhical_delegates = null;
				hierarhical_delegates = getDelegateAssignersTreeArray(user, az.getTripleStorage());

				char*[][] hierarhical_departments_of_delegate = new char*[][hierarhical_delegates.length];
				for(int ii = 0; ii < hierarhical_delegates.length; ii++)
				{
					hierarhical_departments_of_delegate[ii] = getDepartmentTreePathOfUser(hierarhical_delegates[ii], az.getTripleStorage());
				}

				char*[] hierarhical_departments = null;
				hierarhical_departments = getDepartmentTreePathOfUser(user, az.getTripleStorage());
				// log.trace("function authorize: calculate department tree for this target, count={}", hierarhical_departments.length);

				uint count_prepared_elements = 0;
				uint count_authorized_doc = 0;
				uint doc_pos = 0;
				uint prev_doc_pos = 0;

				//	log.trace("this request on authorization #1.1.1 {}, command_uid={}, command_len={}", targetRightType, getString (command_uid), strlen(command_uid));

				*result_ptr = '<';
				strcpy(result_ptr + 1, command_uid);
				result_ptr += strlen(command_uid) + 1;
				strcpy(result_ptr, "><magnet-ontology/transport#result:data>\"");
				result_ptr += 41;

				time_calculate_right.start;

				log.trace("function authorize: repair all elementIds");

				for(uint i = 0; true; i++)
				{
					//log.trace("#1");

					char prev_state_byte = *(autz_elements + i);

					//					log.trace("this request on authorization #1.2, {} {}", i, *(autz_elements + i));

					if(*(autz_elements + i) == ',' || *(autz_elements + i) == 0)
					{

						//log.trace("#2");

						*(autz_elements + i) = 0;

						//log.trace("#21");

						docId = cast(char*) (autz_elements + doc_pos);

						//log.trace("#22");

						count_prepared_elements++;
						bool calculatedRight;
						calculatedRight = az.authorize(fact_o[category_id], docId, user, targetRightType, hierarhical_departments);
						//log.trace("right = {}", calculatedRight);

						//log.trace("#23");

						if(calculatedRight == false)
						{
							for(int ii = 0; ii < hierarhical_delegates.length; ii++)
							{
								//log.trace("#3");
								calculatedRight = az.authorize(fact_o[category_id], docId, hierarhical_delegates[ii], targetRightType,
										hierarhical_departments_of_delegate[ii]);
								if(calculatedRight == true)
									break;
							}
						}

						//log.trace("#4");

						if(calculatedRight == false)
						{
							// вычислим права для найденных делегатов
						}

						if(calculatedRight == true)
						{
							if(count_prepared_elements > 1)
							{
								*result_ptr = ',';
								result_ptr++;
							}

							while(*docId != 0)
								*result_ptr++ = *docId++;

							//							strcpy(result_ptr, docId);
							//							result_ptr += strlen(docId);

							//log.trace("#5");

							//						//log.trace("this request on authorization #1.4 true");
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
					//log.trace("#6");
				}

				//log.trace("#7");

				double total_time_calculate_right = time_calculate_right.stop;

				strcpy(result_ptr, "\".<");
				result_ptr += 3;
				strcpy(result_ptr, command_uid);
				result_ptr += strlen(command_uid);
				strcpy(result_ptr, "><magnet-ontology/transport#result:state>\"ok\".\0");
				result_ptr += 47;

				time = elapsed.stop;

				log.trace("count auth in count docs={}, authorized count docs={}", count_prepared_elements, count_authorized_doc);

				log.trace("total time = {:d6} ms. ( {:d6} sec.), cps={}", time * 1000, time, count_prepared_elements / time);

				log.trace("time calculate right = {:d6} ms. ( {:d6} sec.), cps={}", total_time_calculate_right * 1000, total_time_calculate_right,
						count_prepared_elements / total_time_calculate_right);

				send_result_and_logging_messages(queue_name, result_buffer);
			}
		}

		//	printf("!!!! queue_name=%s\n", queue_name);
		//	log.trace("!!!! check_right={}", check_right);
		//	printf("!!!! list_docid=%s\n", list_docid);

		//	log.trace("\nIN: list_docid={}", str_2_char_array(cast(char*) list_docid, doclistid_length));

		log.trace("message successful prepared\r\n");
	}

}

// Loads server properties
private char[][char[]] load_props()
{
	char[][char[]] result;
	FileConduit props_conduit;

	auto props_path = new FilePath("./semargl.properties");

	if(!props_path.exists)
	// props file doesn't exists, so create new one with defaults
	{
		result["amqp_server_address"] = "localhost";
		result["amqp_server_port"] = "5672";
		result["amqp_server_exchange"] = "";
		result["amqp_server_login"] = "ba";
		result["amqp_server_password"] = "123456";
		result["amqp_server_routingkey"] = "";
		result["amqp_server_queue"] = "semargl";
		result["amqp_server_vhost"] = "magnetico";

		props_conduit = new FileConduit(props_path.toString(), FileConduit.ReadWriteCreate);
		auto output = new MapOutput!(char)(props_conduit.output);

		output.append(result);
		output.flush;
		props_conduit.close;
	}
	else
	{
		props_conduit = new FileConduit(props_path.toString(), FileConduit.ReadExisting);
		auto input = new MapInput!(char)(props_conduit.input);
		result = result.init;
		input.load(result);
		props_conduit.close;
	}

	return result;
}
