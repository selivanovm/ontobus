module scripts.S10UserIsPermissionTargetAuthor;

private import TripleStorage;
private import tango.io.Stdout;
private import Log;
private import tango.stdc.string;
private import tango.stdc.stringz;
private import HashMap;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts)
{

	/*
	 * If elementId contains @ => somebody asks "Can I create right record for object with id == elementId.
	 * If elementId !contains @ => somebody asks "Can I update/delete right record with id == elementId" 
	 */

	//log.trace("S10UserIsPermissionTargetAuthor #START");

	// do you see any dogs right here?
	char* at = null;
	for(uint i = 0; i < strlen(elementId); i++)
	{
		if(*(elementId + i) == '@')
		// i see the dog. right here.
		{
			at = elementId + i + 1;
			break;
		}
	}

	//log.trace("S10UserIsPermissionTargetAuthor #1");
	char* author = null;
	if(at is null)
	// elementId - id of existing right record?
	{
		//log.trace("S10UserIsPermissionTargetAuthor #2");
		author = getRightRecordAuthor(elementId, ts);
	}
	else
	// elementId - object id
	{
		//log.trace("S10UserIsPermissionTargetAuthor #3");
		author = getObjectAuthor(at, ts).ptr;
	}

	//log.trace("S10UserIsPermissionTargetAuthor #4 author = {}, user = {}", fromStringz(author), fromStringz(user));
	return (author !is null && strcmp(user, author) == 0);

}

private char[] getObjectAuthor(char* elementId, TripleStorage ts)
{
	//log.trace("getObjectAuthor #START elementId = {}", fromStringz(elementId));
	triple_list_element* iterator_facts_of_document = ts.getTriples(fromStringz(elementId), null, null);
	//log.trace("getObjectAuthor #1");
	while(iterator_facts_of_document !is null)
	{
		//log.trace("getObjectAuthor #2");
		triple* triple0 = iterator_facts_of_document.triple_ptr;
		//log.trace("getObjectAuthor #3");
		if(triple0 !is null)
		{
			//log.trace("getObjectAuthor #4");
			if(strcmp(triple0.p.ptr, "http://purl.org/dc/elements/1.1/creator") == 0)
			{
				//log.trace("getObjectAuthor #6");
				return triple0.o;
			}
		}
		iterator_facts_of_document = iterator_facts_of_document.next_triple_list_element;
	}
	return null;
}

private char* getRightRecordAuthor(char* elementId, TripleStorage ts)
{
	//	log.trace("getRightRecordAuthor #START");
	triple_list_element* iterator_facts_of_document = ts.getTriples(fromStringz(elementId), null, null);
	//	log.trace("getRightRecordAuthor #1");
	while(iterator_facts_of_document !is null)
	{
		//			log.trace("getRightRecordAuthor #2");
		triple* triple0 = iterator_facts_of_document.triple_ptr;
		//			log.trace("getRightRecordAuthor #3");
		if(triple0 !is null)
		{
			//		log.trace("getRightRecordAuthor #4");
			if(strcmp(triple0.p.ptr, "magnet-ontology/authorization/acl#authorSubsystemElement") == 0)
			{
				return triple0.o.ptr;
			}
		}
		iterator_facts_of_document = iterator_facts_of_document.next_triple_list_element;
	}
	return null;
}