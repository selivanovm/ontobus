module scripts.S01UserIsAdmin;

private import TripleStorage;
private import tango.io.Stdout;
private import tango.stdc.stringz;
private import Log;

static private bool[char[]] cache;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts, char*[] iterator_on_targets_of_hierarhical_departments)
{

	//log.trace("!!! l={}", iterator_on_targets_of_hierarhical_departments.length);

	char[] uzer = fromStringz(user);

	bool *is_admin = (uzer in cache);
	if(is_admin == null)
	{
		if(isAdmin(user, ts))
		{
			//		log.trace("User is admin");
			cache[uzer] = true;
			return true;
		} else {
			for(int i = 0; i < iterator_on_targets_of_hierarhical_departments.length; i++)
			{
				//log.trace("!!! {}", fromStringz(iterator_on_targets_of_hierarhical_departments[i]));
				if(isAdmin(iterator_on_targets_of_hierarhical_departments[i], ts)) {
					cache[uzer] = true;
					return true;
				}
			}
			
		}
		cache[uzer] = false;
		return false;
	}
	return *is_admin;
}

public bool isAdmin(char* user, TripleStorage ts)
{

	uint* iterator0 = ts.getTriples(user, "magnet-ontology/authorization/functions#is_admin", "true");
	
	if(iterator0 != null)
		return true;
	else
		return false;
}