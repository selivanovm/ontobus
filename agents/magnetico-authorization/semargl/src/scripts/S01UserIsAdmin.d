module scripts.S01UserIsAdmin;

private import TripleStorage;
private import tango.io.Stdout;
private import Log;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts)
{
	if(isAdmin(user, ts))
	{
//		log.trace("User is admin");

		return true;
	}
	return false;
}

public bool isAdmin(char* user, TripleStorage ts)
{
	uint* iterator0 = ts.getTriples(user, "magnet-ontology/authorization/functions#is_admin", "true", false);

	if(iterator0 != null)
		return true;

	return false;
}