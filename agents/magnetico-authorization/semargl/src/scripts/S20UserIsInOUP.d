module scripts.S20UserIsInOUP;

import TripleStorage;
import RightTypeDef;
private import Log;
private import tango.stdc.string;
private import HashMap;
private import tango.stdc.stringz;

static char* oupDepId = "f8c51331-b1d8-48ac-ae69-91af741f6320";
static char*[] documentTypeNames = [ "Инвестиционная заявка", "Инвестиционный проект", "Запрос на изменение Инвестиционного проекта" ];

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments)
{

	//log.trace("#1");
	

        bool result = false;

	if(rightType != RightType.READ)
		return false;

	//log.trace("#2");


	if(elementId is null || *elementId == '*')
	{
		log.trace("Неподдерживаемый идентификатор : {}.", elementId);
		return false;
	}

	//log.trace("#3");

	bool is_user_in_oup = false;
	if(strcmp(oupDepId, user) == 0) 
	{
		//log.trace("#31");
		is_user_in_oup = true;
	}
	else {
		//log.trace("#32 {:X4} {}", iterator_on_targets_of_hierarhical_departments, iterator_on_targets_of_hierarhical_departments.length);
		if (iterator_on_targets_of_hierarhical_departments !is null && iterator_on_targets_of_hierarhical_departments.length > 0) {
			for(int i = iterator_on_targets_of_hierarhical_departments.length - 1; i >= 0; i--)
			{
				//log.trace("#33 {}", i);
				if (strcmp(iterator_on_targets_of_hierarhical_departments[i], oupDepId) == 0) {
					//log.trace("#34");
					is_user_in_oup = true;
				}
			}
		}
	}
	//log.trace("#4");
	
	if(is_user_in_oup)
	{
		bool is_element_a_document = false;
		triple_list_element* facts = ts.getTriples(fromStringz(elementId), "magnet-ontology/authorization/acl#category", "DOCUMENT");
		if(facts !is null && facts.triple_ptr !is null)
			is_element_a_document = true;

		//log.trace("#5");
		
		if (is_element_a_document)
		{
			//log.trace("#6");
			
			facts = ts.getTriples(fromStringz(elementId), "magnet-ontology/documents#type_name", null);
			uint next_element0 = 0xFF;
			while(facts !is null && !result)
			{
					//log.trace("#8");
					
				triple *triple_ptr = facts.triple_ptr;
				if(triple_ptr !is null)
				{
					//log.trace("#8");
					for(uint i = 0; i < documentTypeNames.length; i++)
						if(strcmp(triple_ptr.o.ptr, documentTypeNames[i]) == 0)
						{
							result = true;
							break;
						}
					
				}
				facts = facts.next_triple_list_element;
			}
		}
		else
		{
		//	log.trace("Документ в состоянии черновика!");
		}

			
	} else
	{
	//	log.trace("Пользователь не в ОУП!");
	}
	
	return result;

}