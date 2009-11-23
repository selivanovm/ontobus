module scripts.S11ACLRightsHierarhical;

import RightTypeDef;
import TripleStorage;
private import tango.io.Stdout;
private import script_util;
private import tango.stdc.string;
private import tango.stdc.posix.stdio;
private import tango.stdc.stringz;

private import fact_tools;
private import Log;

private import HashMap;


public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments,
		char[] pp)
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
			result = checkRight(user, elementId, rightType, ts, iterator_on_targets_of_hierarhical_departments, pp);
		}
	}
	else
	{
		// иначе выдадим все права выданные системой электоронного архива
		//					result = iSystem.authorizationComponent.checkRight(null , null, null, "BA", null, orgIds, category, elementId, rightType);
		result = checkRight(user, elementId, rightType, ts, iterator_on_targets_of_hierarhical_departments, pp);
	}

	return result;
}

bool checkRight(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments, char[] pp)
{
	//	log.trace("S11ACLRightsHierarhical.checkRight #0 hierarhical_departments.length = {}", iterator_on_targets_of_hierarhical_departments.length);

	// найдем все ACL записи для заданных user и elementId 
	triple_list_element* iterator1 = ts.getTriplesUseIndex(pp, fromStringz(user), fromStringz(elementId), idx_name.S1PPOO);

	//	log.trace("checkRight query: pp={}, o1={}, o2={}", pp, getString(user), getString(elementId));
	//	print_list_triple(iterator1);

	if(lookRightOfIterator(iterator1, rt_symbols + rightType, ts) == true)
		return true;

	// проверим на вхождение elementId в вышестоящих узлах орг структуры
	for(int i = iterator_on_targets_of_hierarhical_departments.length - 1; i >= 0; i--)
	{
		triple_list_element* iterator2 = ts.getTriplesUseIndex(pp, fromStringz(iterator_on_targets_of_hierarhical_departments[i]), fromStringz(elementId), idx_name.S1PPOO);

		//		log.trace("checkRight query: pp={}, o1={}, o2={}", pp, getString(iterator_on_targets_of_hierarhical_departments[i]), getString(elementId));
		//		print_list_triple(iterator2);

		if(lookRightOfIterator(iterator2, rt_symbols + rightType, ts) == true)
			return true;
	}

	return false;
}

bool lookRightOfIterator(triple_list_element* iterator3, char* rightType, TripleStorage ts)
{

	//		log.trace("checkRight query: p1={}, p2={}, o1={}, o2={}", "magnet-ontology/authorization/acl#targetSubsystemElement",
	//				"magnet-ontology/authorization/acl#elementId", getString(user), getString(elementId));
	//		print_list_triple(iterator1);

	while(iterator3 !is null)
	{
		triple *triple3 = iterator3.triple_ptr;
		
		if(triple3 !is null)
		{
			if(strcmp(triple3.p.ptr, "magnet-ontology/authorization/acl#rights") == 0)
			{
				// проверим, есть ли тут требуемуе нами право
				bool is_actual = false;
				for(int i = 0; i < triple3.o.length; i++)
				{
						//					  log.trace("lookRightOfIterator ('{}' || '{}' == '{}' ?)", *triple2_o, *(triple2_o + 1), *rightType);
					if(*triple3.o[i] == *rightType)
					{
						if(!is_actual)
							is_actual = is_right_actual(triple3.s.ptr, ts);
						if(is_actual)
							return true;
						else
							break;
					}
				}
			}
			iterator3 = iterator3.next_triple_list_element;
		}
	}

	return false;
}

/*
 bool checkRight(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments)
 {
 //	log.trace("S11ACLRightsHierarhical.checkRight #0 hierarhical_departments.length = {}", iterator_on_targets_of_hierarhical_departments.length);

 uint* iterator_subjects_of_elementId;

 // найдем все ACL записи для этого документа
 uint* iterator1 = ts.getTriples(null, "magnet-ontology/authorization/acl#elementId", elementId, false);
 iterator_subjects_of_elementId = iterator1;

 //	log.trace("query: s={}, p={}, o={}", null, "magnet-ontology/authorization/acl#elementId", getString (elementId));
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

 if(triple1 !is null)
 {

 char* acl_subject = cast(char*) triple1 + 6;

 // проверим на вхождение elementId в вышестоящих узлах орг структуры
 for(int i = 0; i < iterator_on_targets_of_hierarhical_departments.length; i++)
 {
 if(lookRightInACLRecord(rightType, acl_subject, iterator_on_targets_of_hierarhical_departments[i], ts) == true)
 {
 //						log.trace("#!1 ret");
 return true;
 }
 }
 if(lookRightInACLRecord(rightType, acl_subject, user, ts) == true)
 {
 //					log.trace("#!2 ret");
 return true;
 }

 }
 next_element1 = *(iterator1 + 1);
 iterator1 = cast(uint*) next_element1;
 }
 }
 
 //	log.trace("#!3 ret = {}", this_user_in_ACL);
 return this_user_in_ACL;
 }
 */

/*
 bool lookRightInACLRecord(uint rightType, char* ACLRecordSubject, char* target, TripleStorage ts)
 {
 // возьмем факты этой записи ACL
 uint* iterator2 = ts.getTriples(ACLRecordSubject, "magnet-ontology/authorization/acl#targetSubsystemElement", target, false);

 //	log.trace("query: s={}, p={}, o={}", getString(ACLRecordSubject), "magnet-ontology/authorization/acl#targetSubsystemElement", getString(target));
 //	print_list_triple(iterator2);

 if(iterator2 !is null)
 {
 //		log.trace ("#1 lookRightInACLRecord ACLRecordSubject={}, target={}", getString (ACLRecordSubject), getString (target));
 // это означает, что данная ACL запись содержит нашего пользователя в качестве target
 // теперь считаем сами права

 uint* iterator3 = ts.getTriples(ACLRecordSubject, "magnet-ontology/authorization/acl#rights", null, false);

 //		log.trace("query: s={}, p={}, o={}", getString(ACLRecordSubject), "magnet-ontology/authorization/acl#rights", null);
 //		print_list_triple(iterator3);

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
 //					log.trace ("#5 lookRightInACLRecord o={}", getString (triple2_o));

 while(*triple2_o != 0)
 {
 //						Stdout.format("S11ACLRightsHierarhical.checkRight #5 ?").newline;

 if((rightType == RightType.READ) && (*triple2_o == 'r' || *(triple2_o + 1) == 'r'))
 {
 //Stdout.format("S11ACLRightsHierarhical.checkRight #6 YES").newline;
 return true;
 }
 triple2_o++;
 }

 }
 next_element3 = *(iterator3 + 1);
 iterator3 = cast(uint*) next_element3;
 }
 }
 }

 return false;
 }
 */