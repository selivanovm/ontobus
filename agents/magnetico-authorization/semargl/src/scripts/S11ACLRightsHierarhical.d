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
	uint* iterator1 = ts.getTriples(null, "magnet-ontology/authorization/acl#elementId", elementId, false);
	iterator_subjects_of_elementId = iterator1; 

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

//			print_list_triple(iterator2);

			uint next_element2 = 0xFF;
			while(next_element2 > 0)
			{
				byte* triple2 = cast(byte*) *iterator2;

				if(triple2 !is null)
				{
					char* triple2_p = cast(char*) (triple2 + 6 + (*(triple2 + 0) << 8) + *(triple2 + 1) + 1);
					//					printf("%s\n", triple2_p);

					if(strcmp(triple2_p, "magnet-ontology/authorization/acl#targetSubsystemElement") == 0)
					{
//						log.trace("###1");

						// проверим, это ACL для нашего пользователя или нет
						char*
								triple2_o = cast(char*) (triple2 + 6 + (*(triple2 + 0) << 8) + *(triple2 + 1) + 1 + (*(triple2 + 2) << 8) + *(triple2 + 3) + 1);

//						log.trace("{}", getString(triple2_o));

						if(strcmp(triple2_o, user) == 0)
						{
							this_user_in_ACL = true;
//							Stdout.format("this_user_in_ACL = {}", this_user_in_ACL).newline;
						}

					}
					else if(this_user_in_ACL == true && strcmp(triple2_p, "magnet-ontology/authorization/acl#rights") == 0)
					{
//						Stdout.format("this_user_in_ACL == true && strcmp(triple2_p, 'magnet-ontology/authorization/acl#rights'").newline;

						// проверим, есть ли тут требуемуе нами право
						char*
								triple2_o = cast(char*) (triple2 + 6 + (*(triple2 + 0) << 8) + *(triple2 + 1) + 1 + (*(triple2 + 2) << 8) + *(triple2 + 3) + 1);

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
				next_element2 = *(iterator2 + 1);
				iterator2 = cast(uint*) next_element2;
			}

			next_element1 = *(iterator1 + 1);
			iterator1 = cast(uint*) next_element1;
		}
	}

//	log.trace("S11ACLRightsHierarhical.checkRight #7");

	
	// проверим на вхождение этого документа в вышестоящих узлах орг структуры
	for(int i = 0; i < iterator_on_targets_of_hierarhical_departments.length; i++)
	{
//		log.trace("S11ACLRightsHierarhical.checkRight length_hierarhicaly={} i={} level={}", iterator_on_targets_of_hierarhical_departments.length,
//				i, getString(iterator_on_targets_of_hierarhical_departments[i]));
		uint* iterator00 = ts.getTriples(null, "magnet-ontology/authorization/acl#targetSubsystemElement",
				iterator_on_targets_of_hierarhical_departments[i], false);
//		log.trace("iterator00 = {:X8}", iterator00);
		
		if(iterator00 !is null && iterator_subjects_of_elementId !is null)
		{
			uint next_element0 = 0xFF;
			while(next_element0 > 0)
			{
				byte* triple0 = cast(byte*) *iterator00;
				char* s0 = cast(char*) triple0 + 6;
//				log.trace("s0 = {}", getString (s0));

				uint* iterator11 = iterator_subjects_of_elementId;
				
				uint next_element1 = 0xFF;
				while(next_element1 > 0)
				{
					byte* triple1 = cast(byte*) *iterator11;
					char* s1 = cast(char*) triple1 + 6;
//					log.trace("s1 = {}", getString (s1));

					if(strcmp(s0, s1) == 0)
					{
						log.trace("s0 = s1");
						
						return true;
					}

					next_element1 = *(iterator11 + 1);
					iterator11 = cast(uint*) next_element1;
				}

				next_element0 = *(iterator00 + 1);
				iterator00 = cast(uint*) next_element0;
			}
		}

	//		print_list_triple(iterator0);		
	//		uint* iterator1 = ts.getTriples(null, "magnet-ontology/authorization/acl#elementId", iterator_on_targets_of_hierarhical_departments[i], false);

	}

	return this_user_in_ACL;
}
