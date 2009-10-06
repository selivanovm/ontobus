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

class Authorization
{
	private char[][] i_know_predicates;
	private TripleStorage ts = null;

	this()
	{
		i_know_predicates = new char[][47];

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
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#authorSystem"; // 			- система выдающая право, "BA"/"DOCFLOW"
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#authorSubsystem"; // 		- "user"/routeName
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#authorSubsystemElement"; // - id user or id route.
		//?		i_know_predicates[d++] = "magnet-ontology/authorization/acl#targetSystem"; // 			- система, для которой выдали права, "BA"/"DOCFLOW".
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#targetSubsystem"; // 		- "user"/"department".
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#targetSubsystemElement"; // - user id or department id.

		i_know_predicates[d++] = "magnet-ontology/authorization/acl#category"; // 				- категория элемента, на который выдаются права (DOCUMENT, DOCUMENTTYPE, DICTIONARY и т. д.).
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#dateFrom"; // 				- период действия прав (до (с возможностью указания открытых интервалов значение null)).
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#dateTo"; // 				- период действия прав (от (с возможностью указания открытых интервалов- значение null)).
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#elementId"; // 				- идентификатор элемента, на который выдаются права.
		i_know_predicates[d++] = "magnet-ontology/authorization/acl#rights"; // 				- "c|r|u|d"

		//		 запись о делегировании
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

		ts = new TripleStorage(idx_name.S | idx_name.SP | idx_name.PO | idx_name.SPO | idx_name.O | idx_name.S1PPOO, 1_200_000, 10, 1024 * 1024 * 60);

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

		ts.print_stat();
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

	// необходимые данные загружены, сделаем пробное выполнение скриптов для всех документов 
	public bool authorize(char* authorizedElementCategory, char* authorizedElementId, char* User, uint targetRightType,
			char*[] hierarhical_departments)
	{
		//		log.trace("autorize start, authorizedElementCategory={}, authorizedElementId={}, User={}", getString(authorizedElementCategory), getString(
		//				authorizedElementId), getString(User));
		bool calculatedRight;

		if(targetRightType == RightType.CREATE && (strcmp(authorizedElementCategory, "DOCUMENT") == 0 || strcmp(authorizedElementCategory,
				"DOCUMENTTYPE") == 0 || strcmp(authorizedElementCategory, "DICTIONARY") == 0))
		{
			calculatedRight = scripts.S01AllLoggedUsersCanCreateDocuments.calculate(User, authorizedElementId, targetRightType, ts);
		//			log.trace("autorize end#0, return:[{}]", calculatedRight);
		}
		if(calculatedRight == true)
		{
			//			log.trace("autorize end#1, return:[{}]", calculatedRight);
			return calculatedRight;
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S11ACLRightsHierarhical.calculate(User, authorizedElementId, targetRightType, ts, hierarhical_departments, pp);
		//			log.trace("authorize:S11ACLRightsHierarhical res={}", calculatedRight);
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S05InDocFlow.calculate(User, authorizedElementId, targetRightType, ts);
		//			log.trace("authorize:S05InDocFlow res={}", calculatedRight);
		}

		uint* iterator_facts_of_document = ts.getTriples(authorizedElementId, null, null, false);

		if(iterator_facts_of_document is null && strcmp(authorizedElementCategory, "DOCUMENT") == 0)
		{
			//			log.trace("iterator_facts_of_document [s={}] is null", getString(subject_document));
			//			log.trace("autorize end#2, return:[false]");
			return false;
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S10UserIsAuthorOfDocument.calculate(User, authorizedElementId, targetRightType, ts, iterator_facts_of_document);
		//			log.trace("authorize:S10UserIsAuthorOfDocument res={}", calculatedRight);
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S20UserIsInOUP.calculate(User, authorizedElementId, targetRightType, ts, iterator_facts_of_document);
		//			log.trace("authorize:S20UserIsInOUP res={}", calculatedRight);
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S30UsersOfDocumentum.calculate(User, authorizedElementId, targetRightType, ts, iterator_facts_of_document);
		//			log.trace("authorize:S30UsersOfDocumentum res={}", calculatedRight);
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S40UsersOfTAImport.calculate(User, authorizedElementId, targetRightType, ts, iterator_facts_of_document);
		//			log.trace("authorize:S40UsersOfTAImport res={}", calculatedRight);
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S01UserIsAdmin.calculate(User, authorizedElementId, targetRightType, ts);
		}

		//		log.trace("autorize end#3, return:[{}]", calculatedRight);
		return calculatedRight;
	}

}
