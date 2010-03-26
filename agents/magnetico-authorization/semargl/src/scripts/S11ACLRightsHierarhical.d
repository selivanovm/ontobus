module scripts.S11ACLRightsHierarhical;

private import tango.io.Stdout;
private import tango.stdc.string;
private import tango.stdc.stdio;

private import Predicates;
private import RightTypeDef;
private import TripleStorage;
private import script_util;
private import fact_tools;
private import HashMap;
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

bool checkRight(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments, char[] pp,
		char* authorizedElementCategory)
{
	//	log.trace("S11ACLRightsHierarhical.checkRight #0 hierarhical_departments.length = {}", iterator_on_targets_of_hierarhical_departments.length);

	// найдем все ACL записи для заданных user и elementId 
	triple_list_element* iterator1 = cast (triple_list_element*)ts.getTriplesUseIndex(cast(char*) pp, user, elementId, idx_name.S1PPOO);

	//	log.trace("checkRight query: pp={}, o1={}, o2={}", pp, getString(user), getString(elementId));
	//	print_list_triple(iterator1);

	if(lookRightOfIterator(iterator1, rt_symbols + rightType, ts, authorizedElementCategory) == true)
		return true;

	// проверим на вхождение elementId в вышестоящих узлах орг структуры
	for(int i = iterator_on_targets_of_hierarhical_departments.length - 1; i >= 0; i--)
	{
		triple_list_element* iterator2 = cast (triple_list_element*)ts.getTriplesUseIndex(cast(char*) pp, iterator_on_targets_of_hierarhical_departments[i], elementId, idx_name.S1PPOO);

		//		log.trace("checkRight query: pp={}, o1={}, o2={}", pp, getString(iterator_on_targets_of_hierarhical_departments[i]), getString(elementId));
		//		print_list_triple(iterator2);

		if(lookRightOfIterator(iterator2, rt_symbols + rightType, ts, authorizedElementCategory) == true)
			return true;
	}

	return false;
}

bool lookRightOfIterator(triple_list_element* iterator3, char* rightType, TripleStorage ts, char* authorizedElementCategory)
{

	//	print_list_triple(iterator3);

	{
		while(iterator3 !is null)
		{

			bool category_match = false;
			bool rights_match = false;

			Triple* triple3 = iterator3.triple;

			if(triple3 !is null)
			{
				char* s = cast(char*) triple3.s;
				char* p = cast(char*) triple3.p;

				triple_list_element* category_triples = ts.getTriples(s, CATEGORY.ptr, null);
				if(category_triples !is null)
				{
					Triple* category_triple = category_triples.triple;
					if(category_triple !is null)
					{
						char*	category = cast(char*) category_triple.o;
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
					char*	triple2_o = cast(char*) triple3.o;
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
			iterator3 = iterator3.next_triple_list_element;
		}
	}

	return false;
}
