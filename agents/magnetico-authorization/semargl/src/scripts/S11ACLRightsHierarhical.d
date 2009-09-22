module scripts.S11ACLRightsHierarhical;

import RightTypeDef;
import TripleStorage;
private import tango.io.Stdout;
//import str_tool;
private import script_util;
private import tango.stdc.string;
private import tango.stdc.posix.stdio;
private import fact_tools;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts,
		uint*[] iterator_on_targets_of_hierarhical_departments)
{
	bool result = false;

	//	Stdout.format("S11ACLRightsHierarhical document = {:X4}", elementId).newline;

	// если документ в документообороте и мы хотим модифицировать
	if((RightType.WRITE == rightType) || (RightType.DELETE == rightType))
	{
		//		if(isInDocFlow(elementId, ts))
		{
			// то извлечём все права выданные документооборотом
			//						result = iSystem.authorizationComponent.checkRight("DOCFLOW", null, null, "BA", null, orgIds, category, elementId, rightType);
			result = checkRight(user, elementId, rightType, ts, iterator_on_targets_of_hierarhical_departments);
		}
	}
	else
	{
		// иначе выдадим все права выданные системой электоронного архива
		//					result = iSystem.authorizationComponent.checkRight(null , null, null, "BA", null, orgIds, category, elementId, rightType);
		result = checkRight(user, elementId, rightType, ts, iterator_on_targets_of_hierarhical_departments);
	}

	return result;
}

bool checkRight(char* user, char* elementId, uint rightType, TripleStorage ts,
		uint*[] iterator_on_targets_of_hierarhical_departments)
{
//	Stdout.format("S11ACLRightsHierarhical.checkRight #0 hierarhical_departments.length = {}",
//			iterator_on_targets_of_hierarhical_departments.length).newline;

	uint* iterator1 = ts.getTriples(null, "magnet-ontology/authorization/acl#elementId", elementId, false);

//	print_list_triple(iterator1);

	bool this_user_in_ACL = false;

	if(iterator1 !is null)
	{
		// проверим ACL права для этого документа
		uint next_element1 = 0xFF;
		while(next_element1 > 0)
		{
			// субьект этого триплета - запись в ACL
			byte* triple1 = cast(byte*) *iterator1;
			char* acl_subject = cast(char*) triple1 + 6;

			//			bool this_user_in_ACL = false;
			// возьмем факты этой записи ACL
			uint* iterator2 = ts.getTriples(acl_subject, null, null, false);

			uint next_element2 = 0xFF;
			while(next_element2 > 0)
			{
				byte* triple2 = cast(byte*) *iterator2;

				if(triple2 !is null)
				{
					char* triple2_p = cast(char*) (triple2 + 6 + (*(triple2 + 0) << 8) + *(triple2 + 1) + 1);
					//					printf("%s\n", triple2_p);

					if(strcmp(triple2_p, "magnet-ontology/authorization/acl#targetSubsystemElement\0") == 0)
					{
						//							Stdout.format("###1").newline;

						// проверим, это ACL для нашего пользователя или нет
						char*
								triple2_o = cast(char*) (triple2 + 6 + (*(triple2 + 0) << 8) + *(triple2 + 1) + 1 + (*(triple2 + 2) << 8) + *(triple2 + 3) + 1);

						//					printf("%s\n", triple2_o);

						if(strcmp(triple2_o, user) == 0)
						{
							this_user_in_ACL = true;
							Stdout.format("this_user_in_ACL = {}", this_user_in_ACL).newline;
						}

					}
					else if(this_user_in_ACL == true && strcmp(triple2_p, "magnet-ontology/authorization/acl#rights\0") == 0)
					{
						Stdout.format(
								"this_user_in_ACL == true && strcmp(triple2_p, 'magnet-ontology/authorization/acl#rights\0'").newline;

						// проверим, есть ли тут требуемуе нами право
						char*
								triple2_o = cast(char*) (triple2 + 6 + (*(triple2 + 0) << 8) + *(triple2 + 1) + 1 + (*(triple2 + 2) << 8) + *(triple2 + 3) + 1);

						while(*triple2_o != 0)
						{
							Stdout.format("S11ACLRightsHierarhical.checkRight #5 ?").newline;
							if((rightType == RightType.READ) && *triple2_o == 'r')
							{
								//								Stdout.format("S11ACLRightsHierarhical.checkRight #6 YES").newline;
								return true;
							}
							triple2_o++;
						}

					}
				}
				next_element2 = *(iterator2 + 1);
				iterator2 = cast(uint*) next_element2;
			}

			next_element1 = *(iterator1 + 1);
			iterator1 = cast(uint*) next_element1;
		}
	}

	//	Stdout.format("S11ACLRightsHierarhical.checkRight #7").newline;

	/*	
	 // проверим на вхождение этого документа в вышестоящих узлах орг структуры
	 for(int i = 0; i < iterator_on_targets_of_hierarhical_departments.length; i++)
	 {
	 //		Stdout.format("S11ACLRightsHierarhical.checkRight #1 {} {} {:X4}",  iterator_on_targets_of_hierarhical_departments.length, i, iterator_on_targets_of_hierarhical_departments[i]).newline;

	 uint* iterator0 = iterator_on_targets_of_hierarhical_departments[i];
	 uint next_element0 = 0xFF;
	 while(next_element0 > 0)
	 {
	 if(iterator1 !is null)
	 {
	 uint next_element1 = 0xFF;
	 while(next_element1 > 0)
	 {
	 byte* triple0 = cast(byte*) *iterator0;
	 byte* triple1 = cast(byte*) *iterator1;
	 
	 char* s0 = cast(char*) triple0 + 6;
	 char* s1 = cast(char*) triple1 + 6;
	 
	 if (strcmp (s0,s1) == 0)	
	 {
	 Stdout.format("0 1 = {:X4} {:X4}", s0, s1).newline;
	 
	 }
	 
	 next_element1 = *(iterator1 + 1);
	 iterator1 = cast(uint*) next_element1;
	 }
	 }
	 next_element0 = *(iterator0 + 1);
	 iterator0 = cast(uint*) next_element0;
	 }

	 }
	 */

	return this_user_in_ACL;
}
