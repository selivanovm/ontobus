module authorization;

private import tango.io.Stdout;
private import tango.stdc.string;

//import Integer = tango.text.convert.Integer;
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
private import scripts.S10UserIsAuthorOfDocument;
private import scripts.S11ACLRightsHierarhical;
private import scripts.S20UserIsInOUP;
private import scripts.S30UsersOfDocumentum;
private import scripts.S40UsersOfTAImport;

private import RightTypeDef;
private import script_util;

private import persistent_triple_storage;

private import fact_tools;
private import Log;

private import HashMap;
private import TripleStorage;

//private import mom_client;

private import server;

class Authorization
{
	private char[][] i_know_predicates;
	private TripleStorage ts = null;

	this()
	{
		i_know_predicates = new char[][48];

		uint d = 0;

		// общая онтология
		i_know_predicates[d++] = "magnet-ontology#put"; //
		i_know_predicates[d++] = "magnet-ontology#get"; //
		i_know_predicates[d++] = "magnet-ontology#delete"; //
		i_know_predicates[d++] = "magnet-ontology#delete_by_subject";
		i_know_predicates[d++] = "magnet-ontology#delete_subjects_by_predicate";

		i_know_predicates[d++] = "magnet-ontology/subject"; //
		i_know_predicates[d++] = "magnet-ontology/argument"; //
		i_know_predicates[d++] = "magnet-ontology/result"; //
		i_know_predicates[d++] = "magnet-ontology/state"; //
		i_know_predicates[d++] = "magnet-ontology/data"; //
		i_know_predicates[d++] = "magnet-ontology/transport#set_from"; //
		i_know_predicates[d++] = "magnet-ontology/transport/message#reply_to"; // имя очереди для ответа на сообщение

		// онтология authorization

		//		 функции авторизации
		i_know_predicates[d++] = "magnet-ontology/authorization/functions#create"; //
		i_know_predicates[d++] = "magnet-ontology/authorization/functions#update"; //
		i_know_predicates[d++] = "magnet-ontology/authorization/functions#get_authorization_rights_records"; //
		i_know_predicates[d++] = "magnet-ontology/authorization/functions#is_in_docflow"; //
		i_know_predicates[d++] = "magnet-ontology/authorization/functions#is_admin"; //
		i_know_predicates[d++] = "magnet-ontology/authorization/functions#get_delegate_assigners"; //
		i_know_predicates[d++] = "magnet-ontology/authorization/functions#get_delegate_assigners_tree"; //
		i_know_predicates[d++] = "magnet-ontology/authorization/functions#authorize"; //

		//		 функции делегирования
		i_know_predicates[d++] = "magnet-ontology/authorization/functions#remove_delegate"; //
		i_know_predicates[d++] = "magnet-ontology/authorization/functions#add_delegates"; //
		i_know_predicates[d++] = "magnet-ontology/authorization/functions#get_delegate_assigners"; //
		i_know_predicates[d++] = "magnet-ontology/authorization/functions#get_delegate_assigners_tree"; //

		//		 запись о праве, данная часть ACL требует переработки!
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#authorSystem"; //                         - система выдающая право, "BA"/"DOCFLOW"
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#authorSubsystem"; //                 - "user"/routeName
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#authorSubsystemElement"; // - id user or id route.
		//?		i_know_predicates[d++] = "magnet-ontology/authorization/acl#targetSystem"; //                   - система, для которой выдали права, "BA"/"DOCFLOW".
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#targetSubsystem"; //                 - "user"/"department".
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#targetSubsystemElement"; // - user id or department id.

		i_know_predicates[d++] = "magnet-ontology/authorization/acl#category"; //                                 - категория элемента, на который выдаются права (DOCUMENT, DOCUMENTTYPE, DICTIONARY и т. д.).
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#dateFrom"; //                                 - период действия прав (до (с возможностью указания открытых интервалов значение null)).
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#dateTo"; //                                 - период действия прав (от (с возможностью указания открытых интервалов- значение null)).
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#elementId"; //                                 - идентификатор элемента, на который выдаются права.
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#rights"; //                                 - "c|r|u|d"

		//		 запись о делегировании
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#delegate"; // - кому делегируют
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#owner"; // - кто делегирует
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#withTree"; // - делегировать с учетом дерева делегатов

		// document
		i_know_predicates[d++] = "http://purl.org/dc/elements/1.1/creator"; // - создатель объекта(документа, типа документа, справочника)
		i_know_predicates[d++] = "magnet-ontology#subject";
		i_know_predicates[d++] = "magnet-ontology#typeName";

		// ORGANIZATION
		i_know_predicates[d++] = "magnet-ontology#hasPart";
		i_know_predicates[d++] = "magnet-ontology#memberOf";
		i_know_predicates[d++] = "magnet-ontology#loginName";

		i_know_predicates[d++] = "magnet-ontology/documents#type_name";

		init();
	}

	public TripleStorage getTripleStorage()
	{
		return ts;
	}

	private char[] pp = null;

	private void init()
	{
		log.trace("authorization init..");
		Stdout.format("authorization init..").newline;

		//		ts = new TripleStorage(idx_name.S | idx_name.SP | idx_name.PO | idx_name.SPO | idx_name.O | idx_name.S1PPOO, 1_200_000, 20, 1024 * 1024 * 100);
		ts = new TripleStorage(2_000_000, 9, 1024 * 1024 * 250);
		ts.set_new_index(idx_name.S, 500_000, 6, 1024 * 1024 * 40);
		ts.set_new_index(idx_name.O, 500_000, 6, 1024 * 1024 * 20);
		ts.set_new_index(idx_name.PO, 1_000_000, 9, 1024 * 1024 * 40);
		ts.set_new_index(idx_name.SP, 2_000_000, 9, 1024 * 1024 * 150);
		ts.set_new_index(idx_name.S1PPOO, 500_000, 6, 1024 * 1024 * 40);

		ts.setPredicatesToS1PPOO("magnet-ontology/authorization/acl#targetSubsystemElement", "magnet-ontology/authorization/acl#elementId",
				"magnet-ontology/authorization/acl#rights");

		pp = "magnet-ontology/authorization/acl#targetSubsystemElement" ~ "magnet-ontology/authorization/acl#elementId";
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

		foreach(file; scan.files)
		{
			log.trace("{}\n", file);
			load_from_file(file, i_know_predicates, ts);
		}
		log.trace("\n{} Errors", scan.errors.length);
		foreach(error; scan.errors)
			log.trace(error);

		//		print_list_triple(ts.getTriples("record", null, null, false));

		//		ts.removeTriple("record", "magnet-ontology#target", "92e57b6d-83e3-485f-8885-0bade363f759");

		//		print_list_triple(ts.getTriples("record", null, null, false));

		log.trace("authorization init ... ok");
		Stdout.format("authorization init.. ok").newline;
	}

	public void logginTriple(char command, char[] s, char[] p, char[] o)
	{
		auto layout = new Locale;
		//		auto nameFile = layout("data/authorize-data-{:yyyy-MM-dd}.n3log", WallClock.now);
		//		auto file = new File(nameFile, File.WriteAppending);

		auto tm = WallClock.now;
		auto dt = Clock.toDate(tm);
		char[] tmp1 = new char[35 + s.length + p.length + o.length];
		char[18] tmp;

		// так сделано из невозможности задать параметр из двух цифр в Util.layout
		if(command == 'A')
		{
			auto now = Util.layout(tmp1, "%0-%1-%2 %3:%4:%5,%6 A <%7><%8>\"%9\" .\n", convert(tmp[0 .. 4], dt.date.year), convert(tmp[4 .. 6],
					dt.date.day), convert(tmp[6 .. 8], dt.date.month), convert(tmp[8 .. 10], dt.time.hours), convert(tmp[10 .. 12], dt.time.minutes),
					convert(tmp[12 .. 14], dt.time.seconds), convert(tmp[14 .. 17], dt.time.millis), s, p, o);

			File.append(layout("data/authorize-data-{:yyyy-MM-dd}.n3log", WallClock.now), now);
		}
		else if(command == 'U')
		{
			auto now = Util.layout(tmp1, "%0-%1-%2 %3:%4:%5,%6 U <%7><%8>\"%9\" .\n", convert(tmp[0 .. 4], dt.date.year), convert(tmp[4 .. 6],
					dt.date.day), convert(tmp[6 .. 8], dt.date.month), convert(tmp[8 .. 10], dt.time.hours), convert(tmp[10 .. 12], dt.time.minutes),
					convert(tmp[12 .. 14], dt.time.seconds), convert(tmp[14 .. 17], dt.time.millis), s, p, o);

			File.append(layout("data/authorize-data-{:yyyy-MM-dd}.n3log", WallClock.now), now);
		}
		else if(command == 'D')
		{
			auto now = Util.layout(tmp1, "%0-%1-%2 %3:%4:%5,%6 D <%7><%8>\"%9\" .\n", convert(tmp[0 .. 4], dt.date.year), convert(tmp[4 .. 6],
					dt.date.day), convert(tmp[6 .. 8], dt.date.month), convert(tmp[8 .. 10], dt.time.hours), convert(tmp[10 .. 12], dt.time.minutes),
					convert(tmp[12 .. 14], dt.time.seconds), convert(tmp[14 .. 17], dt.time.millis), s, p, o);

			File.append(layout("data/authorize-data-{:yyyy-MM-dd}.n3log", WallClock.now), now);
		}
	}

	private char[] convert(char[] tmp, long i)
	{
		return Integer.formatter(tmp, i, 'u', '?', 8);
	}

	// необходимые данные загружены, сделаем пробное выполнение скриптов для заданного пользователя
	public bool authorize(char* authorizedElementCategory, char* authorizedElementId, char* User, uint targetRightType,
			char*[] hierarhical_departments)
	{
		//		log.trace("autorize start, authorizedElementCategory={}, authorizedElementId={}, User={}", getString(authorizedElementCategory), getString(
		//				authorizedElementId), getString(User));
		bool calculatedRight;

		if(strcmp(authorizedElementCategory, "PERMISSION") == 0)
			return scripts.S01UserIsAdmin.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments) || scripts.S10UserIsPermissionTargetAuthor.calculate(
					User, authorizedElementId, targetRightType, ts);

		int is_in_docflow = -1;
		if((targetRightType == RightType.UPDATE || targetRightType == RightType.DELETE || targetRightType == RightType.WRITE) && strcmp(
				authorizedElementCategory, "DOCUMENT") == 0)
		{
			is_in_docflow = scripts.S05InDocFlow.calculate(User, authorizedElementId, targetRightType, ts);
			if(is_in_docflow == 1)
				return true;
			else if(is_in_docflow == 0)
				return scripts.S01UserIsAdmin.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments);
		}

		if(targetRightType == RightType.CREATE && (strcmp(authorizedElementCategory, "DOCUMENT") == 0 || (*authorizedElementId == '*' && (strcmp(
				authorizedElementCategory, "DOCUMENTTYPE") == 0 || strcmp(authorizedElementCategory, "DICTIONARY") == 0))))

		{

			calculatedRight = scripts.S01AllLoggedUsersCanCreateDocuments.calculate(User, authorizedElementId, targetRightType, ts);
			//log.trace("autorize end#0, return:[{}]", calculatedRight);
		}

		if(calculatedRight == true)
		{
			//log.trace("autorize end#1, return:[{}]", calculatedRight);
			return calculatedRight;
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S11ACLRightsHierarhical.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments, pp);
			//log.trace("authorize:S11ACLRightsHierarhical res={}", calculatedRight);
		}

		//		if(calculatedRight == false)
		//		{
		//			calculatedRight = scripts.S05InDocFlow.calculate(User, authorizedElementId, targetRightType, ts);
		//log.trace("authorize:S05InDocFlow res={}", calculatedRight);
		//		}

		if(scripts.S01UserIsAdmin.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments))
		{
			//log.trace("# User Is Admin");
			return true;
		}

			//log.trace("# User Is not Admin");

		uint* iterator_facts_of_document = ts.getTriples(authorizedElementId, null, null);

		if(iterator_facts_of_document is null && strcmp(authorizedElementCategory, "DOCUMENT") == 0)
		{
			//			log.trace("iterator_facts_of_document [s={}] is null", getString(subject_document));
			//log.trace("autorize end#2, return:[false]");
			return false;
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S10UserIsAuthorOfDocument.calculate(User, authorizedElementId, targetRightType, ts, iterator_facts_of_document);
			//log.trace("authorize:S10UserIsAuthorOfDocument res={}", calculatedRight);
		}

		bool is_doc_or_draft = (strcmp(authorizedElementCategory, "DOCUMENT") == 0 || strcmp(authorizedElementCategory, "DOCUMENT_DRAFT") == 0);
		if(calculatedRight == false && is_doc_or_draft)
		{
			calculatedRight = scripts.S20UserIsInOUP.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments);
			//log.trace("authorize:S20UserIsInOUP res={}", calculatedRight);
		}

		if(calculatedRight == false && is_doc_or_draft)
		{
			calculatedRight = scripts.S30UsersOfDocumentum.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments);
			//log.trace("authorize:S30UsersOfDocumentum res={}", calculatedRight);
		}

		if(calculatedRight == false && is_doc_or_draft)
		{
			calculatedRight = scripts.S40UsersOfTAImport.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments);
			//log.trace("authorize:S40UsersOfTAImport res={}", calculatedRight);
		}

		if(calculatedRight == false && is_doc_or_draft)
		{
			calculatedRight = scripts.S50UserOfTORO.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments);
			//log.trace("authorize:S50UserOfTORO res={}", calculatedRight);
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S01UserIsAdmin.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments);
		}

		//log.trace("autorize end#3, return:[{}]", calculatedRight);
		return calculatedRight;
	}

	public void getAuthorizationRightRecords(char*[] fact_s, char*[] fact_p, char*[] fact_o, uint count_facts, char* result_buffer)
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
				log.trace("pattern predicate = '{}'. pattern object = '{}' with length = {}", getString(fact_p[i]), getString(fact_o[i]), strlen(
						fact_o[i]));
				if(strcmp(fact_p[i], "magnet-ontology/transport#set_from") == 0)
				{
					from_id = i;
				}
				else if(strcmp(fact_p[i], "magnet-ontology/authorization/acl#authorSystem") == 0)
				{
					patterns_cnt++;
					author_system_id = i;
				}
				else if(strcmp(fact_p[i], "magnet-ontology/authorization/acl#authorSubsystem") == 0)
				{
					patterns_cnt++;
					author_subsystem_id = i;
				}
				else if(strcmp(fact_p[i], "magnet-ontology/authorization/acl#authorSubsystemElement") == 0)
				{
					patterns_cnt++;
					author_subsystem_element_id = i;
				}
				else if(strcmp(fact_p[i], "magnet-ontology/authorization/acl#targetSystem") == 0)
				{
					patterns_cnt++;
					target_system_id = i;
				}
				else if(strcmp(fact_p[i], "magnet-ontology/authorization/acl#targetSubsystem") == 0)
				{
					patterns_cnt++;
					target_subsystem_id = i;
				}
				else if(strcmp(fact_p[i], "magnet-ontology/authorization/acl#targetSubsystemElement") == 0)
				{
					patterns_cnt++;
					target_subsystem_element_id = i;
				}
				else if(strcmp(fact_p[i], "magnet-ontology/authorization/acl#category") == 0)
				{
					patterns_cnt++;
					category_id = i;
				}
				else if(strcmp(fact_p[i], "magnet-ontology/authorization/acl#elementId") == 0)
				{
					patterns_cnt++;
					elements_id = i;
				}
				else if(strcmp(fact_p[i], "magnet-ontology/transport/message#reply_to") == 0)
				{
					reply_to_id = i;
				}
			}
		}

		uint* start_facts_set = null;
		byte start_set_marker = 0;
		if(elements_id > 0)
		{
			log.trace("object = {}", getString(fact_o[elements_id]));
			start_facts_set = ts.getTriples(null, null, fact_o[elements_id]);
		}
		else if(author_subsystem_element_id > 0)
		{
			start_set_marker = 1;
			start_facts_set = ts.getTriples(null, null, fact_o[author_subsystem_element_id]);
		}
		else if(target_subsystem_element_id > 0)
		{
			start_set_marker = 2;
			start_facts_set = ts.getTriples(null, null, fact_o[target_subsystem_element_id]);
		}
		else if(category_id > 0)
		{
			start_set_marker = 3;
			start_facts_set = ts.getTriples(null, null, fact_o[category_id]);
		}
		else if(author_subsystem_id > 0)
		{
			start_set_marker = 4;
			start_facts_set = ts.getTriples(null, null, fact_o[author_subsystem_id]);
		}
		else if(target_subsystem_id > 0)
		{
			start_set_marker = 5;
			start_facts_set = ts.getTriples(null, null, fact_o[target_subsystem_id]);
		}
		else if(author_system_id > 0)
		{
			start_set_marker = 6;
			start_facts_set = ts.getTriples(null, null, fact_o[author_system_id]);
		}
		else if(target_system_id > 0)
		{
			start_set_marker = 7;
			start_facts_set = ts.getTriples(null, null, fact_o[target_system_id]);
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
		strcpy(result_ptr, "><magnet-ontology/transport#result:data>{");
		result_ptr += 41;

		if(start_facts_set !is null)
		{
			uint next_element0 = 0xFF;
			while(next_element0 > 0)
			{
				byte* triple = cast(byte*) *start_facts_set;
				if(triple !is null)
				{
					char* s = cast(char*) triple + 6;

					uint* founded_facts = ts.getTriples(s, null, null);
					uint* founded_facts_copy = founded_facts;
					if(founded_facts !is null)
					{
						uint next_element1 = 0xFF;
						bool is_match = true;
						byte checked_patterns_cnt = 1;
						while(next_element1 > 0)

						{

							byte* triple1 = cast(byte*) *founded_facts;

							if(triple1 !is null)
							{

								char* p1 = cast(char*) (triple1 + 6 + (*(triple1 + 0) << 8) + *(triple1 + 1) + 1);
								char*
										o1 = cast(char*) (triple1 + 6 + (*(triple1 + 0) << 8) + *(triple1 + 1) + 1 + (*(triple1 + 2) << 8) + *(triple1 + 3) + 1);

								if(start_set_marker < 1 && author_subsystem_element_id > 0 && strcmp(p1,
										"magnet-ontology/authorization/acl#authorSubsystemElement") == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[author_subsystem_element_id]) == 0;
								}
								if(start_set_marker < 2 && target_subsystem_element_id > 0 && strcmp(p1,
										"magnet-ontology/authorization/acl#targetSubsystemElement") == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[target_subsystem_element_id]) == 0;
								}
								if(start_set_marker < 3 && category_id > 0 && strcmp(p1, "magnet-ontology/authorization/acl#category") == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[category_id]) == 0;
								}
								if(start_set_marker < 4 && author_subsystem_id > 0 && strcmp(p1, "magnet-ontology/authorization/acl#authorSubsystem") == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[author_subsystem_id]) == 0;
								}
								if(start_set_marker < 5 && target_subsystem_id > 0 && strcmp(p1, "magnet-ontology/authorization/acl#targetSubsystem") == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[target_subsystem_id]) == 0;
								}
								if(start_set_marker < 6 && author_system_id > 0 && strcmp(p1, "magnet-ontology/authorization/acl#authorSystem") == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[author_system_id]) == 0;
								}
								if(start_set_marker < 7 && target_system_id > 0 && strcmp(p1, "magnet-ontology/authorization/acl#targetSystem") == 0)
								{
									checked_patterns_cnt++;
									is_match = is_match & strcmp(o1, fact_o[target_system_id]) == 0;
								}

							}
							next_element1 = *(founded_facts + 1);
							founded_facts = cast(uint*) next_element1;

						}

						//log.trace("is_match = {} checked_patterns_cnt = {} patterns_cnt = {} ", is_match, checked_patterns_cnt, patterns_cnt);

						if(is_match && checked_patterns_cnt == patterns_cnt)
						{
							//log.trace("found match");
							next_element1 = 0xFF;
							while(next_element1 > 0)
							{
								byte* triple1 = cast(byte*) *founded_facts_copy;
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

								next_element1 = *(founded_facts_copy + 1);
								founded_facts_copy = cast(uint*) next_element1;
							}
						}

						if(strlen(result_buffer) > 10000)
						{
							strcpy(result_ptr, "}.\0");

							send_result_and_logging_messages(queue_name, result_buffer);

							//							client.send(queue_name, result_buffer);

							result_ptr = cast(char*) result_buffer;

							*result_ptr = '<';
							strcpy(result_ptr + 1, command_uid);
							result_ptr += strlen(command_uid) + 1;
							strcpy(result_ptr, "><magnet-ontology/transport#result:data>{");
							result_ptr += 41;

						}
					}
				}
				next_element0 = *(start_facts_set + 1);
				start_facts_set = cast(uint*) next_element0;
			}

		}

		strcpy(result_ptr, "}.<");
		result_ptr += 3;
		strcpy(result_ptr, command_uid);
		result_ptr += strlen(command_uid);
		strcpy(result_ptr, "><magnet-ontology/transport#result:state>\"ok\".\0");

		strcpy(queue_name, fact_o[reply_to_id]);

		send_result_and_logging_messages(queue_name, result_buffer);

		//		client.send(queue_name, result_buffer);

		double time = elapsed.stop;
		log.trace("get authorization rights records time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
		log.trace("result:{}\n sent to: {}", getString(result_buffer), getString(queue_name));

	}

	public void getDelegateAssignersTree(char*[] fact_s, char*[] fact_p, char*[] fact_o, int arg_id, uint count_facts, char* result_buffer)
	//,
	//			mom_client client)
	{

		log.trace("команда на выборку делегировавших");

		auto elapsed = new StopWatch();
		elapsed.start;

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

		char* queue_name = cast(char*) (new char[40]);
		strcpy(queue_name, fact_o[reply_to_id]);

		//log.trace("#1 gda");

		char* result_ptr = cast(char*) result_buffer;
		char* command_uid = fact_s[0];
		strcpy(queue_name, fact_o[reply_to_id]);

		*result_ptr = '<';
		strcpy(result_ptr + 1, command_uid);
		result_ptr += strlen(command_uid) + 1;
		strcpy(result_ptr, "><magnet-ontology/transport#result:data>\"");
		result_ptr += 41;

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
		strcpy(result_ptr, "><magnet-ontology/transport#result:state>\"ok\".\0");

		//		client.send(queue_name, result_buffer);
		send_result_and_logging_messages(queue_name, result_buffer);

		double time = elapsed.stop;
		log.trace("get delegate assigners time = {:d6} ms. ( {:d6} sec.)", time * 1000, time);
		log.trace("result:{} \nsent to:{}", getString(result_buffer), getString(queue_name));

	}

}
