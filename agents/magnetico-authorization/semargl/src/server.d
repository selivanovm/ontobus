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

private librabbitmq_client client = null;

private Authorization az = null;

private char* result_buffer = null;
private char* queue_name = null;
private char* user = null;

char[] PUT = "magnet-ontology#put";
char[] GET = "magnet-ontology#get";
char[] SUBJECT = "magnet-ontology#subject";
char[] ARGUMENT = "magnet-ontology/transport#argument";
char[] RESULT_DATA = "magnet-ontology/transport#result:data";
char[] RESULT_STATE = "magnet-ontology/transport#result:state";
char[] REPLY_TO = "magnet-ontology/transport#reply_to";

uint fn_cnt = 0;
uint args_cnt = 0;
uint reply_to_cnt = 0;

char*[] fn_names;
uint[] fn_names_l;

char*[] fn_uids;
uint[] fn_uids_l;

char*[] args;
uint[] args_l;

char*[] args_uids;
uint[] args_uids_l;

char*[] reply_to;
uint[] reply_to_l;

char*[] reply_to_uids;
uint[] reply_to_uids_l;

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

	Stdout.format("connect to AMQP server ({}:{} vhost={}, queue={})", hostname, port, vhost, queue);
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

		//		Stdout.format ("{}", message);
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

			/*			Counts count_elements = calculate_count_facts(cast(char*) message, message_size);
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
			*/

  fn_cnt = 0;
  args_cnt = 0;
  reply_to_cnt = 0;

void parse_functions(char* start, int l, char* s, int s_l, char* p, int p_l, char* o, int o_l, uint  m)
{

  log.trace("Triple : <{}> <{}> <{}> .", getString(s, s_l), getString(p, p_l), getString(o, o_l));
  
  if (cmp_str(p, p_l, SUBJECT)) {

    // сохраняем uid
    fn_uids[fn_cnt] = s;
    fn_uids_l[fn_cnt] = s_l;

    // сохраняем функцию
    fn_names[fn_cnt] = o;
    fn_names_l[fn_cnt] = o_l;

    fn_cnt++;

  } else if (cmp_str(p, p_l, ARGUMENT)) {

    // сохраняем uid
    args_uids[args_cnt] = s;
    args_uids_l[args_cnt] = s_l;

    // сохраняем аргумент
    args[args_cnt] = o;
    args_l[args_cnt] = o_l;

    args_cnt++;

  } else if (cmp_str(p, p_l, REPLY_TO)) {
    
    reply_to_uids[reply_to_cnt] = s;
    reply_to_uids_l[reply_to_cnt] = s_l;

    reply_to[reply_to_cnt] = o;
    reply_to_l[reply_to_cnt] = o_l;

    reply_to_cnt++;

  }

}


  split_triples_line(cast(char*) message, message_size, &parse_functions);

  log.trace("разбор окончен.");

  char* reply_to_ptr;
  uint reply_to_length;

  log.trace("Получено {} команд.", fn_cnt);

  for(uint i = 0; i < fn_cnt; i++) {

    reply_to_ptr = null;
    reply_to_length = 0;
    
    for(uint k = 0; k < reply_to_cnt; k++) {
      if (cmp_str(fn_uids[i], fn_uids_l[i], reply_to_uids[k], reply_to_uids_l[k])) {
	reply_to_ptr = reply_to[k];
	reply_to_length = reply_to_l[k];
      }
    }

    if (reply_to_ptr == null || reply_to_length == 0) {
      continue;
    }

    log.trace("Получена команда : {}", getString(fn_names[i], fn_names_l[i]));

    if (cmp_str(fn_names[i], fn_names_l[i], PUT)) {
      put_triplets(i);
      /*      for(uint j = 0; j < args_cnt; j++) {
	if (cmp_str(fn_uids[i], fn_uids_l[i], args_uids[j], args_uids_l[j])) {
	put_triples_line(args[j], args_l[j], &store_triplet);	  
	}
	}*/
    } else if (cmp_str(fn_names[i], fn_names_l[i], GET)) {
      /*      uint arg_idx  = -1;
      for(uint j = 0; j < args_cnt; j++) {
	if (cmp_str(fn_uids[i], fn_uids_l[i], args_uids[j], args_uids_l[j])) {
	  //	  split_triples_line(args[j], args_l[j], &get_triplet(fn_uids[i], fn_uids_l[i], reply_to_ptr, reply_to_length);
	}*/
      }
    }
			

  /*			for(int i = 0; i < count_facts; i++)
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
										}
									}
								}
							}
						}
					}

				}

				}*/

  /*			log.trace("разбор сообщения закончен");

			if(get_id >= 0 && arg_id > 0)
			{

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
			}*/

  /*			if(delete_subjects_id >= 0 && arg_id > 0)
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

				}*/

  /*			if(delete_subjects_by_predicate_id >= 0 && arg_id > 0)
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
				}*/

  /*			// GET_AUTHORIZATION_RIGHTS_RECORDS
			if(get_authorization_rights_records_id >= 0 && arg_id > 0)
			{
				az.getAuthorizationRightRecords(fact_s, fact_p, fact_o, count_facts, result_buffer, client);
			}*/

  /*			// PUT
			if(put_id >= 0 && arg_id > 0)
			{
				log.trace("команда на добавление");

				int reply_to_id = 0;

				ulong uuid = getUUID();

				for(int i = 0; i < count_facts; i++)
				{
					if(strcmp(fact_p[i], "magnet-ontology/transport/message#reply_to") == 0)
						reply_to_id = i;
					else if(is_fact_in_object[i] == arg_id)
					{
						if(strlen(fact_s[i]) == 0)
						{
							fact_s[i] = cast(char*) new char[16];
							longToHex(uuid, fact_s[i]);
						}
						log.trace("add triple <{}><{}><{}>", getString(cast(char*) fact_s[i]), getString(cast(char*) fact_p[i]), getString(
								cast(char*) fact_o[i]));
						az.getTripleStorage.addTriple(getString(fact_s[i]), getString(fact_p[i]), getString(fact_o[i]));
						az.logginTriple('A', getString(fact_s[i]), getString(fact_p[i]), getString(fact_o[i]));
					}
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

				}*/

  /*			// GET_DELEGATE_ASSIGNERS
			if(get_delegate_assigners_tree_id >= 0 && arg_id > 0)
			{
				az.getDelegateAssignersTree(fact_s, fact_p, fact_o, arg_id, count_facts, result_buffer, client);
				}*/
			//			log.trace("# fact_p[0]={}, fact_o[0]={}", getString(fact_p[0]), getString(fact_o[0]));

  /*			// AUTHORIZE
			if(strcmp(fact_o[0], "magnet-ontology/authorization/functions#authorize") == 0 && strcmp(fact_p[0], "magnet-ontology#subject") == 0)
			{
				log.trace("function authorize");

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
					char prev_state_byte = *(autz_elements + i);

					//								log.trace("this request on authorization #1.2, {} {}", i, *(autz_elements + i));

					if(*(autz_elements + i) == ',' || *(autz_elements + i) == 0)
					{
						*(autz_elements + i) = 0;

						docId = cast(char*) (autz_elements + doc_pos);

						count_prepared_elements++;
						bool calculatedRight;
						calculatedRight = az.authorize(fact_o[category_id], docId, user, targetRightType, hierarhical_departments);
						//					log.trace("right = {}", calculatedRight);

						if(calculatedRight == false)
						{
							for(int ii = 0; ii < hierarhical_delegates.length; ii++)
							{
								calculatedRight = az.authorize(fact_o[category_id], docId, hierarhical_delegates[ii], targetRightType,
										hierarhical_departments_of_delegate[ii]);
								if(calculatedRight == true)
									break;
							}
						}

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

							//						log.trace("this request on authorization #1.4 true");
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

			}*/
		}

		//	printf("!!!! queue_name=%s\n", queue_name);
		//	log.trace("!!!! check_right={}", check_right);
		//	printf("!!!! list_docid=%s\n", list_docid);

		//	log.trace("\nIN: list_docid={}", str_2_char_array(cast(char*) list_docid, doclistid_length));
		log.trace("message successful prepared");
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


bool cmp_str(char* buf1, uint l1, char[] buf2) {
  if (l1 != buf2.length)
    return false;
  if (l1 == 0)
    return true;

  char* bbuf = &buf2[0];
  for(uint i = 0; i < l1; i++) {
    if (*(buf1 + i) != *(bbuf + i))
      return false;
  }
  return true;
}

private bool cmp_str(char* buf1, uint l1, char* buf2, uint l2) {
  if (l1 != l2)
    return false;
  if (l1 == 0)
    return true;

  for(uint i = 0; i < l1; i++) {
    if (*(buf1 + i) != *(buf2 + i))
      return false;
  }
  return true;
}

private void put_triplets(uint fn_num)
{

  log.trace("команда на добавление");
  ulong uuid = getUUID();

  void store_triplet(char* start, int l, char* s, int s_l, char* p, int p_l, char* o, int o_l, uint  m)
  {
    char* subject = null;
    if(s_l == 0)
      {
	subject = cast(char*) new char[16];
	s_l = 16;
	longToHex(uuid, subject);
      }
    else
      subject = s;
    log.trace("add triple <{}><{}><{}>", getString(s, s_l), getString(p, p_l), getString(o, o_l));
    az.getTripleStorage.addTriple(getString(s, s_l), getString(p, p_l), getString(o, o_l));
    az.logginTriple('A', getString(s, s_l), getString(p, p_l), getString(o, o_l));
    
  }
  for(uint j = 0; j < args_cnt; j++) {
    if (cmp_str(fn_uids[fn_num], fn_uids_l[fn_num], args_uids[j], args_uids_l[j])) {
      split_triples_line(args[j], args_l[j], &store_triplet);	  
    }
  }

  // PUT
    /*  if(put_id >= 0 && arg_id > 0)
    {

      
      
      for(int i = 0; i < count_facts; i++)
	{
	  if(strcmp(fact_p[i], "magnet-ontology/transport/message#reply_to") == 0)
	    reply_to_id = i;
	  else if(is_fact_in_object[i] == arg_id)
	    {
	    }
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
      
      }*/
  
}