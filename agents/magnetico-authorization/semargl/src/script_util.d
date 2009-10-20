module script_util;

private import RightTypeDef;
private import TripleStorage;
private import tango.io.Stdout;
private import fact_tools;
private import Log;
private import tango.stdc.string;

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
 * возвращает массив субьектов (s) вышестоящих подразделений по отношению к user   
 */
public char*[] getDepartmentTreePathOfUser(char* user, TripleStorage ts)
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

		}
	}

	//		Stdout.format("getDepartmentTreePath #5 ok").newline;

	result.length = count_result;
	return result;
}

/*
 * возвращает массив субьектов (s) вышестоящих подразделений по отношению к delegate_id   
 */
public char*[] getDelegateAssignersTreeArray(char* delegate_id, TripleStorage ts)
{

	char*[] result = new char*[20];
	uint result_cnt = 0;

	void put_in_result(char* founded_delegate)
	{
		result[result_cnt++] = founded_delegate;
	}

	getDelegateAssignersForDelegate(delegate_id, ts, &put_in_result);

	result.length = result_cnt;

	return result;

}

public void getDelegateAssignersForDelegate(char* delegate_id, TripleStorage ts, void delegate(char* founed_delegate) process_delegate)
{

	uint* delegates_facts = ts.getTriples(null, "magnet-ontology/authorization/acl#delegate", delegate_id, false);

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
				uint* owners_facts = ts.getTriples(subject, "magnet-ontology/authorization/acl#owner", null, false);

				if(owners_facts !is null)
				{
					uint next_owner = 0xFF;
					while(next_owner > 0)
					{
						byte* owner = cast(byte*) *owners_facts;
						if(owner !is null)
						{
							//log.trace("#4 gda");

							char* object = cast(char*) (owner + 6 + (*(owner + 0) << 8) + *(owner + 1) + 1 + (*(owner + 2) << 8) + *(owner + 3) + 1);

							//log.trace("delegate = {}, owner = {}", getString(subject), getString(object));

							/*			  strcpy(result_ptr++, ",");
							 strcpy(result_ptr, object);
							 result_ptr += strlen(object);*/
							process_delegate(object);

							uint* with_tree_facts = ts.getTriples(subject, "magnet-ontology/authorization/acl#withTree", null, false);
							if(with_tree_facts !is null)
							{
								uint next_with_tree = 0xFF;
								while(next_with_tree > 0)
								{
									byte* with_tree = cast(byte*) *with_tree_facts;
									if(with_tree !is null)
									{
										if(strcmp(cast(char*) with_tree, "1") == 0)
											getDelegateAssignersForDelegate(object, ts, process_delegate);
										next_with_tree = 0;
									}
									else
									{
										next_with_tree = *(with_tree_facts + 1);
										with_tree_facts = cast(uint*) next_with_tree;
									}
								}
							}
							next_owner = 0;
						}
						else
						{
							next_owner = *(owners_facts + 1);
							owners_facts = cast(uint*) next_owner;
						}
					}
				}
			}
			next_delegate = *(delegates_facts + 1);
			delegates_facts = cast(uint*) next_delegate;
		}
	}
}