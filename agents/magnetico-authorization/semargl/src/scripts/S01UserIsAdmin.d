module scripts.S01UserIsAdmin;

import TripleStorage;
private import tango.io.Stdout;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts)
{
	if(isAdmin(user, ts))
	{
		//        	log.debug('User is admin')
		Stdout.format("i'm admin").newline;

		return true;
	}
	return false;
}

public bool isAdmin(char* user, TripleStorage ts)
{
	uint* iterator0 = ts.getTriples(user, "magnet-ontology#isAdmin", "true", false);

	if(iterator0 != null)
		return true;

	return false;
}