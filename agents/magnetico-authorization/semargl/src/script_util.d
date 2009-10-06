module script_util;

private import RightTypeDef;
private import TripleStorage;
private import tango.io.Stdout;
private import fact_tools;
private import Log;

public bool isInDocFlow(char* elementId, TripleStorage ts)
{
	//		 Stdout.format("isInDocFlow, elementId={}", elementId).newline;
	// найдем субьекта ACL записи по <magnet-ontology#elementId>=elementId
	uint* iterator0 = ts.getTriples(null, "magnet-ontology#elementId", elementId, false);
	char* ACL_subject;

	if(iterator0 !is null)
	{
		byte* triple0 = cast(byte*) *iterator0;
		ACL_subject = cast(char*) triple0 + 6;
		//		 Stdout.format("isInDocFlow #1 ACL Subject {}", str_2_chararray(ACL_subject)).newline;

		// найдем автора 
		iterator0 = ts.getTriples(ACL_subject, "magnet-ontology#author", null, false);

		char* autor_in_acl;
		if(iterator0 !is null)
		{
			triple0 = cast(byte*) *iterator0;
			autor_in_acl = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);
			//		 Stdout.format("isInDocFlow #2 autor in acl {}", str_2_chararray(autor_in_acl)).newline;

			// найдем для этого автора группу

			iterator0 = ts.getTriples(autor_in_acl, "magnet-ontology#group", "DOCFLOW", false);

			if(iterator0 !is null)
			{
				Stdout.format("да, документ в документообороте {}", getString(elementId)).newline;
				return true;
			}
		}
	}

	return false;
}

/*
 * возвращает массив субьектов вышестоящих подразделений по отношению к user   
 */
public char*[] getDepartmentTreePath(char* user, TripleStorage ts)
{
	// получаем путь до корня в дереве подразделений начиная от заданного подразделения

	char*[] result = new char*[16];
	ubyte count_result = 0;

	uint* iterator0;
	byte* triple0;

//	log.trace("getDepartmentTreePath #1 for user={}", getString(user));

	iterator0 = ts.getTriples(user, "magnet-ontology#memberOf", null, false);

//	print_list_triple(iterator0);

	if(iterator0 !is null)
	{
		triple0 = cast(byte*) *iterator0;
		char* next_branch = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);;

		if(next_branch !is null)
		{
//			log.trace("getDepartmentTreePath #1 next_branch={}", getString(next_branch));
			result[count_result] = next_branch;
			count_result++;
		}

		while(next_branch !is null)
		{
			uint* iterator1 = ts.getTriples(null, "magnet-ontology#hasPart", next_branch, false);
			next_branch = null;
			if(iterator1 !is null)
			{
				byte* triple = cast(byte*) *iterator1;
				char* s = cast(char*) triple + 6;
//				log.trace("next_element1={}", getString (s));

				result[count_result] = s;
				count_result++;
				next_branch = s;
			}

//			iterator0 = ts.getTriples(next_branch, "magnet-ontology#hasPart", null, false);
//			if(iterator0 !is null)
//			{
//				triple0 = cast(byte*) *iterator0;
//
//				if(triple0 !is null)
//				{
//					next_branch = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);;
//
//					if(next_branch !is null)
//						log.trace("getDepartmentTreePath #2 next_branch  {}", getString(next_branch));
//				}
//				else
//					next_branch = null;
//
//			}
//			else
//				next_branch = null;
		}
	}

//		Stdout.format("getDepartmentTreePath #5 ok").newline;

	result.length = count_result;

	return result;
}