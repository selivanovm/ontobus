module scripts.S40UsersOfTAImport;

import TripleStorage;

import RightTypeDef;

private import Log;
private import tango.stdc.string;

static char* depId = "92e57b6d-83e3-485f-8885-0bade363f759";
static char*[] documentTypeNames = [ "Чертеж-IMPORT", "Конструкторский проект-IMPORT" ];


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
		for(uint i = iterator_on_targets_of_hierarhical_departments.length - 1; i >= 0; i--)
		{
			if (strcmp(iterator_on_targets_of_hierarhical_departments[i], depId) == 0)
				is_user_in_dep = true;
		}
	
	if(is_user_in_dep)
	{
		bool is_element_a_document = false;
		uint* facts = ts.getTriples(elementId, "magnet-ontology/authorization/acl#category", "DOCUMENT");
		if(facts !is null)
		{
			byte* triple = cast(byte*) *facts;
			if(triple !is null)
				is_element_a_document = true;
		}
		
		if (is_element_a_document)
		{
			facts = ts.getTriples(elementId, "magnet-ontology/documents#type_name", null);
			if(facts !is null)
			{
				uint next_element0 = 0xFF;
				while(next_element0 > 0 && !result)
				{
					byte* triple = cast(byte*) *facts;
					if(triple !is null)
					{
						char* o = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1 + 
								       (*(triple + 2) << 8) + *(triple + 3) + 1);
						for(uint i = 0; i < documentTypeNames.length; i++)
							if(strcmp(o, documentTypeNames[i]) == 0)
							{
								result = true;
								break;
							}
					
					}
					next_element0 = *(facts + 1);
					facts = cast(uint*) next_element0;
				}
			}
		}
		else
			log.trace("Документ в состоянии черновика!");

			
	} else
		log.trace("Пользователь не находится  в подразделении {}!", depId);
	
	return result;

}