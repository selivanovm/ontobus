module script_util;

import RightTypeDef;
import TripleStorage;
private import tango.io.Stdout;
import fact_tools;

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

			iterator0 = ts.getTriples(autor_in_acl, "magnet-ontology#group", "DOCFLOW\0", false);

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
 * возвращает массив итераторов на списки субьектов 
 * имеющих факты magnet-ontology#target = подразделение по иерархии  
 */
public uint*[] getDepartmentTreePath(char* user, TripleStorage ts)
{
	// получаем путь до корня в дереве подразделений начиная от заданного подразделения

	uint*[] result = new uint*[16];
	ubyte count_result = 0;

	uint* iterator0;
	byte* triple0;

	//	Stdout.format("getDepartmentTreePath #1 user={}", str_2_chararray(user)).newline;

	iterator0 = ts.getTriples(user, "magnet-ontology#memberOf", null, false);
	if(iterator0 !is null)
	{
		triple0 = cast(byte*) *iterator0;
		char*
				next_branch = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);;
		//		if(next_branch !is null)
		//			Stdout.format("getDepartmentTreePath #1 next_branch  {}", str_2_chararray(next_branch)).newline;

		while(next_branch !is null)
		{

			uint* iterator1 = ts.getTriples(null, "magnet-ontology#target", next_branch, false);
			if(iterator1 !is null)
			{

				//				Stdout.format("iterator1 next_element1={:X4}", iterator1).newline;

				result[count_result] = iterator1;
				count_result++;

			}

			iterator0 = ts.getTriples(next_branch, "magnet-ontology#memberOf", null, false);
			if(iterator0 !is null)
			{
				triple0 = cast(byte*) *iterator0;

				if(triple0 !is null)
				{
					next_branch = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);;
				//					if(next_branch !is null)
				//						Stdout.format("getDepartmentTreePath #2 next_branch  {}", str_2_chararray(next_branch)).newline;
				}
				else
					next_branch = null;

			}
			else
				next_branch = null;
		}
	}

	//	Stdout.format("getDepartmentTreePath #5 ok").newline;

	result.length = count_result;

	return result;
}

