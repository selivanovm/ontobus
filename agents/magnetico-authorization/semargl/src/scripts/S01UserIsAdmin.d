module scripts.S01UserIsAdmin;

private import TripleStorage;
private import tango.io.Stdout;
private import tango.stdc.stringz;
private import Log;
private import HashMap;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments)
{

	//log.trace("!!! l={}", iterator_on_targets_of_hierarhical_departments.length);

	if(isAdmin(user, ts))
	{
		//		log.trace("User is admin");

		return true;
	} else {
		for(int i = 0; i < iterator_on_targets_of_hierarhical_departments.length; i++)
		{
			//log.trace("!!! {}", fromStringz(iterator_on_targets_of_hierarhical_departments[i]));
			if(isAdmin(iterator_on_targets_of_hierarhical_departments[i], ts)) {

				return true;
			}
		}

	}
	return false;
}

public bool isAdmin(char* user, TripleStorage ts)
{
	triple_list_element* iterator0 = ts.getTriples(fromStringz(user), "magnet-ontology/authorization/functions#is_admin", "true");

	if(iterator0 != null)
		return true;

	return false;
}