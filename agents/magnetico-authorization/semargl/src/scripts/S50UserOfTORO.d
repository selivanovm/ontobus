module scripts.S50UserOfTORO;

import TripleStorage;

import RightTypeDef;

private import Log;
private import tango.stdc.string;
private import tango.stdc.stringz;
private import HashMap;

static char* depId = "92e57b6d-83e3-485f-8885-0bade363f759";
static char*[] documentTypeNames = [ "Комплект чертежей", "Конструкторский проект", "Чертеж", "Чертеж ТОРО", 
		    "Ведомость дефектов", "Отчет о ремонте", "Протокол измерений", "Техническая документация", "Паспорт", "Эскиз" ];


public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments)
{
        bool result = false;

	if(rightType != RightType.READ)
		return false;

	if(elementId is null || *elementId == '*')
	{
		log.trace("Неподдерживаемый идентификатор : {}.", elementId);
		return false;
	}

	bool is_user_in_dep = false;
	if(strcmp(depId, user) == 0)
		is_user_in_dep = true;
	else
		if (iterator_on_targets_of_hierarhical_departments !is null && iterator_on_targets_of_hierarhical_departments.length > 0) {
			for(int i = iterator_on_targets_of_hierarhical_departments.length - 1; i >= 0; i--)
			{
				if (strcmp(iterator_on_targets_of_hierarhical_departments[i], depId) == 0)
					is_user_in_dep = true;
			}
		}
	
	if(is_user_in_dep)
	{
		bool is_element_a_document = false;
		triple_list_element* facts = ts.getTriples(fromStringz(elementId), "magnet-ontology/authorization/acl#category", "DOCUMENT");
		if(facts !is null && facts.triple_ptr !is null)
			is_element_a_document = true;
		
		if (is_element_a_document)
		{
			facts = ts.getTriples(fromStringz(elementId), "magnet-ontology/documents#type_name", null);
			while(facts !is null && !result)
			{
				triple* triple_ptr = facts.triple_ptr;
				if(triple_ptr !is null)
				{
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
	}
	else
	{
		//	log.trace("Документ в состоянии черновика!");
	}
	return result;

}