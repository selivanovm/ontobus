module scripts.S01AllLoggedUsersCanCreateDocuments;

private import tango.io.Stdout;

private import RightTypeDef;
private import Predicates;
private import TripleStorage;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts)
{
	//	Stdout.format("S01AllLoggedUsersCanCreateDocuments is run... rightType={}", rightType).newline;

	if(rightType == RightType.CREATE)
	{
		return true;
	}
	return false;
}