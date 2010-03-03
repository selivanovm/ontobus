module scripts.S11ACLRightsHierarhical;

private import Predicates;

import RightTypeDef;
import TripleStorage;
private import tango.io.Stdout;
private import script_util;
private import tango.stdc.string;
private import tango.stdc.stdio;

private import fact_tools;
private import Log;



public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments,
		      char[] pp, char* authorizedElementCategory)
{
	bool result = false;

	//	log.trace("S11ACLRightsHierarhical document = {:X4}", elementId);

	// если документ в документообороте и мы хотим модифицировать
	if((RightType.WRITE == rightType) || (RightType.DELETE == rightType))
	{
		//		if(isInDocFlow(elementId, ts))
		{
			// то извлечём все права выданные документооборотом
			//						result = iSystem.authorizationComponent.checkRight("DOCFLOW", null, null, "BA", null, orgIds, category, elementId, rightType);
			result = checkRight(user, elementId, rightType, ts, iterator_on_targets_of_hierarhical_departments, pp, authorizedElementCategory);
		}
	}
	else
	{
		// иначе выдадим все права выданные системой электоронного архива
		//					result = iSystem.authorizationComponent.checkRight(null , null, null, "BA", null, orgIds, category, elementId, rightType);
		result = checkRight(user, elementId, rightType, ts, iterator_on_targets_of_hierarhical_departments, pp, authorizedElementCategory);
	}

	return result;
}

bool checkRight(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments, char[] pp, char* authorizedElementCategory)
{
	//	log.trace("S11ACLRightsHierarhical.checkRight #0 hierarhical_departments.length = {}", iterator_on_targets_of_hierarhical_departments.length);

	// найдем все ACL записи для заданных user и elementId 
	uint* iterator1 = ts.getTriplesUseIndex(cast(char*) pp, user, elementId, idx_name.S1PPOO);

	//	log.trace("checkRight query: pp={}, o1={}, o2={}", pp, getString(user), getString(elementId));
	//	print_list_triple(iterator1);

	if(lookRightOfIterator(iterator1, rt_symbols + rightType, ts, authorizedElementCategory) == true)
		return true;

	// проверим на вхождение elementId в вышестоящих узлах орг структуры
	for(int i = iterator_on_targets_of_hierarhical_departments.length - 1; i >= 0; i--)
	{
		uint* iterator2 = ts.getTriplesUseIndex(cast(char*) pp, iterator_on_targets_of_hierarhical_departments[i], elementId, idx_name.S1PPOO);

		//		log.trace("checkRight query: pp={}, o1={}, o2={}", pp, getString(iterator_on_targets_of_hierarhical_departments[i]), getString(elementId));
		//		print_list_triple(iterator2);

		if(lookRightOfIterator(iterator2, rt_symbols + rightType, ts, authorizedElementCategory) == true)
			return true;
	}

	return false;
}

bool lookRightOfIterator(uint* iterator3, char* rightType, TripleStorage ts, char* authorizedElementCategory)
{

	//	print_list_triple(iterator3);


	if(iterator3 !is null)
	{
		uint next_element3 = 0xFF;
		while(next_element3 > 0)
		{

			bool category_match = false;
			bool rights_match = false;

			byte* triple3 = cast(byte*) *iterator3;

			if(triple3 !is null)
			{
				char* s = cast(char*) triple3 + 6;
				char* p = cast(char*) (triple3 + 6 + (*(triple3 + 0) << 8) + *(triple3 + 1) + 1);

				uint* category_triples = ts.getTriples(s, CATEGORY.ptr, null);
				if(category_triples !is null)
				{
					byte* category_triple = cast(byte*) *category_triples;
					if(category_triple !is null) 
					{
						char* category = cast(char*) (category_triple + 6 + (*(category_triple + 0) << 8) + *(category_triple + 1) + 1 + (*(category_triple + 2) << 8) + *(category_triple + 3) + 1);
						//log.trace("# {} ?= {}", getString(authorizedElementCategory), getString(category));
						
						if(strcmp(authorizedElementCategory, category) == 0)
						{
							category_match = true;
						}
					}
				}

				if(category_match && strcmp(p, RIGHTS.ptr) == 0)
				{
					// проверим, есть ли тут требуемуе нами право
					char* triple2_o = cast(char*) (triple3 + 6 + (*(triple3 + 0) << 8) + *(triple3 + 1) + 1 + (*(triple3 + 2) << 8) + *(triple3 + 3) + 1);
					//		log.trace ("#5 lookRightInACLRecord o={}", getString (triple2_o));

					bool is_actual = false;
					while(*triple2_o != 0)
					{
						//					  log.trace("lookRightOfIterator ('{}' || '{}' == '{}' ?)", *triple2_o, *(triple2_o + 1), *rightType);
						if(*triple2_o == *rightType || *(triple2_o + 1) == *rightType)
						{
							if(!is_actual)
								is_actual = is_right_actual(s, ts);
							if(is_actual)
							{
								//log.trace("# subject = {} ", getString(s));
								
								return true;
							}
							else
								break;
						}
						triple2_o++;
					}
				}
			}
			next_element3 = *(iterator3 + 1);
			iterator3 = cast(uint*) next_element3;
		}
	}

	return false;
}
