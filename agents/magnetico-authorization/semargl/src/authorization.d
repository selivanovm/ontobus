module authorization;

// import TripleStorageInvoker;
private import tango.io.Stdout;
private import std.c.string;
//import Integer = tango.text.convert.Integer;
import tango.io.File;
import Text = tango.text.Util;
import tango.time.StopWatch;
import dee0xd.Log;

import HashMap;
import TripleStorage;
//import ListTriple;
//import Triple;
import tango.time.WallClock;
import tango.time.Clock;
import tango.io.FileScan;

import tango.text.locale.Locale;
import tango.text.convert.TimeStamp;
import tango.text.convert.Layout;

import RightTypeDef;
import script_util;

import S05InDocFlow;
import S01AllLoggedUsersCanCreateDocuments;
import S01UserIsAdmin;
import S10UserIsAuthorOfDocument;
import S11ACLRightsHierarhical;
import S20UserIsInOUP;
import S30UsersOfDocumentum;
import S40UsersOfTAImport;

class Authorization
{
	private char[][] i_know_predicates;
	private TripleStorage ts = null;

	this()
	{
		i_know_predicates = new char[][17];

		uint d = 0;

		// document
		i_know_predicates[d++] = "http://purl.org/dc/elements/1.1/creator";
		i_know_predicates[d++] = "magnet-ontology#subject";
		i_know_predicates[d++] = "magnet-ontology#typeName";

		// ACL
		i_know_predicates[d++] = "magnet-ontology#author";
		i_know_predicates[d++] = "magnet-ontology#rigths";
		i_know_predicates[d++] = "magnet-ontology#target";
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
			load_from_file(file);
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
			load_from_file(file);
		}
		Stdout.formatln("\n{} Errors", scan.errors.length);
		foreach(error; scan.errors)
			Stdout(error).newline;

		Stdout.format("authorization init ... ok").newline;
	}

	private void load_from_file(FilePath file_path)
	{
		uint count_add_triple = 0;
		uint count_ignored_triple = 0;

		auto elapsed = new StopWatch();
		double time;
		Stdout.format("load triples from file {}", file_path).newline;

		auto file = new File(file_path.path ~ file_path.name ~ file_path.suffix);
		auto content = cast(char[]) file.read;

		elapsed.start;

		foreach(line; Text.lines(content))
		{
			char[] s, p, o;
			int idx = 0;
			foreach(element; Text.delimit(line, ">"))
			{
				element = Text.chopl(element, "<");
				element = Text.chopl(element, " <");
				element = Text.chopr(element, " .");
				element = Text.trim(element);

				if(element[4] == '-' && element[7] == '-' && element[10] == ' ' && element[13] == ':' && element[16] == ':' && element[19] == ',')
					element = Text.delimit(element, "<")[1];

				element[element.length] = 0;

				idx++;
				if(idx == 1)
				{
					s = element;
				}

				if(idx == 2)
				{
					p = element;
				}

				if(idx == 3)
				{
					if(element.length > 2)
					{
						o = element[1 .. (element.length - 1)];
						o[o.length] = 0;
					}
				}

			//				Stdout.format("element={} ", element).newline;

			}

			//			Stdout.format("main: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o).newline;

			if(s.length == 0 && p.length == 0 && o.length == 0)
				continue;

			if(o.length == 2)
			{
				// Stdout.format("main: skip this triple [{}] <{}><{}><{}>", count_add_triple, s, p, o).newline;
				continue;
			}

			bool i_know_predicat = false;
			for(int i = 0; i < i_know_predicates.length; i++)
			{
				if(p == i_know_predicates[i])
				{
					i_know_predicat = true;
					break;
				}

			}

			if(i_know_predicat)
			{
				//						Stdout.format("main: add triple [{}] <{}><{}><{}>", count_add_triple, s, p, o).newline;
				if(ts.addTriple(s, p, o))
					count_add_triple++;
				else
					count_ignored_triple++;
			}
			else
			{
				count_ignored_triple++;

			}
		//				if(count_add_triple > 5)
		//					break;
		}

		//	

		time = elapsed.stop;

		Stdout.format("create TripleStorage time = {}, count add triples = {}, ignored = {}", time, count_add_triple,
				count_ignored_triple).newline;
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

		printf("authorize:docId=%s\n", docId);

		calculatedRight = S01AllLoggedUsersCanCreateDocuments.calculate(User, subject_document, targetRightType, ts);
		if (calculatedRight == true)
			return calculatedRight;
		

		uint* iterator_facts_of_document = ts.getTriples(subject_document, null, null, false);

		if(iterator_facts_of_document is null)
		{
			Stdout.format("iterator_facts_of_document is null").newline;
			return false;
		}

		if(calculatedRight == false)
			calculatedRight = S11ACLRightsHierarhical.calculate(User, subject_document, targetRightType, ts,
					hierarhical_departments);

		if(calculatedRight == false)
			calculatedRight = S05InDocFlow.calculate(User, subject_document, targetRightType, ts);

		if(calculatedRight == false)
			calculatedRight = S10UserIsAuthorOfDocument.calculate(User, subject_document, targetRightType, ts,
					iterator_facts_of_document);

		if(calculatedRight == false)
			calculatedRight = S20UserIsInOUP.calculate(User, subject_document, targetRightType, ts,
					iterator_facts_of_document);

		if(calculatedRight == false)
			calculatedRight = S30UsersOfDocumentum.calculate(User, subject_document, targetRightType, ts,
					iterator_facts_of_document);

		if(calculatedRight == false)
			calculatedRight = S40UsersOfTAImport.calculate(User, subject_document, targetRightType, ts,
					iterator_facts_of_document);

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

	public char[] str_2_char_array(char* str)
	{
		uint str_length = 0;
		char* tmp_ptr = str;
		while(*tmp_ptr != 0)
		{
			//		Stdout.format("@={}", *tmp_ptr).newline;
			tmp_ptr++;
		}

		str_length = tmp_ptr - str;

		char[] res = new char[str_length];

		for(uint i = 0; i < str_length; i++)
		{
			res[i] = *(str + i);
		}

		return res;
	}
}