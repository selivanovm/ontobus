module scripts.S09DocumentOfTemplate;

import TripleStorage;

import RightTypeDef;

private import Log;
private import tango.stdc.string;
private import scripts.S11ACLRightsHierarhical;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments,
		char[] pp)
{
        bool result = false;

	if(rightType != RightType.READ)
		return false;

	if(elementId is null || *elementId == '*')
	{
		log.trace("Неподдерживаемый идентификатор : {}.", elementId);
		return false;
	}

	byte* template_triple;
	uint* facts = ts.getTriples(elementId, "magnet-ontology/documents#template_id", null);
	if(facts !is null)
	{
		template_triple = cast(byte*) *facts;
		if(template_triple !is null)
		{
			char* template_id = cast(char*) (template_triple + 6 + (*(template_triple + 0) << 8) + *(template_triple + 1) + 1 + (*(template_triple + 2) << 8) + *(template_triple + 3) + 1);
			result = scripts.S11ACLRightsHierarhical.checkRight(user, template_id, rightType, ts, iterator_on_targets_of_hierarhical_departments, pp);	
		}
	}
	return result;

}