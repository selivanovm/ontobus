module S01AllLoggedUsersCanCreateDocuments;

import RightTypeDef;
import TripleStorage;
private import tango.io.Stdout;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts)
{
	Stdout.format("S01AllLoggedUsersCanCreateDocuments is run... rightType={}", rightType).newline;

	if(rightType == RightType.CREATE)
	{
		return true;
	}
	return false;
}