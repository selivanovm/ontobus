module scripts.S20UserIsInOUP;

import TripleStorage;
import RightTypeDef;
private import Log;
private import tango.stdc.string;

static char* oupDepId = "f8c51331-b1d8-48ac-ae69-91af741f6320";
static char*[] documentTypeNames = [ "Инвестиционная заявка","Инвестиционный проект", "Запрос на изменение Инвестиционного проекта" ];

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

	bool is_user_in_oup = false;
	if(strcmp(oupDepId, user) == 0)
		is_user_in_oup = true;
	else
		for(uint i = iterator_on_targets_of_hierarhical_departments.length - 1; i >= 0; i--)
		{
			if (strcmp(iterator_on_targets_of_hierarhical_departments[i], oupDepId) == 0)
				is_user_in_oup = true;
		}
	
	if(is_user_in_oup)
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
		log.trace("Пользователь не в ОУП!");
	
	return result;

}