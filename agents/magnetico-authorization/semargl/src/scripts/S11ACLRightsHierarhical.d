module scripts.S11ACLRightsHierarhical;

private import tango.io.Stdout;
private import tango.stdc.string;
private import tango.stdc.stringz;
private import tango.stdc.stdio;
private import tango.core.Thread;

private import Predicates;
private import RightTypeDef;
private import trioplax.TripleStorage;
private import script_util;
private import fact_tools;
private import trioplax.triple;
private import Log;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments,
		char[] pp, char* authorizedElementCategory)
{
	bool result = false;

	//@@@@
//	Thread.sleep(0.001);
//	log.trace("#1.1", result);
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

	//@@@@
//	Thread.sleep(0.001);
//	log.trace("#1.2");

	// найдем все ACL записи для заданных user и elementId 
	triple_list_element* iterator1 = cast (triple_list_element*)ts.getTriplesUseIndexS1PPOO(cast(char*) pp, user, elementId);
	

//	log.trace("checkRight query: pp={}, o1={}, o2={}", pp, getString(user), getString(elementId));
	//	print_list_triple(iterator1);

	bool res = lookRightOfIterator(iterator1, rt_symbols + rightType, ts, authorizedElementCategory);
	ts.list_no_longer_required (iterator1);
	
	if(res == true)
		return true;

	// проверим на вхождение elementId в вышестоящих узлах орг структуры
	for(int i = iterator_on_targets_of_hierarhical_departments.length - 1; i >= 0; i--)
	{
		triple_list_element* iterator2 = cast (triple_list_element*)ts.getTriplesUseIndexS1PPOO(cast(char*) pp, iterator_on_targets_of_hierarhical_departments[i], elementId);

		//		log.trace("checkRight query: pp={}, o1={}, o2={}", pp, getString(iterator_on_targets_of_hierarhical_departments[i]), getString(elementId));
		//		print_list_triple(iterator2);

		res = lookRightOfIterator(iterator2, rt_symbols + rightType, ts, authorizedElementCategory);
		ts.list_no_longer_required (iterator2);

		if(res == true)
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
				
				if (s is null)
				{
				    log.trace ("Exception: scripts.S11ACLRightsHierarhical.lookRightOfIterator (..)  subject is null, p = " ~ fromStringz (p));
				    throw new Exception ("scripts.S11ACLRightsHierarhical.lookRightOfIterator (..)  subject is null, p = " ~ fromStringz (p));
				}
				

				triple_list_element* category_triples = ts.getTriples(s, CATEGORY.ptr, null);
				triple_list_element* category_triples_FE = category_triples;
				
				if(category_triples !is null)
				{
					Triple* category_triple = category_triples.triple;
					if(category_triple !is null)
					{
						char*	category = cast(char*) category_triple.o;

						//@@@@
//						Thread.sleep(0.001);
//						log.trace("#2.1");
//						log.trace("# {} ?= {}", getString(authorizedElementCategory), getString(category));

						if(strcmp(authorizedElementCategory, category) == 0)
						{
							category_match = true;
						}
					}
					ts.list_no_longer_required (category_triples_FE);
				}

				if(category_match && strcmp(p, RIGHTS.ptr) == 0)
				{
					// проверим, есть ли тут требуемуе нами право
					char*	triple2_o = cast(char*) triple3.o;
//							log.trace ("#5 lookRightInACLRecord o={}", getString (triple2_o));

					bool is_actual = false;
					while(*triple2_o != 0)
					{
						//					  log.trace("lookRightOfIterator ('{}' || '{}' == '{}' ?)", *triple2_o, *(triple2_o + 1), *rightType);
						if(*triple2_o == *rightType || *(triple2_o + 1) == *rightType)
						{
							if(!is_actual)
								is_actual = is_subject_actual(s, ts);
							if(is_actual)
							{
								//@@@@
//								Thread.sleep(0.001);
//								log.trace("# subject = {} ", getString(s));

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
