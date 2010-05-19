module server;

private import Predicates;

private import tango.core.Thread;
private import tango.io.Console;
private import tango.stdc.string;
private import tango.stdc.stdlib;
private import tango.stdc.stdio;
private import tango.stdc.stringz;
private import Log;

private import tango.io.device.File;
private import tango.io.FileScan;
private import tango.io.FileConduit;
private import tango.io.stream.MapStream;

private import Integer = tango.text.convert.Integer;

private import tango.io.Stdout;
private import Text = tango.text.Util;
private import tango.time.StopWatch;
private import tango.time.WallClock;
private import tango.time.Clock;

private import triple;
private import TripleStorage;
private import authorization;

private import mom_client;
private import librabbitmq_client;
// private import libdbus_client;
private import autotest;

private import script_util;
private import RightTypeDef;
private import fact_tools;
private import tango.text.locale.Locale;

private Authorization az = null;
public char[][char[]] props;

private char* result_buffer = null;
private char* queue_name = null;
private char* user = null;

private bool logging_io_messages = true;
private Locale layout;

File file;

void main(char[][] args)
{
	char[] autotest_file = null;
	long count_repeat = 1;
	bool nocompare = false;
	bool log_query = false;

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
				count_repeat = atoll(toStringz(args[i + 1]));
				log.trace("repeat = {}", count_repeat);
			}
			if(args[i] == "-nocompare" || args[i] == "-n")
			{
				nocompare = true;
				log.trace("no compare");
			}
			if(args[i] == "-log_query" || args[i] == "-q")
			{
				log_query = true;
				log.trace("log query mode");
			}
		}
	}

	layout = new Locale;

	result_buffer = cast(char*) new char[1024 * 1024];
	queue_name = cast(char*) (new char[40]);
	user = cast(char*) (new char[40]);

	props = load_props();

	az = new Authorization(props);

	if(log_query)
		az.getTripleStorage().log_query = true;

	if(autotest_file is null)
	{
		log.trace("no autotest mode");

		char[] hostname = props["amqp_server_address"] ~ "\0";

		if(hostname.length > 2)
		{
			int port = atoi((props["amqp_server_port"] ~ "\0").ptr);
			char[] vhost = props["amqp_server_vhost"] ~ "\0";
			char[] login = props["amqp_server_login"] ~ "\0";
			char[] passw = props["amqp_server_password"] ~ "\0";
			char[] queue = props["amqp_server_queue"] ~ "\0";

			log.trace("connect to AMQP server ({}:{} vhost={}, queue={})", hostname, port, vhost, queue);

			mom_client client = null;

			client = new librabbitmq_client(hostname, port, login, passw, queue, vhost);
			client.set_callback(&get_message);

			Thread thread = new Thread(&client.listener);
			thread.start;
			Thread.sleep(0.250);

			log.trace("start new Thread {:X4}", &thread);
		}

		/*
		 char[] dbus_semargl_service_name = props["dbus_semargl_service_name"];
		 if(dbus_semargl_service_name !is null && dbus_semargl_service_name.length > 1)
		 {
		 log.trace("connect to DBUS, service name = {}", dbus_semargl_service_name);

		 mom_client client = null;

		 client = new libdbus_client();

		 (cast(libdbus_client) client).setServiceName(dbus_semargl_service_name);
		 (cast(libdbus_client) client).setListenFrom(props["dbus_semargl_listen_from"]);

		 (cast(libdbus_client) client).connect();

		 client.set_callback(&get_message);

		 Thread thread = new Thread(&client.listener);
		 thread.start;
		 Thread.sleep(0.250);

		 log.trace("start new Thread {:X4}", &thread);
		 }
		 */

	} else
	{
		log.trace("use direct send command");
		mom_client client = null;

		client = new autotest(autotest_file, count_repeat, nocompare);
		client.set_callback(&get_message);

		(new Thread(&client.listener)).start;
		Thread.sleep(0.250);
	}
	
	//@@@
//	Thread.sleep(25);
}

void send_result_and_logging_messages(char* queue_name, char* result_buffer, mom_client from_client)
{
	auto elapsed = new StopWatch();
	double time;

	log.trace("send to queue {}", fromStringz(queue_name));
	elapsed.start;
	from_client.send(queue_name, result_buffer);

	time = elapsed.stop;
	log.trace("send result time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);

	if(logging_io_messages)
	{
		elapsed.start;

		auto tm = WallClock.now;
		auto dt = Clock.toDate(tm);
		writeToLog(layout("{:yyyy-MM-dd HH:mm:ss},{} OUTPUT\r\n", tm, dt.time.millis));
		writeToLog(fromStringz(result_buffer));

		time = elapsed.stop;
		log.trace("logging output message, time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
	}
}

void get_message(byte* message, ulong message_size, mom_client from_client)
{
	char* msg = cast(char*) message;
	//		log.trace("get message {}", msg[0 .. message_size]);
	//		printf ("\nget message !%s!\n", message);

	try
	{
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

				writeToLog(layout("{:yyyy-MM-dd HH:mm:ss},{} INPUT\r\n", tm, dt.time.millis));
				writeToLog(message_buffer);
				writeToLog("\r\n\r\n");
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

				uint count_facts = extract_facts_from_message(cast(char*) message, message_size, count_elements,
						fact_s, fact_p, fact_o, is_fact_in_object);

				// 				
				// замапим предикаты фактов на конкретные переменные put_id, arg_id
				int authorization_id = -1;
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
					//log.trace("look triple <{}><{}><{}>", getString(cast(char*) fact_s[i]), 
					//  getString( cast(char*) fact_p[i]), getString(cast(char*) fact_o[i]));

					if(strcmp(fact_p[i], SUBJECT.ptr) == 0)
					{
						//log.trace("#1");

						if(authorization_id < 0 && strcmp(fact_o[i], AUTHORIZE.ptr) == 0)
						{
							//log.trace("#2");
							authorization_id = i;
							log.trace("found comand {}, id ={} ", getString(fact_o[i]), i);
						} else if(put_id < 0 && strcmp(fact_o[i], PUT.ptr) == 0)
						{
							put_id = i;
							log.trace("found comand {}, id ={} ", getString(fact_o[i]), i);
						} else if(delete_subjects_by_predicate_id < 0 && strcmp(fact_o[i],
								DELETE_SUBJECTS_BY_PREDICATE.ptr) == 0)
						{
							delete_subjects_by_predicate_id = i;
							log.trace("found comand {}, id ={} ", getString(fact_o[i]), i);
						} else if(get_id < 0 && strcmp(fact_o[i], GET.ptr) == 0)
						{
							get_id = i;
							log.trace("found comand {}, id ={} ", getString(fact_o[i]), i);
						} else if(delete_subjects_id < 0 && strcmp(fact_o[i], DELETE_SUBJECTS.ptr) == 0)
						{
							delete_subjects_id = i;
							log.trace("found comand {}, id ={} ", getString(fact_o[i]), i);
						} else if(get_delegate_assigners_tree_id < 0 && strcmp(fact_o[i],
								GET_DELEGATE_ASSIGNERS_TREE.ptr) == 0)
						{
							get_delegate_assigners_tree_id = i;
							log.trace("found comand {}, id ={} ", getString(fact_o[i]), i);
						} else if(get_id < 0 && strcmp(fact_o[i], GET_AUTHORIZATION_RIGHT_RECORDS.ptr) == 0)
						{
							get_authorization_rights_records_id = i;
							log.trace("found comand {}, id ={} ", getString(fact_o[i]), i);
						} else if(put_id < 0 && strcmp(fact_o[i], "magnet-ontology#agent_function") == 0)
						{
							agent_function_id = i;
						} else if(put_id < 0 && strcmp(fact_o[i], CREATE.ptr) == 0)
						{
							log.trace("found tag {}, id ={} ", getString(fact_o[i]), i);
							create_id = i;
							put_id = i;
						}

					} else if(arg_id < 0 && strcmp(fact_p[i], FUNCTION_ARGUMENT.ptr) == 0)
					{
						arg_id = i;
						log.trace("found tag {}, id ={} ", getString(fact_p[i]), i);
					}

				}

				log.trace("разбор сообщения закончен : uid = {}", getString(fact_s[0]));

				bool
						isCommandRecognized = delete_subjects_id > -1 || get_id > -1 || put_id > -1 || delete_subjects_by_predicate_id > -1 || get_authorization_rights_records_id > -1 || add_delegates_id > -1 || get_delegate_assigners_tree_id > -1 || agent_function_id > -1 || create_id > -1 || authorization_id > -1;

				if(!isCommandRecognized)
				{
					log.trace("# unrecognized tag");

					int reply_to_id = 0;
					for(int i = 0; i < count_facts; i++)
					{
						if(strlen(fact_o[i]) > 0)
						{
							if(strcmp(fact_p[i], REPLY_TO.ptr) == 0)
							{
								reply_to_id = i;
							}
						}
					}

					char* result_ptr = cast(char*) result_buffer;
					char* command_uid = fact_s[0];

					*result_ptr = '<';
					strcpy(result_ptr + 1, command_uid);
					result_ptr += strlen(command_uid) + 1;
					strcpy(result_ptr, result_state_err_header.ptr);
					result_ptr += result_state_err_header.length;
					*(result_ptr - 1) = 0;

					strcpy(queue_name, fact_o[reply_to_id]);

					send_result_and_logging_messages(queue_name, result_buffer, from_client);

					return;
				}

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
					log.trace("agent_function s = {}, p = {}, o = {}", getString(fact_s[i]), getString(fact_p[i]),
							getString(fact_o[i]));

					if(strcmp(fact_s[i], "trioplax") == 0 && strcmp(fact_p[i], "set_stat_info_logging") == 0)
					{
						if(strcmp(fact_o[i], "true") == 0)
						{
							log.trace("az.getTripleStorage.set_stat_info_logging(true)");
							az.getTripleStorage.set_stat_info_logging(true);
						} else
							az.getTripleStorage.set_stat_info_logging(false);
					}
					if(strcmp(fact_s[i], "semargl") == 0 && strcmp(fact_p[i], "set_logging_io_messages") == 0)
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
							if(strcmp(fact_p[i], REPLY_TO.ptr) == 0)
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
					log.trace("query s = {}, p = {}, o = {}", getString(fact_s[i]), getString(fact_p[i]), getString(
							fact_o[i]));

					char* ss = strlen(fact_s[i]) == 0 ? null : fact_s[i];
					char* pp = strlen(fact_p[i]) == 0 ? null : fact_p[i];
					char* oo = strlen(fact_o[i]) == 0 ? null : fact_o[i];

					triple_list_element* list_facts = az.getTripleStorage.getTriples(ss, pp, oo);
					triple_list_element* list_facts_FE = list_facts;
					//				uint* list_facts = az.getTripleStorage.getTriples(fact_s[i], fact_p[i], fact_o[i], false);

					char* result_ptr = cast(char*) result_buffer;
					char* command_uid = fact_s[0];

					*result_ptr = '<';
					strcpy(result_ptr + 1, command_uid);
					result_ptr += strlen(command_uid) + 1;
					strcpy(result_ptr, result_data_header.ptr);
					result_ptr += result_data_header.length;

					{
						while(list_facts !is null)
						{
							Triple* triple = list_facts.triple;
							//						log.trace("list_fact {:X4}", list_facts);
							if(triple !is null)
							{
								char* s = cast(char*) triple.s;

								char* p = cast(char*) triple.p;

								char* o = cast(char*) triple.o;

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
							list_facts = list_facts.next_triple_list_element;
						}
						az.getTripleStorage.list_no_longer_required(list_facts_FE);
					}

					time = elapsed.stop;
					log.trace("get triples time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);

					strcpy(result_ptr, "\".<");
					result_ptr += 3;
					strcpy(result_ptr, command_uid);
					result_ptr += strlen(command_uid);
					strcpy(result_ptr, result_state_ok_header.ptr);
					result_ptr += result_state_ok_header.length;
					*(result_ptr - 1) = 0;

					strcpy(queue_name, fact_o[reply_to_id]);

					send_result_and_logging_messages(queue_name, result_buffer, from_client);
				}

				if(delete_subjects_id >= 0 && arg_id > 0)
				{
					log.trace("команда на удаление всех фактов у которых субьект, s={}", getString(fact_o[arg_id]));

					int reply_to_id = 0;
					for(int i = 0; i < count_facts; i++)
					{
						if(strlen(fact_o[i]) > 0)
						{
							if(strcmp(fact_p[i], REPLY_TO.ptr) == 0)
							{
								reply_to_id = i;
							}
						}
					}

					remove_subject(fact_o[arg_id]);

					char* result_ptr = cast(char*) result_buffer;
					char* command_uid = fact_s[0];

					*result_ptr = '<';
					strcpy(result_ptr + 1, command_uid);
					result_ptr += strlen(command_uid) + 1;
					strcpy(result_ptr, result_state_ok_header.ptr);
					result_ptr += result_state_ok_header.length;
					*(result_ptr - 1) = 0;

					strcpy(queue_name, fact_o[reply_to_id]);

					send_result_and_logging_messages(queue_name, result_buffer, from_client);

					//				uint* SET = az.getTripleStorage.getTriples(null, null, "45fd1447ef7a46c9ac08b73cddc776d4");
					//				fact_tools.print_list_triple(SET);
				}

				if(delete_subjects_by_predicate_id >= 0 && arg_id > 0)
				{
					char* arg_p;
					char* arg_o;
					int reply_to_id = 0;

					for(ubyte i = 0; i < count_facts; i++)
					{
						if(is_fact_in_object[i] == arg_id)
						{
							arg_p = fact_p[i];
							arg_o = fact_o[i];
						}

						if(strlen(fact_o[i]) > 0)
						{
							if(strcmp(fact_p[i], REPLY_TO.ptr) == 0)
							{
								reply_to_id = i;
							}
						}

						if(arg_o !is null && reply_to_id != 0)
						{
							break;
						}

					}

					log.trace(
							"команда на удаление всех фактов у найденных субьектов по заданному предикату (при p={} o={})",
							getString(arg_p), getString(arg_o));

					remove_subjects_by_predicate(arg_p, arg_o);

					time = elapsed.stop;
					log.trace("remove triples time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);

					char* result_ptr = cast(char*) result_buffer;
					char* command_uid = fact_s[0];

					*result_ptr = '<';
					strcpy(result_ptr + 1, command_uid);
					result_ptr += strlen(command_uid) + 1;
					strcpy(result_ptr, result_state_ok_header.ptr);
					result_ptr += result_state_ok_header.length;
					*(result_ptr - 1) = 0;

					strcpy(queue_name, fact_o[reply_to_id]);

					send_result_and_logging_messages(queue_name, result_buffer, from_client);
				}

				// GET_AUTHORIZATION_RIGHTS_RECORDS
				if(get_authorization_rights_records_id >= 0 && arg_id > 0)
				{
					az.getAuthorizationRightRecords(fact_s, fact_p, fact_o, count_facts, result_buffer, from_client);
				}

				// PUT
				if(put_id >= 0 && arg_id > 0)
				{
					log.trace("команда на добавление");

					int reply_to_id = 0;
					bool facts_removed = false;

					char* uuid = cast(char*) new char[17];
					longToHex(getUUID(), uuid);

					// найдем триплет с elementId
					int element_id = -1;
					for(int i = 0; i < count_facts; i++)
					{
						if(strcmp(ELEMENT_ID.ptr, fact_p[i]) == 0)
						{
							element_id = i;
							break;
						}
					}

					// проверим есть ли такая запись в хранилище

					if(create_id >= 0 && strlen(fact_o[element_id]) > 0)
					{

						if(element_id >= 0)
						{
							log.trace("check for elementId = {}", getString(fact_o[element_id])); //@@@@

							triple_list_element* founded_facts = az.getTripleStorage.getTriples(null, ELEMENT_ID.ptr,
									fact_o[element_id]);
							triple_list_element* founded_facts_FE = founded_facts;
							{
								bool is_exists_not_null = false;
								while(founded_facts !is null)
								{
									Triple* triple = founded_facts.triple;
									if(triple !is null)
									{
										is_exists_not_null = true;
										char* s = cast(char*) triple.s;

										log.trace("check right record with subject = {}", getString(s)); //@@@@

										bool is_exists = true;
										for(int i = 0; i < count_facts; i++)
										{
											if(i != element_id && is_fact_in_object[i] == arg_id && (strcmp(fact_p[i],
													TARGET_SUBSYSTEM_ELEMENT.ptr) == 0 || strcmp(fact_p[i],
													CATEGORY.ptr) == 0 || strcmp(fact_p[i], AUTHOR_SYSTEM.ptr) == 0) || strcmp(
													fact_p[i], RIGHTS.ptr) == 0)

											{
												log.trace("check for existance <{}> <{}> <{}>", getString(s),
														getString(fact_p[i]), getString(fact_o[i])); //@@@@
												triple_list_element* founded_facts2 = az.getTripleStorage.getTriples(s,
														fact_p[i], fact_o[i]);
												triple_list_element* founded_facts2_FE = founded_facts2;
												if(founded_facts2 is null)
												{
													//log.trace("#444");
													is_exists = false;
													az.getTripleStorage.list_no_longer_required(founded_facts2_FE);
													break;
												} else
												{
													//log.trace("#555");
													bool is_exists2 = false;
													while(founded_facts2 !is null && is_exists)
													{
														Triple* triple2 = founded_facts2.triple;
														if(triple2 !is null)
														{
															char* o = cast(char*) triple2.o;

															if(strcmp(o, fact_o[i]) == 0)
															{
																is_exists2 = true;
																break;
															}

														}
														founded_facts2 = founded_facts2.next_triple_list_element;
													}
													az.getTripleStorage.list_no_longer_required(founded_facts2_FE);
													//log.trace("#666 {} {}", is_exists, is_exists2);
													is_exists = is_exists2 && is_exists;
												}
											}
										}
										if(is_exists)
										{
											facts_removed = true;
											remove_subject(s);
										}

									}
									founded_facts = founded_facts.next_triple_list_element;
								}
								az.getTripleStorage.list_no_longer_required(founded_facts_FE);
							}
						}
					}

					int ext_uid = -1;

					for(int i = 0; i < count_facts; i++)
					{
						if(strcmp(fact_p[i], NEW_UID.ptr) == 0)
						{
							ext_uid = i;
							continue;
						}

						if(strcmp(fact_p[i], REPLY_TO.ptr) == 0)
						{
							reply_to_id = i;
						} else if(is_fact_in_object[i] == arg_id)
						{
							if(ext_uid > 0)
							{
								uuid = fact_o[ext_uid];
							}

							//						if(facts_removed || strlen(fact_s[i]) == 0)
							if(strlen(fact_s[i]) == 0)
								fact_s[i] = uuid;
							else
								uuid = fact_s[i];

							try
							{
								log.trace("add triple <{}><{}>\"{}\"", getString(fact_s[i]), getString(fact_p[i]),
										getString(fact_o[i]));

								az.logginTriple('A', getString(fact_s[i]), getString(fact_p[i]), getString(fact_o[i]));
								try
								{
									az.getTripleStorage.addTriple(getString(fact_s[i]), getString(fact_p[i]),
											getString(fact_o[i]));
								} catch(IndexException ex)
								{
									throw new Exception("message - add triple");
								}
							} catch(Exception ex)
							{
								log.trace("failed command add triple <{}><{}>\"{}\"", getString(cast(char*) fact_s[i]),
										getString(cast(char*) fact_p[i]), getString(cast(char*) fact_o[i]));
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
					strcpy(result_ptr, result_state_ok_header.ptr);
					result_ptr += result_state_ok_header.length - 1;

					if(uuid !is null)
					{
						//					strcpy(result_ptr, "\".<");
						strcpy(result_ptr, "<");
						result_ptr += 1;
						strcpy(result_ptr, command_uid);
						result_ptr += strlen(command_uid);
						strcpy(result_ptr, result_data_header.ptr);
						result_ptr += result_data_header.length;
						strcpy(result_ptr, uuid);
						result_ptr += 16;
					}

					strcpy(result_ptr, "\".\0");

					strcpy(queue_name, fact_o[reply_to_id]);

					send_result_and_logging_messages(queue_name, result_buffer, from_client);

					//				uint* SET = az.getTripleStorage.getTriples(null, null, "45fd1447ef7a46c9ac08b73cddc776d4");
					//				fact_tools.print_list_triple(SET);

				}

				// GET_DELEGATE_ASSIGNERS
				if(get_delegate_assigners_tree_id >= 0 && arg_id > 0)
				{
					az.getDelegateAssignersTree(fact_s, fact_p, fact_o, arg_id, count_facts, result_buffer, from_client);
				}
				//			log.trace("# fact_p[0]={}, fact_o[0]={}", getString(fact_p[0]), getString(fact_o[0]));

				// AUTHORIZE
				if(authorization_id >= 0)
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
							if(strcmp(fact_p[i], SET_FROM.ptr) == 0)
							{
								from_id = i;
							} else if(strcmp(fact_p[i], RIGHTS.ptr) == 0)
							{
								right_id = i;
							} else if(strcmp(fact_p[i], CATEGORY.ptr) == 0)
							{
								category_id = i;
							} else if(strcmp(fact_p[i], TARGET_SUBSYSTEM_ELEMENT.ptr) == 0)
							{
								targetId_id = i;
							} else if(strcmp(fact_p[i], ELEMENT_ID.ptr) == 0)
							{
								elements_id = i;
							} else if(strcmp(fact_p[i], REPLY_TO.ptr) == 0)
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
						hierarhical_departments_of_delegate[ii] = getDepartmentTreePathOfUser(
								hierarhical_delegates[ii], az.getTripleStorage());
					}

					char*[] hierarhical_departments = null;
					hierarhical_departments = getDepartmentTreePathOfUser(user, az.getTripleStorage());
					//				log.trace("function authorize: calculate department tree for this target, count={}", hierarhical_departments.length);

					uint count_prepared_elements = 0;
					uint count_authorized_doc = 0;
					uint doc_pos = 0;
					uint prev_doc_pos = 0;

					//	log.trace("this request on authorization #1.1.1 {}, command_uid={}, command_len={}", targetRightType, getString (command_uid), strlen(command_uid));

					*result_ptr = '<';
					strcpy(result_ptr + 1, command_uid);
					result_ptr += strlen(command_uid) + 1;
					strcpy(result_ptr, result_data_header.ptr);
					result_ptr += result_data_header.length;

					time_calculate_right.start;

					//				log.trace("function authorize: repair all elementIds");

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
							calculatedRight = az.authorize(fact_o[category_id], docId, user, targetRightType,
									hierarhical_departments, from_client);

							//log.trace("right = {}", calculatedRight);

							//log.trace("#23");

							if(calculatedRight == false)
							{
								for(int ii = 0; ii < hierarhical_delegates.length; ii++)
								{
									//log.trace("#3");
									calculatedRight = az.authorize(fact_o[category_id], docId,
											hierarhical_delegates[ii], targetRightType,
											hierarhical_departments_of_delegate[ii], from_client);
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
					}

					double total_time_calculate_right = time_calculate_right.stop;

					strcpy(result_ptr, "\".<");
					result_ptr += 3;
					strcpy(result_ptr, command_uid);
					result_ptr += strlen(command_uid);
					strcpy(result_ptr, result_state_ok_header.ptr);
					result_ptr += result_state_ok_header.length;
					*(result_ptr - 1) = 0;

					time = elapsed.stop;

					log.trace("count auth in count docs={}, authorized count docs={}", count_prepared_elements,
							count_authorized_doc);

					log.trace("total time = {:d6} ms. ( {:d6} sec.), cps={}", time * 1000, time,
							count_prepared_elements / time);

					//				printf("send_result_and_logging_messages #1\n");
					log.trace("time calculate right = {:d6} ms. ( {:d6} sec.), cps={}",
							total_time_calculate_right * 1000, total_time_calculate_right,
							count_prepared_elements / total_time_calculate_right);

					//				printf("try to send message\n");

					send_result_and_logging_messages(queue_name, result_buffer, from_client);

					//				printf("message successfully sent\n");

				}
			}

			//	printf("!!!! queue_name=%s\n", queue_name);
			//	log.trace("!!!! check_right={}", check_right);
			//	printf("!!!! list_docid=%s\n", list_docid);

			//	log.trace("\nIN: list_docid={}", str_2_char_array(cast(char*) list_docid, doclistid_length));

			if(logging_io_messages == true)
			{
				writeToLog("\r\n\r\n\r\n");
			}

		}

	} finally
	{
		az.getTripleStorage().print_stat();
		az.getTripleStorage().release_all_lists();
		
		log.trace("message successfully prepared\r\n");
	}
}

void remove_subject(char* s)
{
	triple_list_element* removed_facts = az.getTripleStorage.getTriples(s, null, null);
	triple_list_element* removed_facts_FE = removed_facts;

	if(removed_facts !is null)
	{

		char[][20] s_a;
		char[][20] p_a;
		char[][20] o_a;

		int cnt = 0;

		while(removed_facts !is null)
		{
			Triple* triple2 = removed_facts.triple;

			if(triple2 !is null)
			{
				char* ss = cast(char*) triple2.s;

				char* pp = cast(char*) triple2.p;

				char* oo = cast(char*) triple2.o;

				s_a[cnt] = getString(ss);
				p_a[cnt] = getString(pp);
				o_a[cnt] = getString(oo);

				//				az.getTripleStorage.removeTriple(getString(ss), getString(pp), getString(oo));
			}
			cnt++;
			removed_facts = removed_facts.next_triple_list_element;
		}

		for(int k = 0; k < cnt; k++)
		{
			//			log.trace("remove triple2 <{}><{}>\"{}\"", s_a[k], p_a[k], o_a[k]);

			az.getTripleStorage.removeTriple(s_a[k], p_a[k], o_a[k]);
			az.logginTriple('D', s_a[k], p_a[k], o_a[k]);
		}

		az.getTripleStorage.list_no_longer_required(removed_facts_FE);

	}
}

void remove_subjects_by_predicate(char* p, char* o)
{

	triple_list_element* removed_facts = az.getTripleStorage.getTriples(null, p, o);
	triple_list_element* removed_facts_FE = removed_facts;

	if(removed_facts !is null)
	{

		char[][100] s_a;

		int cnt = 0;

		while(removed_facts !is null)
		{
			Triple* triple2 = removed_facts.triple;

			if(triple2 !is null)
			{
				char* ss = cast(char*) triple2.s;
				s_a[cnt] = getString(ss);
			}
			cnt++;
			removed_facts = removed_facts.next_triple_list_element;
		}

		for(int k = 0; k < cnt; k++)
		{
			remove_subject(s_a[k].ptr);
		}

		az.getTripleStorage.list_no_longer_required(removed_facts_FE);

	}
}

private void writeToLog(char[] string)
{
	synchronized
	{
		if(file is null)
		{
			auto style = File.ReadWriteOpen;
			style.share = File.Share.Read;
			style.open = File.Open.Append;
			file = new File("io_messages.log", style);
		}
		file.output.write(string);
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
		result["dbus_semargl_service_name"] = "";
		result["dbus_semargl_listen_from"] = "";
		result["index_PO_key_area"] = "10000";
		result["index_S1PPOO_count"] = "1000";
		result["index_SP_key_area"] = "10000";
		result["index_S_key_area"] = "1000";
		result["index_SPO_count"] = "1000";
		result["index_O_short_order"] = "4";
		result["index_SPO_key_area"] = "10000";
		result["dbus_semargl_service_name"] = "";
		result["index_SP_count"] = "1000";
		result["index_O_key_area"] = "10000";
		result["index_S1PPOO_short_order"] = "4";
		result["index_S1PPOO_key_area"] = "10000";
		result["index_SPO_short_order"] = "4";
		result["dbus_semargl_listen_from"] = "";
		result["index_PO_short_order"] = "4";
		result["index_PO_count"] = "1000";
		result["index_O_count"] = "1000";
		result["index_S_short_order"] = "4";
		result["index_SP_short_order"] = "4";
		result["index_S_count"] = "1000";
		result["amqp_server_routingkey"] = "";				
		

		props_conduit = new FileConduit(props_path.toString(), FileConduit.ReadWriteCreate);
		auto output = new MapOutput!(char)(props_conduit.output);

		output.append(result);
		output.flush;
		props_conduit.close;
	} else
	{
		props_conduit = new FileConduit(props_path.toString(), FileConduit.ReadExisting);
		auto input = new MapInput!(char)(props_conduit.input);
		result = result.init;
		input.load(result);
		props_conduit.close;
	}

	return result;
}