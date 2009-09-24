module scripts.S11ACLRightsHierarhical;

import RightTypeDef;
import TripleStorage;
private import tango.io.Stdout;
private import script_util;
private import tango.stdc.string;
private import tango.stdc.posix.stdio;

private import fact_tools;
private import Log;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments)
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

bool checkRight(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments)
{
	//	log.trace("S11ACLRightsHierarhical.checkRight #0 hierarhical_departments.length = {}", iterator_on_targets_of_hierarhical_departments.length);

	uint* iterator_subjects_of_elementId;

	// найдем все ACL записи для этого документа
	uint* iterator1 = ts.getTriples(null, "magnet-ontology/authorization/acl#elementId", elementId, false);
	iterator_subjects_of_elementId = iterator1;

	//    	log.trace("query: s={}, p={}, o={}", null, "magnet-ontology/authorization/acl#elementId", getString (elementId));
	//		print_list_triple(iterator1);

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

			// проверим на вхождение elementId в вышестоящих узлах орг структуры
			for(int i = 0; i < iterator_on_targets_of_hierarhical_departments.length; i++)
			{
				uint* iterator2 = ts.getTriples(acl_subject, "magnet-ontology/authorization/acl#targetSubsystemElement",
						iterator_on_targets_of_hierarhical_departments[i], false);

				if(iterator2 !is null)
				{
					return true;
				}

			}

			//			bool this_user_in_ACL = false;
			// возьмем факты этой записи ACL
			uint* iterator2 = ts.getTriples(acl_subject, "magnet-ontology/authorization/acl#targetSubsystemElement", user, false);

			//			log.trace("query: s={}, p={}, o={}", getString(acl_subject), "magnet-ontology/authorization/acl#targetSubsystemElement", getString(user));
			//			print_list_triple(iterator2);

			if(iterator2 !is null)
			{
				// это означает, что данная ACL запись содержит нашего пользователя в качестве target
				// теперь считаем сами права

				uint* iterator3 = ts.getTriples(acl_subject, "magnet-ontology/authorization/acl#rights", null, false);

				//				log.trace("query: s={}, p={}, o={}", getString(acl_subject), "magnet-ontology/authorization/acl#rights", null);
				//				print_list_triple(iterator3);

				if(iterator3 !is null)
				{
					uint next_element3 = 0xFF;
					while(next_element3 > 0)
					{
						byte* triple3 = cast(byte*) *iterator3;

						if(triple3 !is null)
						{
							// проверим, есть ли тут требуемуе нами право
							char*
									triple2_o = cast(char*) (triple3 + 6 + (*(triple3 + 0) << 8) + *(triple3 + 1) + 1 + (*(triple3 + 2) << 8) + *(triple3 + 3) + 1);

							while(*triple2_o != 0)
							{
								//							Stdout.format("S11ACLRightsHierarhical.checkRight #5 ?").newline;
								if((rightType == RightType.READ) && (*triple2_o == 'r' || *(triple2_o + 1) == 'r'))
								{
									//								Stdout.format("S11ACLRightsHierarhical.checkRight #6 YES").newline;
									return true;
								}
								triple2_o++;
							}

						}
					}
					next_element3 = *(iterator3 + 1);
					iterator3 = cast(uint*) next_element3;
				}
			}

			next_element1 = *(iterator1 + 1);
			iterator1 = cast(uint*) next_element1;
		}
	}

	return this_user_in_ACL;
}
