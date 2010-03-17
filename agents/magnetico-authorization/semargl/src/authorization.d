module authorization;

private import Predicates;

private import tango.io.Stdout;
private import tango.stdc.string;
private import tango.stdc.stdlib;
private import tango.io.FileConduit;
private import tango.io.stream.MapStream;

import Integer = tango.text.convert.Integer;

version(tango_99_8)
{
	private import tango.io.device.File;
}

version(tango_99_7)
{
	private import tango.io.File;
}

private import Text = tango.text.Util;
private import tango.time.StopWatch;
private import tango.time.WallClock;
private import tango.time.Clock;
private import tango.io.FileScan;

private import tango.text.locale.Locale;
private import tango.text.convert.TimeStamp;
private import tango.text.convert.Layout;

private import scripts.S05InDocFlow;
private import scripts.S01AllLoggedUsersCanCreateDocuments;
private import scripts.S01UserIsAdmin;
private import scripts.S09DocumentOfTemplate;
private import scripts.S10UserIsAuthorOfDocument;
private import scripts.S11ACLRightsHierarhical;

private import RightTypeDef;
private import script_util;

private import persistent_triple_storage;

private import fact_tools;
private import Log;

private import HashMap;
private import TripleStorage;

private import Category;

//private import mom_client;

private import server;

class Authorization
{
	private char[][] i_know_predicates;
	private TripleStorage ts = null;

	int[] counters;

	private char[] log_path = "";
	private File log_file;

	this(char[][char[]] props)
	{
		counters = new int[10];

		i_know_predicates = new char[][20];

		uint d = 0;

		//		 запись о праве, данная часть ACL требует переработки!

		//      - система выдающая право, "BA"/"DOCFLOW"
		i_know_predicates[d++] = AUTHOR_SYSTEM;
		//      - "user"/routeName
		i_know_predicates[d++] = AUTHOR_SUBSYSTEM;
		//		 - id user or id route.
		i_know_predicates[d++] = AUTHOR_SUBSYSTEM_ELEMENT;
		i_know_predicates[d++] = TARGET_SYSTEM; //           - система, для которой выдали права, "BA"/"DOCFLOW".

		i_know_predicates[d++] = TARGET_SUBSYSTEM; //       - "user"/"department".
		i_know_predicates[d++] = TARGET_SUBSYSTEM_ELEMENT; // - user id or department id.

		i_know_predicates[d++] = CATEGORY; //                                 - категория элемента, на который выдаются права (DOCUMENT, DOCUMENTTYPE, DICTIONARY и т. д.).
		i_know_predicates[d++] = DATE_FROM; //                                 - период действия прав (до (с возможностью указания открытых интервалов значение null)).
		i_know_predicates[d++] = DATE_TO; //                                 - период действия прав (от (с возможностью указания открытых интервалов- значение null)).
		i_know_predicates[d++] = ELEMENT_ID; //                                 - идентификатор элемента, на который выдаются права.
		i_know_predicates[d++] = RIGHTS; //                                 - "c|r|u|d"

		//		 запись о делегировании
		i_know_predicates[d++] = DELEGATION_DELEGATE; // - кому делегируют
		i_know_predicates[d++] = DELEGATION_OWNER; // - кто делегирует
		i_know_predicates[d++] = DELEGATION_WITH_TREE; // - делегировать с учетом дерева делегатов

		// document
		i_know_predicates[d++] = CREATOR; // - создатель объекта(документа, типа документа, справочника)
		i_know_predicates[d++] = SUBJECT;
		//		i_know_predicates[d++] = "magnet-ontology#typeName";

		// ORGANIZATION
		i_know_predicates[d++] = HAS_PART;
		i_know_predicates[d++] = MEMBER_OF;
		i_know_predicates[d++] = IS_ADMIN;

		i_know_predicates[d++] = DOCUMENT_TEMPLATE_ID;

		init(props);
	}

	public TripleStorage getTripleStorage()
	{
		return ts;
	}

	private char[] pp = null;

	private void init(char[][char[]] props)
	{
		try
		{
			log.trace("authorization init..");
			Stdout.format("authorization init..").newline;

			ts = new TripleStorage(atoi(props["index_SPO_count"].ptr), atoi(props["index_SPO_short_order"].ptr),
					atoi(props["index_SPO_key_area"].ptr));
			ts.set_new_index(idx_name.S, atoi(props["index_S_count"].ptr), atoi(props["index_S_short_order"].ptr),
					atoi(props["index_S_key_area"].ptr));
			ts.set_new_index(idx_name.O, atoi(props["index_O_count"].ptr), atoi(props["index_O_short_order"].ptr),
					atoi(props["index_O_key_area"].ptr));
			ts.set_new_index(idx_name.PO, atoi(props["index_PO_count"].ptr), atoi(props["index_PO_short_order"].ptr), atoi(
					props["index_PO_key_area"].ptr));
			ts.set_new_index(idx_name.SP, atoi(props["index_SP_count"].ptr), atoi(props["index_SP_short_order"].ptr), atoi(
					props["index_SP_key_area"].ptr));
			ts.set_new_index(idx_name.S1PPOO, atoi(props["index_S1PPOO_count"].ptr), atoi(props["index_S1PPOO_short_order"].ptr), atoi(
					props["index_S1PPOO_key_area"].ptr));

			ts.setPredicatesToS1PPOO(TARGET_SUBSYSTEM_ELEMENT, ELEMENT_ID, RIGHTS);

			//		ts.setPredicatesToS1PPOO("magnet-ontology/authorization/acl#targetSubsystemElement", "magnet-ontology/authorization/acl#elementId",
			//				"magnet-ontology/authorization/acl#rights");

			pp = TARGET_SUBSYSTEM_ELEMENT ~ ELEMENT_ID;
			//

			char[] root = ".";
			log.trace("Scanning '{}'", root);

			auto scan = (new FileScan)(root, ".n3");
			log.trace("\n{} Folders\n", scan.folders.length);
			foreach(folder; scan.folders)
				log.trace("{}\n", folder);
			log.trace("\n{0} Files\n", scan.files.length);

			foreach(file; scan.files)
			{
				log.trace("{}\n", file);
				load_from_file(file, i_know_predicates, ts);
			}
			log.trace("\n{} Errors", scan.errors.length);
			foreach(error; scan.errors)
				log.trace(error);

			scan = (new FileScan)(root, ".n3log");
			log.trace("\n{} Folders\n", scan.folders.length);
			foreach(folder; scan.folders)
				log.trace("{}\n", folder);
			log.trace("\n{0} Files\n", scan.files.length);

			FilePath[] fp = scan.files;

			char[][] fp_str = new char[][fp.length];

			for(int i = 0; i < fp.length; i++)
			{
				fp_str[i] = fp[i].toString();
			}
			fp_str = fp_str.sort;

			for(int i = 0; i < fp_str.length; i++)
			{
				log.trace("{}\n", fp_str[i]);
				load_from_file(new FilePath(fp_str[i]), i_know_predicates, ts);
			}

			log.trace("\n{} Errors", scan.errors.length);
			foreach(error; scan.errors)
				log.trace(error);

			//		print_list_triple(ts.getTriples("record", null, null, false));

			//		ts.removeTriple("record", "magnet-ontology#target", "92e57b6d-83e3-485f-8885-0bade363f759");

			//		print_list_triple(ts.getTriples("record", null, null, false));

			log.trace("authorization init ... ok");
			Stdout.format("authorization init.. ok").newline;

			ts.print_stat();
		}
		catch(IndexException ex)
		{
			if(ex.errCode == IndexException.errorCode.short_order_is_full)
			{
				char[] prop_name = "index_" ~ ex.idxName ~ "_short_order";
				int short_order_param = atoi(props[prop_name].ptr);

				log.trace("prev short order param = {}", short_order_param);
				Stdout.format("prev short order param = {}", short_order_param).newline;
				short_order_param++;
				log.trace("new short order param = {}", short_order_param);
				Stdout.format("prev short order param = {}", short_order_param).newline;
				props[prop_name] = Integer.toString(short_order_param);
			}
			if(ex.errCode == IndexException.errorCode.block_triple_area_is_full)
			{
				char[] prop_name = "index_" ~ ex.idxName ~ "_key_area";
				int param = atoi(props[prop_name].ptr);

				log.trace("prev key area param = {}", param);
				Stdout.format("prev key area param = {}", param).newline;
				param += 1000 * 1024;
				log.trace("prev key area param = {}", param);
				Stdout.format("prev key area param = {}", param).newline;

				props[prop_name] = Integer.toString(param);
			}

			FileConduit props_conduit;
			auto props_path = new FilePath("./semargl.properties");
			props_conduit = new FileConduit(props_path.toString(), FileConduit.ReadWriteCreate);
			auto output = new MapOutput!(char)(props_conduit.output);

			output.append(props);
			output.flush;
			props_conduit.close;

			log.trace("wait to exit");

			throw ex;
		}
		catch(Exception ex)
		{
			throw ex;
		}
	}

	public void logginTriple(char command, char[] s, char[] p, char[] o)
	{
		auto layout = new Locale;

		auto tm = WallClock.now;
		auto dt = Clock.toDate(tm);
		char[] tmp1 = new char[35 + s.length + p.length + o.length];
		char[18] tmp;

		auto actual_log_path = layout("data/authorize-data-{:yyyy-MM-dd}.n3log", WallClock.now);
		if(actual_log_path != log_path || log_file is null)
		{

			log_path = actual_log_path;

			if(log_file !is null)
			{
				log_file.close;
			}

			auto style = File.ReadWriteOpen;
			style.share = File.Share.Read;
			style.open = File.Open.Append;
			log_file = new File(log_path, style);
		}

		// так сделано из невозможности задать параметр из двух цифр в Util.layout
		if(command == 'A')
		{
			auto now = Util.layout(tmp1, "%0-%1-%2 %3:%4:%5,%6 A <%7><%8>\"%9\" .\n", convert(tmp[0 .. 4], dt.date.year), convert(tmp[6 .. 8],
					dt.date.month), convert(tmp[4 .. 6], dt.date.day), convert(tmp[8 .. 10], dt.time.hours), convert(tmp[10 .. 12], dt.time.minutes),
					convert(tmp[12 .. 14], dt.time.seconds), convert(tmp[14 .. 17], dt.time.millis), s, p, o);

			log_file.output.write(now);
		}
		else if(command == 'U')
		{
			auto now = Util.layout(tmp1, "%0-%1-%2 %3:%4:%5,%6 U <%7><%8>\"%9\" .\n", convert(tmp[0 .. 4], dt.date.year), convert(tmp[6 .. 8],
					dt.date.month), convert(tmp[4 .. 6], dt.date.day), convert(tmp[8 .. 10], dt.time.hours), convert(tmp[10 .. 12], dt.time.minutes),
					convert(tmp[12 .. 14], dt.time.seconds), convert(tmp[14 .. 17], dt.time.millis), s, p, o);

			log_file.output.write(now);
		}
		else if(command == 'D')
		{
			auto now = Util.layout(tmp1, "%0-%1-%2 %3:%4:%5,%6 D <%7><%8>\"%9\" .\n", convert(tmp[0 .. 4], dt.date.year), convert(tmp[6 .. 8],
					dt.date.month), convert(tmp[4 .. 6], dt.date.day), convert(tmp[8 .. 10], dt.time.hours), convert(tmp[10 .. 12], dt.time.minutes),
					convert(tmp[12 .. 14], dt.time.seconds), convert(tmp[14 .. 17], dt.time.millis), s, p, o);

			log_file.output.write(now);
		}
	}

	private char[] convert(char[] tmp, long i)
	{
		return Integer.formatter(tmp, i, 'u', '?', 8);
	}

	bool f_authorization_trace = false;

	// необходимые данные загружены, сделаем пробное выполнение скриптов для заданного пользователя
	public bool authorize(char* authorizedElementCategory, char* authorizedElementId, char* User, uint targetRightType,
			char*[] hierarhical_departments, mom_client from_client)
	{
		//		log.trace("autorize start, authorizedElementCategory={}, authorizedElementId={}, User={}", 
		//getString(authorizedElementCategory), getString(authorizedElementId), getString(User));
		bool calculatedRight;

		bool isAdmin = scripts.S01UserIsAdmin.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments);

		if(f_authorization_trace)
		{
			// 			log.trace("autorize:S01UserIsAdmin res={}", isAdmin);
		}
		bool result;
		if(strcmp(authorizedElementCategory, Category.PERMISSION.ptr) == 0)
		{
			calculatedRight = scripts.S10UserIsPermissionTargetAuthor.calculate(User, authorizedElementId, targetRightType, ts);

			result = isAdmin || calculatedRight;

			if(f_authorization_trace)
			{
				//log.trace("autorize: isAdmin || calculatedRight res={}", result);				
			}

			return result;
		}

		int is_in_docflow = -1;
		if((targetRightType == RightType.UPDATE || targetRightType == RightType.DELETE || targetRightType == RightType.WRITE) && strcmp(
				authorizedElementCategory, Category.DOCUMENT.ptr) == 0)
		{
			//log.trace("#udw, category = DOCUMENT");
			is_in_docflow = scripts.S05InDocFlow.calculate(User, authorizedElementId, targetRightType, ts);
			if(is_in_docflow == 1)
			{
				//counters[1]++;
				return true;
			}
			else if(is_in_docflow == 0)
			{
				//counters[2]++;
				return scripts.S01UserIsAdmin.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments);
			}
		}

		if(targetRightType == RightType.CREATE && (strcmp(authorizedElementCategory, Category.DOCUMENT.ptr) == 0 || (*authorizedElementId == '*' && strcmp(
				authorizedElementCategory, Category.DOCUMENT_TEMPLATE.ptr) == 0)))

		{
			if(scripts.S01AllLoggedUsersCanCreateDocuments.calculate(User, authorizedElementId, targetRightType, ts))
			{
				//counters[3]++;
				return true;
			}
			////log.trace("autorize end#0, return:[{}]", calculatedRight);
		}

		result = strcmp(authorizedElementCategory, Category.DOCUMENT.ptr) == 0 && scripts.S09DocumentOfTemplate.calculate(User, authorizedElementId,
				targetRightType, ts, hierarhical_departments, pp);
		//		log.trace("S09DocumentOfTemplate result = {}", result);
		if(result)
		{
			//counters[4]++;
			return true;
		}

		triple_list_element* iterator_facts_of_document = ts.getTriples(authorizedElementId, null, null);
		if(strcmp("null", authorizedElementId) != 0 && iterator_facts_of_document is null && strcmp(authorizedElementCategory, Category.DOCUMENT.ptr) == 0)
		{
			//			log.trace("iterator_facts_of_document [s={}] is null", getString(subject_document));
			//log.trace("autorize end#2, return:[false]");
			//counters[5]++;
			return false;
		}

		if(scripts.S11ACLRightsHierarhical.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments, pp,
				authorizedElementCategory))
		{
			//counters[6]++;
			return true;
			//log.trace("authorize:S09DocumentOfTemplate res={}", calculatedRight);
		}
		//log.trace("authorize:S11ACLRightsHierarhical res={}", calculatedRight);

		if(scripts.S10UserIsAuthorOfDocument.calculate(User, authorizedElementId, targetRightType, ts, iterator_facts_of_document))
		{
			//counters[7]++;
			return true;
		}
		//log.trace("authorize:S10UserIsAuthorOfDocument res={}", calculatedRight);

		if(isAdmin)
		{
			return true;
		}

		//		log.trace("Access Denied");

		return false;
		//		bool is_doc_or_draft = (strcmp(authorizedElementCategory, Category.DOCUMENT.ptr) == 0 || strcmp(authorizedElementCategory, Category.DOCUMENT_DRAFT.ptr) == 0);

		//log.trace("autorize end#3, return:[{}]", calculatedRight);
		//counters[8]++;
		//		log.trace("# {} {} {} {} {} {} {} {} {}",  counters[0], counters[1], counters[2], counters[3], counters[4], counters[5], counters[6], counters[7], counters[8]);
	}

	public void getAuthorizationRightRecords(char*[] fact_s, char*[] fact_p, char*[] fact_o, uint count_facts, char* result_buffer,
			mom_client from_client)
	//, mom_client client)
	{

		log.trace("запрос на выборку записей прав");

		auto elapsed = new StopWatch();

		char* queue_name = cast(char*) (new char[40]);

		int authorize_id = 0;
		int from_id = 0;

		int author_system_id = 0;
		int author_subsystem_id = 0;
		int author_subsystem_element_id = 0;
		int target_system_id = 0;
		int target_subsystem_id = 0;
		int target_subsystem_element_id = 0;
		int category_id = 0;
		int elements_id = 0;
		int reply_to_id = 0;

		char* result_ptr = cast(char*) result_buffer;
		char* command_uid = fact_s[0];

		byte patterns_cnt = 0;

		for(int i = 0; i < count_facts; i++)
		{
			if(strlen(fact_o[i]) > 0)
			{
				/*				log.trace("pattern predicate = '{}'. pattern object = '{}' with length = {}", 
				 getString(fact_p[i]), getString(fact_o[i]), strlen(fact_o[i]));*/
				if(strcmp(fact_p[i], SET_FROM.ptr) == 0)
				{
					from_id = i;
				}
				else if(strcmp(fact_p[i], AUTHOR_SYSTEM.ptr) == 0)
				{
					patterns_cnt++;
					author_system_id = i;
				}
				else if(strcmp(fact_p[i], AUTHOR_SUBSYSTEM.ptr) == 0)
				{
					patterns_cnt++;
					author_subsystem_id = i;
				}
				else if(strcmp(fact_p[i], AUTHOR_SUBSYSTEM_ELEMENT.ptr) == 0)
				{
					patterns_cnt++;
					author_subsystem_element_id = i;
				}
				else if(strcmp(fact_p[i], TARGET_SYSTEM.ptr) == 0)
				{
					patterns_cnt++;
					target_system_id = i;
				}
				else if(strcmp(fact_p[i], TARGET_SUBSYSTEM.ptr) == 0)
				{
					patterns_cnt++;
					target_subsystem_id = i;
				}
				else if(strcmp(fact_p[i], TARGET_SUBSYSTEM_ELEMENT.ptr) == 0)
				{
					patterns_cnt++;
					target_subsystem_element_id = i;
				}
				else if(strcmp(fact_p[i], CATEGORY.ptr) == 0)
				{
					patterns_cnt++;
					category_id = i;
				}
				else if(strcmp(fact_p[i], ELEMENT_ID.ptr) == 0)
				{
					patterns_cnt++;
					elements_id = i;
				}
				else if(strcmp(fact_p[i], REPLY_TO.ptr) == 0)
				{
					reply_to_id = i;
				}
			}
		}

		//		uint* SET = ts.getTriples("6fcb52fc46889ba8", null, null);
		//		fact_tools.print_list_triple(SET);

		triple_list_element* start_facts_set = null;
		byte start_set_marker = 0;
		if(elements_id > 0)
		{
			log.trace("object = {}", getString(fact_o[elements_id]));
			start_facts_set = cast(triple_list_element*) ts.getTriples(null, ELEMENT_ID.ptr, fact_o[elements_id]);
		}
		else if(author_subsystem_element_id > 0)
		{
			start_set_marker = 1;
			start_facts_set = cast(triple_list_element*) ts.getTriples(null, null, fact_o[author_subsystem_element_id]);
		}
		else if(target_subsystem_element_id > 0)
		{
			start_set_marker = 2;
			start_facts_set = cast(triple_list_element*) ts.getTriples(null, null, fact_o[target_subsystem_element_id]);
		}
		else if(category_id > 0)
		{
			start_set_marker = 3;
			start_facts_set = cast(triple_list_element*) ts.getTriples(null, null, fact_o[category_id]);
		}
		else if(author_subsystem_id > 0)
		{
			start_set_marker = 4;
			start_facts_set = cast(triple_list_element*) ts.getTriples(null, null, fact_o[author_subsystem_id]);
		}
		else if(target_subsystem_id > 0)
		{
			start_set_marker = 5;
			start_facts_set = cast(triple_list_element*) ts.getTriples(null, null, fact_o[target_subsystem_id]);
		}
		else if(author_system_id > 0)
		{
			start_set_marker = 6;
			start_facts_set = cast(triple_list_element*) ts.getTriples(null, null, fact_o[author_system_id]);
		}
		else if(target_system_id > 0)
		{
			start_set_marker = 7;
			start_facts_set = cast(triple_list_element*) ts.getTriples(null, null, fact_o[target_system_id]);
		}

		log.trace("elements_id = {}, author_subsystem_element_id = {}, target_subsystem_element_id = {}", elements_id, author_subsystem_element_id,
				target_subsystem_element_id);
		log.trace("category_id = {}, author_subsystem_id = {}, target_subsystem_id = {}, author_system_id = {}, target_system_id = {}", category_id,
				author_subsystem_id, target_subsystem_id, author_system_id, target_system_id);
		log.trace("start_set_marker = {}", start_set_marker);

		strcpy(queue_name, fact_o[reply_to_id]);

		*result_ptr = '<';
		strcpy(result_ptr + 1, command_uid);
		result_ptr += strlen(command_uid) + 1;
		strcpy(result_ptr, result_data_header_with_bracets.ptr);
		result_ptr += result_data_header_with_bracets.length;

		if(start_facts_set !is null)
		{
			while(start_facts_set !is null)
			{
				byte* triple = cast(byte*) start_facts_set.triple_ptr;
				//				log.trace("# get_authorization_rights_records : triple = {:X4}", triple);

				if(triple !is null)
				{
					char* s = cast(char*) triple + 6;

					triple_list_element* founded_facts = cast(triple_list_element*) ts.getTriples(s, null, null);
					triple_list_element* founded_facts_copy = founded_facts;
					if(founded_facts !is null)
					{
						bool is_match = true;
						byte checked_patterns_cnt = 1;
						while(founded_facts !is null)
						{

							byte* triple1 = cast(byte*) founded_facts.triple_ptr;

							if(triple1 !is null)
							{

								char* p1 = cast(char*) (triple1 + 6 + (*(triple1 + 0) << 8) + *(triple1 + 1) + 1);
								char*
										o1 = cast(char*) (triple1 + 6 + (*(triple1 + 0) << 8) + *(triple1 + 1) + 1 + (*(triple1 + 2) << 8) + *(triple1 + 3) + 1);

								if(start_set_marker < 1 && author_subsystem_element_id > 0 && strcmp(p1, AUTHOR_SUBSYSTEM_ELEMENT.ptr) == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[author_subsystem_element_id]) == 0;
								}
								if(start_set_marker < 2 && target_subsystem_element_id > 0 && strcmp(p1, TARGET_SUBSYSTEM_ELEMENT.ptr) == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[target_subsystem_element_id]) == 0;
								}
								if(start_set_marker < 3 && category_id > 0 && strcmp(p1, CATEGORY.ptr) == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[category_id]) == 0;
								}
								if(start_set_marker < 4 && author_subsystem_id > 0 && strcmp(p1, AUTHOR_SUBSYSTEM.ptr) == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[author_subsystem_id]) == 0;
								}
								if(start_set_marker < 5 && target_subsystem_id > 0 && strcmp(p1, TARGET_SUBSYSTEM.ptr) == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[target_subsystem_id]) == 0;
								}
								if(start_set_marker < 6 && author_system_id > 0 && strcmp(p1, AUTHOR_SYSTEM.ptr) == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[author_system_id]) == 0;
								}
								if(start_set_marker < 7 && target_system_id > 0 && strcmp(p1, TARGET_SYSTEM.ptr) == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[target_system_id]) == 0;
								}

							}

							founded_facts = founded_facts.next_triple_list_element;

						}

						//						log.trace("is_match = {} checked_patterns_cnt = {} patterns_cnt = {} ", is_match, checked_patterns_cnt, patterns_cnt);

						if(is_match && checked_patterns_cnt == patterns_cnt)
						{
							//log.trace("found match");
							while(founded_facts_copy !is null)
							{
								byte* triple1 = cast(byte*) founded_facts_copy.triple_ptr;
								//log.trace("#3");
								if(triple1 !is null)
								{
									//log.trace("...not null");
									char* p1 = cast(char*) (triple1 + 6 + (*(triple1 + 0) << 8) + *(triple1 + 1) + 1);
									char*
											o1 = cast(char*) (triple1 + 6 + (*(triple1 + 0) << 8) + *(triple1 + 1) + 1 + (*(triple1 + 2) << 8) + *(triple1 + 3) + 1);

									strcpy(result_ptr++, "<");
									strcpy(result_ptr, s);
									result_ptr += strlen(s);
									strcpy(result_ptr, "><");
									result_ptr += 2;
									strcpy(result_ptr, p1);
									result_ptr += strlen(p1);
									strcpy(result_ptr, ">\"");
									result_ptr += 2;
									strcpy(result_ptr, o1);
									result_ptr += strlen(o1);
									strcpy(result_ptr, "\".");
									result_ptr += 2;
								}

								founded_facts_copy = founded_facts_copy.next_triple_list_element;
							}
						}

						if(strlen(result_buffer) > 10000)
						{
							strcpy(result_ptr, "}.\0");

							send_result_and_logging_messages(queue_name, result_buffer, from_client);

							//							client.send(queue_name, result_buffer);

							result_ptr = cast(char*) result_buffer;

							*result_ptr = '<';
							strcpy(result_ptr + 1, command_uid);
							result_ptr += strlen(command_uid) + 1;
							strcpy(result_ptr, result_data_header_with_bracets.ptr);
							result_ptr += result_data_header_with_bracets.length;

						}
					}
				}
				start_facts_set = start_facts_set.next_triple_list_element;
			}

		}

		strcpy(result_ptr, "}.<");
		result_ptr += 3;
		strcpy(result_ptr, command_uid);
		result_ptr += strlen(command_uid);
		strcpy(result_ptr, result_state_ok_header.ptr);
		result_ptr += result_state_ok_header.length;
		*(result_ptr - 1) = 0;

		strcpy(queue_name, fact_o[reply_to_id]);

		send_result_and_logging_messages(queue_name, result_buffer, from_client);

		//		client.send(queue_name, result_buffer);

		double time = elapsed.stop;
		log.trace("get authorization rights records time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
		log.trace("result:{}\n sent to: {}", getString(result_buffer), getString(queue_name));

	}

	public void getDelegateAssignersTree(char*[] fact_s, char*[] fact_p, char*[] fact_o, int arg_id, uint count_facts, char* result_buffer,
			mom_client from_client)
	{

		log.trace("команда на выборку делегировавших");

		auto elapsed = new StopWatch();
		elapsed.start;

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

		char* queue_name = cast(char*) (new char[40]);
		strcpy(queue_name, fact_o[reply_to_id]);

		//log.trace("#1 gda");

		char* result_ptr = cast(char*) result_buffer;
		char* command_uid = fact_s[0];
		strcpy(queue_name, fact_o[reply_to_id]);

		*result_ptr = '<';
		strcpy(result_ptr + 1, command_uid);
		result_ptr += strlen(command_uid) + 1;
		strcpy(result_ptr, result_data_header.ptr);
		result_ptr += result_data_header.length;

		void put_in_result(char* founded_delegate)
		{
			strcpy(result_ptr++, ",");
			strcpy(result_ptr, founded_delegate);
			result_ptr += strlen(founded_delegate);
		}

		getDelegateAssignersForDelegate(fact_o[arg_id], ts, &put_in_result);

		strcpy(result_ptr, "\".<");
		result_ptr += 3;
		strcpy(result_ptr, command_uid);
		result_ptr += strlen(command_uid);
		strcpy(result_ptr, result_state_ok_header.ptr);
		result_ptr += result_state_ok_header.length;
		*(result_ptr - 1) = 0;

		//		client.send(queue_name, result_buffer);
		send_result_and_logging_messages(queue_name, result_buffer, from_client);

		double time = elapsed.stop;
		log.trace("get delegate assigners time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
		log.trace("result:{} \nsent to:{}", getString(result_buffer), getString(queue_name));

	}

}
