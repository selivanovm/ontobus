module server;

private import tango.core.Thread;
private import tango.io.Console;
private import tango.stdc.string;
private import tango.stdc.stdlib;
//private import std.string;
private import tango.stdc.posix.stdio;
private import Log;

private import tango.io.FileScan;
private import tango.io.FileConduit;
private import tango.io.stream.MapStream;

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

	char[][char[]] props = load_props;
	char[] hostname = props["amqp_server_address"] ~ "\0";
	int port = atoi((props["amqp_server_port"] ~ "\0").ptr);
	char[] vhost = props["amqp_server_vhost"] ~ "\0";
	char[] login = props["amqp_server_login"] ~ "\0";
	char[] passw = props["amqp_server_password"] ~ "\0";
	char[] queue = props["amqp_server_queue"] ~ "\0";

	Stdout.format("connect to AMQP server ({}:{} vhost={}, queue={})", hostname, port, vhost, queue).newline;
	client = new librabbitmq_client(hostname, port, login, passw, queue, vhost);
	client.set_callback(&get_message);

	(new Thread(&client.listener)).start;
	Thread.sleep(0.250);
}

void get_message(byte* message, ulong message_size)
{
	synchronized
	{
		if(*(message + message_size - 1) != '.')
		{
			log.trace("invalid message");
			return;
		}

		*(message + message_size) = 0;

		//		Stdout.format ("{}", message).newline;
		log.trace("\n\nget new message, message_size={} \n{}...", message_size, getString(cast(char*) message));

		auto elapsed = new StopWatch();
		auto time_calculate_right = new StopWatch();
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
			int get_delegate_assigners_id = -1;

			for(int i = 0; i < count_facts; i++)
			{
				//				log.trace("look triple <{}><{}><{}>", getString(cast(char*) fact_s[i]), toString(
				//						cast(char*) fact_p[i]), getString(cast(char*) fact_o[i]));

				if(put_id < 0 && strcmp(fact_o[i], "magnet-ontology#put") == 0 && strcmp(fact_p[i], "magnet-ontology#subject") == 0)
				{
					put_id = i;
				//					Stdout.format("found comand {}, id ={} ", getString(fact_o[i]), i).newline;
				}
				else
				{
					if(arg_id < 0 && strcmp(fact_p[i], "magnet-ontology/transport#argument") == 0)
					{
						arg_id = i;
					//						Stdout.format("found comand {}, id ={} ", getString(fact_p[i]), i).newline;
					}
					else
					{
						if(delete_subjects_by_predicate_id < 0 && strcmp(fact_o[i], "magnet-ontology#delete_subjects_by_predicate") == 0 && strcmp(
								fact_p[i], "magnet-ontology#subject") == 0)
						{
							delete_subjects_by_predicate_id = i;
						//							Stdout.format("found comand {}, id ={} ", getString(fact_o[i]), i).newline;
						}
						else
						{
							if(get_id < 0 && strcmp(fact_o[i], "magnet-ontology#get") == 0 && strcmp(fact_p[i], "magnet-ontology#subject") == 0)
							{
								get_id = i;
								Stdout.format("found comand {}, id ={} ", getString(fact_o[i]), i).newline;
							}
							else
							{
								if(delete_subjects_id < 0 && strcmp(fact_o[i], "magnet-ontology#delete_subjects") == 0 && strcmp(fact_p[i],
										"magnet-ontology#subject") == 0)
								{
									delete_subjects_id = i;
									Stdout.format("found comand {}, id ={} ", getString(fact_o[i]), i).newline;
								}
								else
								{
									if(get_id < 0 && 
									   strcmp(fact_o[i], "magnet-ontology/authorization/functions#get_authorization_rights_records") == 0 &&
									   strcmp(fact_p[i], "magnet-ontology#subject") == 0)
									{
										get_authorization_rights_records_id = i;
										//Stdout.format("found comand {}, id ={} ", getString(fact_o[i]), i).newline;
									}
									else
									  {
									    if(add_delegates_id < 0 && 
									       strcmp(fact_o[i], 
										      "magnet-ontology/authorization/functions#add_delegates") == 0 &&
									       strcmp(fact_p[i], "magnet-ontology#subject") == 0)
									      {
										add_delegates_id = i;
									//Stdout.format("found comand {}, id ={} ", getString(fact_o[i]), i).newline;
									      } 
									    else
									      {
										if(get_delegate_assigners_id < 0 && 
										   strcmp(fact_o[i], 
											  "magnet-ontology/authorization/functions#get_delegate_assigners") == 0 &&
										   strcmp(fact_p[i], "magnet-ontology#subject") == 0)
										  {
										    get_delegate_assigners_id = i;
										    //Stdout.format("found comand {}, id ={} ", getString(fact_o[i]), i).newline;
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
				log.trace("function get: query={} ", getString(fact_o[arg_id]));

				uint* list_facts = az.getTripleStorage.getTriples(fact_s[arg_id], fact_p[arg_id], fact_o[arg_id], false);

				if(list_facts !is null)
				{
					uint next_element1 = 0xFF;
					while(next_element1 > 0)
					{
						byte* triple = cast(byte*) *list_facts;
						if(triple !is null)
						{
							char* s = cast(char*) triple + 6;

							char* p = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1);

							char* o = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1 + (*(triple + 2) << 8) + *(triple + 3) + 1);

							log.trace("get result: <{}><{}><{}>", getString(s), getString(p), getString(p));
						}
						next_element1 = *(list_facts + 1);
						list_facts = cast(uint*) next_element1;
					}
				}
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

				uint* removed_facts = az.getTripleStorage.getTriples(fact_o[arg_id], null, null, false);

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

							log.trace("remove triple <{}><{}><{}>", getString(s), getString(p), getString(p));

							az.getTripleStorage.removeTriple(s, p, o);
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
				strcpy(result_ptr, "><magnet-ontology/transport#result:state>\"ok\".");
				result_ptr += 48;

				strcpy(result_ptr, "\".\0");

				strcpy(queue_name, fact_o[reply_to_id]);

				log.trace("queue_name:{}", getString(queue_name));
				log.trace("result:{}", getString(result_buffer));

				elapsed.start;

				client.send(queue_name, result_buffer);

				time = elapsed.stop;

				log.trace("send result time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);

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

				uint* removed_subjects = az.getTripleStorage.getTriples(null, arg_p, arg_o, false);

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

							uint* removed_facts = az.getTripleStorage.getTriples(s, null, null, false);

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

										az.getTripleStorage.removeTriple(s, p, o);
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
			  az.getAuthorizationRightRecords(fact_s, fact_p, fact_o, count_facts, result_buffer, client);
			}

			// PUT
			if(put_id >= 0 && arg_id > 0)
			{
				log.trace("команда на добавление");

				int reply_to_id = 0;

				ulong uuid = getUUID();

				for(int i = 0; i < count_facts; i++)
				{
				  if (strcmp(fact_p[i], "magnet-ontology/transport/message#reply_to") == 0)
				    reply_to_id = i;
				  else if(is_fact_in_object[i] == arg_id)
				    {
				      if(strlen(fact_s[i]) == 0)
					{
					  fact_s[i] = cast(char*) new char[16];
					  longToHex(uuid, fact_s[i]);
					}
				    }
				  
				  log.trace("add triple <{}><{}><{}>", getString(cast(char*) fact_s[i]), getString(cast(char*) fact_p[i]), getString(
																		     cast(char*) fact_o[i]));
				  az.getTripleStorage.addTriple(getString(fact_s[i]), getString(fact_p[i]), getString(fact_o[i]));
				  az.logginTriple('A', getString(fact_s[i]), getString(fact_p[i]), getString(fact_o[i]));
				}

				time = elapsed.stop;
				log.trace("add triple time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);

				char* result_ptr = cast(char*) result_buffer;
				char* command_uid = fact_s[0];

				*result_ptr = '<';
				strcpy(result_ptr + 1, command_uid);
				result_ptr += strlen(command_uid) + 1;
				strcpy(result_ptr, "><magnet-ontology/transport#result:state>\"ok\".");
				result_ptr += 48;

				strcpy(result_ptr, "\".\0");

				strcpy(queue_name, fact_o[reply_to_id]);

				log.trace("queue_name:{}", getString(queue_name));
				log.trace("result:{}", getString(result_buffer));

				elapsed.start;

				client.send(queue_name, result_buffer);

				time = elapsed.stop;

				log.trace("send result time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);

			}

			// GET_DELEGATE_ASSIGNERS
			if(get_delegate_assigners_id >= 0 && arg_id > 0)
			{
			  log.trace("команда на выборку делегировавших");
			  
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
			  
			  uint* delegates_facts = az.getTripleStorage.getTriples(null, "magnet-ontology/authorization/acl#delegate", fact_o[arg_id], false);
			  
			  //log.trace("#1 gda");

			  char* result_ptr = cast(char*) result_buffer;
			  char* command_uid = fact_s[0];
			  strcpy(queue_name, fact_o[reply_to_id]);

			  *result_ptr = '<';
			  strcpy(result_ptr + 1, command_uid);
			  result_ptr += strlen(command_uid) + 1;
			  strcpy(result_ptr, "><magnet-ontology/transport#result:data>\"");
			  result_ptr += 41;
				
			  if(delegates_facts !is null)
			    {
			      //log.trace("#2 gda");
			      uint next_delegate = 0xFF;
			      while(next_delegate > 0)
				{
				  //log.trace("#3 gda");
				  byte* de_legate = cast(byte*) *delegates_facts;
				  if(de_legate !is null)
				    {
				      char* subject = cast(char*) de_legate + 6;
				      uint* owners_facts = 
					az.getTripleStorage.getTriples(subject, "magnet-ontology/authorization/acl#owner", null, false);
				      
				      if(owners_facts !is null)
					{
					  uint next_owner = 0xFF;
					  while(next_owner > 0)
					    {
					      byte* owner = cast(byte*) *owners_facts;
					      if(owner !is null)
						{
						  //log.trace("#4 gda");
						  char* object = cast(char*) (owner + 6 + (*(owner + 0) << 8) + *(owner + 1) + 1 + 
									      (*(owner + 2) << 8) + *(owner + 3) + 1);

						  //log.trace("delegate = {}, owner = {}", getString(subject), getString(object));

						  strcpy(result_ptr++, ",");
						  strcpy(result_ptr, object);
						  result_ptr += strlen(object);

						}
					      next_owner = *(owners_facts + 1);
					      owners_facts = cast(uint*) next_owner;
					    }
					}
				    }
				  next_delegate = *(delegates_facts + 1);
				  delegates_facts = cast(uint*) next_delegate;
				}
			    }

			  strcpy(result_ptr, "\".<");
			  result_ptr += 3;
			  strcpy(result_ptr, command_uid);
			  result_ptr += strlen(command_uid);
			  strcpy(result_ptr, "><magnet-ontology/transport#result:state>\"ok\".\0");
			  
			  client.send(queue_name, result_buffer);
			  
			  time = elapsed.stop;
			  log.trace("get delegate assigners time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
			  log.trace("result:{}", getString(result_buffer));

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

				char*[] hierarhical_departments = null;
				log.trace("function authorize: calculate department tree for this target");
				hierarhical_departments = getDepartmentTreePath(user, az.getTripleStorage());
				//						log.trace("!!!! load_hierarhical_departments, count={}", hierarhical_departments.length);

				uint count_prepared_elements = 0;
				uint count_authorized_doc = 0;
				uint doc_pos = 0;
				uint prev_doc_pos = 0;

				//			Stdout.format("this request on authorization #1.1.1 {}, command_uid={}, command_len={}", targetRightType, getString (command_uid), strlen(command_uid)).newline;

				*result_ptr = '<';
				strcpy(result_ptr + 1, command_uid);
				result_ptr += strlen(command_uid) + 1;
				strcpy(result_ptr, "><magnet-ontology/transport#result:data>\"");
				result_ptr += 41;

				time_calculate_right.start;
				
				log.trace("function authorize: repair all elementIds");

				for(uint i = 0; true; i++)
				{
					char prev_state_byte = *(autz_elements + i);

					//								Stdout.format("this request on authorization #1.2, {} {}", i, *(autz_elements + i)).newline;

					if(*(autz_elements + i) == ',' || *(autz_elements + i) == 0)
					{
						*(autz_elements + i) = 0;

						docId = cast(char*) (autz_elements + doc_pos);
						//					printf("elId:%s\n", elId);

						//					Stdout.format("this request on authorization #1.3, {} docId={}", i, getString (autz_elements + doc_pos)).newline;

						count_prepared_elements++;
						bool calculatedRight = az.authorize(fact_o[category_id], docId, user, targetRightType, hierarhical_departments);
						//					Stdout.format("right = {}", calculatedRight).newline;

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

							//						Stdout.format("this request on authorization #1.4 true").newline;
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
				strcpy(result_ptr + 3, command_uid);
				result_ptr += strlen(command_uid) + 1;
				strcpy(result_ptr, "><magnet-ontology/transport#result:state>\"ok\".\0");
				result_ptr += 48;

				time = elapsed.stop;

				log.trace("count auth in count docs={}, authorized count docs={}", count_prepared_elements, count_authorized_doc);

				log.trace("total time = {:d6} ms. ( {:d6} sec.), cps={}", time * 1000, time, count_prepared_elements / time);

				log.trace("time calculate right = {:d6} ms. ( {:d6} sec.), cps={}", total_time_calculate_right * 1000, total_time_calculate_right,
						count_prepared_elements / total_time_calculate_right);

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
