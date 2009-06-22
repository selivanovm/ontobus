module S01AllLoggedUsersCanCreateDocuments;

import RightTypeDef;
import TripleStorage;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts)
{
	if(rightType == RightType.CREATE)
	{
		return true;
	}
	return false;
}