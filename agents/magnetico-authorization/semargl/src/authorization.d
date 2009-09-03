module authorization;

// import TripleStorageInvoker;
private import tango.io.Stdout;
private import tango.stdc.string;

//import Integer = tango.text.convert.Integer;
version(tango_99_8)
{
	import tango.io.device.File;
}

version(tango_99_7)
{
	import tango.io.File;
}

import Text = tango.text.Util;
import tango.time.StopWatch;
import Log;

import HashMap;
import TripleStorage;
import tango.time.WallClock;
import tango.time.Clock;
import tango.io.FileScan;

import tango.text.locale.Locale;
import tango.text.convert.TimeStamp;
import tango.text.convert.Layout;

import RightTypeDef;
import script_util;

import persistent_triple_storage;

import scripts.S05InDocFlow;
import scripts.S01AllLoggedUsersCanCreateDocuments;
import scripts.S01UserIsAdmin;
import scripts.S10UserIsAuthorOfDocument;
import scripts.S11ACLRightsHierarhical;
import scripts.S20UserIsInOUP;
import scripts.S30UsersOfDocumentum;
import scripts.S40UsersOfTAImport;

import fact_tools;

class Authorization
{
	private char[][] i_know_predicates;
	private TripleStorage ts = null;

	this()
	{
		i_know_predicates = new char[][24];

		uint d = 0;

		// document
		i_know_predicates[d++] = "http://purl.org/dc/elements/1.1/creator";
		i_know_predicates[d++] = "magnet-ontology#subject";
		i_know_predicates[d++] = "magnet-ontology#typeName";

		// ACL
		i_know_predicates[d++] = "magnet-ontology#author";
		i_know_predicates[d++] = "magnet-ontology#authorSystem";
		i_know_predicates[d++] = "magnet-ontology#authorSubsystem";
		i_know_predicates[d++] = "magnet-ontology#authorSubsystemElement";

		i_know_predicates[d++] = "magnet-ontology#category";

		i_know_predicates[d++] = "magnet-ontology#target";
		i_know_predicates[d++] = "magnet-ontology#targetSystem";
		i_know_predicates[d++] = "magnet-ontology#targetSubsystem";
		i_know_predicates[d++] = "magnet-ontology#targetSubsystemElement";

		i_know_predicates[d++] = "magnet-ontology#rigths";
		i_know_predicates[d++] = "magnet-ontology#fromUserId";
		i_know_predicates[d++] = "magnet-ontology#toUserId";
		i_know_predicates[d++] = "magnet-ontology#withDelegatesTree";
		i_know_predicates[d++] = "magnet-ontology#elementId";
		i_know_predicates[d++] = "magnet-ontology#group";
		i_know_predicates[d++] = "magnet-ontology#dateFrom";
		i_know_predicates[d++] = "magnet-ontology#dateTo";

		// ORGANIZATION
		i_know_predicates[d++] = "magnet-ontology#hasPart";
		i_know_predicates[d++] = "magnet-ontology#memberOf";
		i_know_predicates[d++] = "magnet-ontology#loginName";

		//
		i_know_predicates[d++] = "magnet-ontology#isAdmin";

		init();
	}

	public TripleStorage getTripleStorage()
	{
		return ts;
	}

	private void init()
	{
		Stdout.format("authorization init..").newline;

		ts = new TripleStorage(idx_name.S | idx_name.SP | idx_name.PO | idx_name.SPO, 500_000, 8);

		//		

		char[] root = ".";
		Stdout.formatln("Scanning '{}'", root);

		auto scan = (new FileScan)(root, ".n3");
		Stdout.format("\n{} Folders\n", scan.folders.length);
		foreach(folder; scan.folders)
			Stdout.format("{}\n", folder);
		Stdout.format("\n{0} Files\n", scan.files.length);

		foreach(file; scan.files)
		{
			Stdout.format("{}\n", file);
			load_from_file(file, i_know_predicates, ts);
		}
		Stdout.formatln("\n{} Errors", scan.errors.length);
		foreach(error; scan.errors)
			Stdout(error).newline;

		scan = (new FileScan)(root, ".tn3");
		Stdout.format("\n{} Folders\n", scan.folders.length);
		foreach(folder; scan.folders)
			Stdout.format("{}\n", folder);
		Stdout.format("\n{0} Files\n", scan.files.length);

		foreach(file; scan.files)
		{
			Stdout.format("{}\n", file);
			load_from_file(file, i_know_predicates, ts);
		}
		Stdout.formatln("\n{} Errors", scan.errors.length);
		foreach(error; scan.errors)
			Stdout(error).newline;
		
  	    print_list_triple (ts.getTriples("6fade5fe62cac8f0", null, null, false));
  	    print_list_triple (ts.getTriples("6fade578b4571790", null, null, false));
  	    
		
		Stdout.format("authorization init ... ok").newline;
	}

	public void addAuthorizeData(char[] s, char[] p, char[] o)
	{
		auto layout = new Locale;
		auto nameFile = layout("data/authorize-data-{:yyyy-MM-dd}.tn3", WallClock.now);
		auto file = new File(nameFile);
		ts.addTriple(s, p, o);

		auto tm = WallClock.now;
		auto dt = Clock.toDate(tm);
		char[] tmp1 = new char[33 + s.length + p.length + o.length];
		char[18] tmp;

		auto now = Util.layout(tmp1, "%0-%1-%2 %3:%4:%5,%6 <%7><%8>\"%9\" .\n", convert(tmp[0 .. 4], dt.date.year),
				convert(tmp[4 .. 6], dt.date.day), convert(tmp[6 .. 8], dt.date.month), convert(tmp[8 .. 10],
						dt.time.hours), convert(tmp[10 .. 12], dt.time.minutes),
				convert(tmp[12 .. 14], dt.time.seconds), convert(tmp[14 .. 17], dt.time.millis), s, p, o);

		file.append(now);
	}

	private char[] convert(char[] tmp, long i)
	{
		return Integer.formatter(tmp, i, 'u', '?', 8);
	}

	// необходимые данные загружены, сделаем пробное выполнение скриптов для всех документов 

	public bool authorize(char* docId, char* User, uint targetRightType, uint*[] hierarhical_departments)
	{
		//		Stdout.format("autorize start").newline;
		//		elapsed.start;

		//		char* User = "671d8e10-d7ca-48ae-b027-76a97172f304";
		//	char* User = "61b807a9-e350-45a1-a0ed-10afa8f987a4";

		// 

		//		uint count_auth_doc = 0;
		// считываем все документы
		//		uint* iterator0 = ts.getTriples(null, "magnet-ontology#subject", "DOCUMENT", false);

		//		if(iterator0 is null)
		//		{
		//			throw new Exception("not found documents");
		//		}

		//		char* char_p_dept = cast(char*) "Department";

		//		Stdout.format("#1 predicate_department={}", char_p_dept).newline;

		//		elapsed.start;

		//		uint targetRightType = RightType.READ;

		bool calculatedRight = false;
		//		calculatedRight = S01UserIsAdmin.calculate(User, null, targetRightType, ts);

		//		uint next_element = 0xFF;
		//		while(next_element > 0)
		//		{
		//			byte* triple0 = cast(byte*) *iterator0;
		//				Stdout.format("#2 triple0={:X4}", cast(void*) triple0).newline;

		//				uint key1_length = (*(triple0 + 0) << 8) + *(triple0 + 1);
		//				uint key2_length = (*(triple0 + 2) << 8) + *(triple0 + 3);
		//				uint key3_length = (*(triple0 + 4) << 8) + *(triple0 + 5);

		//char* triple0_s = cast(char*) triple0 + 6;
		//				char* triple0_p = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1);

		//			char* subject_document = cast(char*) triple0 + 6;
		char* subject_document = docId;

		//		printf("authorize:docId=%s user=%s target_right_type=%i\n", docId, User, targetRightType);

		calculatedRight = scripts.S01AllLoggedUsersCanCreateDocuments.calculate(User, subject_document,
				targetRightType, ts);
		if(calculatedRight == true)
			return calculatedRight;

		uint* iterator_facts_of_document = ts.getTriples(subject_document, null, null, false);

		if(iterator_facts_of_document is null)
		{
			Stdout.format("iterator_facts_of_document is null").newline;
			return false;
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S11ACLRightsHierarhical.calculate(User, subject_document, targetRightType, ts,
					hierarhical_departments);
		//			printf("authorize:S11ACLRightsHierarhical res=%d\n", calculatedRight);
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S05InDocFlow.calculate(User, subject_document, targetRightType, ts);
		//			printf("authorize:S05InDocFlow res=%d\n", calculatedRight);
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S10UserIsAuthorOfDocument.calculate(User, subject_document, targetRightType, ts,
					iterator_facts_of_document);
		//			printf("authorize:S10UserIsAuthorOfDocument res=%d\n", calculatedRight);
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S20UserIsInOUP.calculate(User, subject_document, targetRightType, ts,
					iterator_facts_of_document);
		//			printf("authorize:S20UserIsInOUP res=%d\n", calculatedRight);
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S30UsersOfDocumentum.calculate(User, subject_document, targetRightType, ts,
					iterator_facts_of_document);
		//			printf("authorize:S30UsersOfDocumentum res=%d\n", calculatedRight);
		}

		if(calculatedRight == false)
		{
			calculatedRight = scripts.S40UsersOfTAImport.calculate(User, subject_document, targetRightType, ts,
					iterator_facts_of_document);
		//			printf("authorize:S40UsersOfTAImport res=%d\n", calculatedRight);
		}

		//		next_element = *(iterator0 + 1);
		//		iterator0 = cast(uint*) next_element;

		//		count_auth_doc++;
		//				log.trace ("next_element={:X}, iterator0={:X}", next_element, iterator0);
		//			calculatedRight = false;
		//		}

		//		time = elapsed.stop;

		//		Stdout.format("calculate rules for documents, count={}, time ={}, cps={}", count_auth_doc, time,
		//				count_auth_doc / time).newline;

		return calculatedRight;
	}

}