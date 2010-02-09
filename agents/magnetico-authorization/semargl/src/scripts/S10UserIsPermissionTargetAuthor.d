module scripts.S10UserIsPermissionTargetAuthor;

private import Predicates;

private import TripleStorage;
private import tango.io.Stdout;
private import Log;
private import tango.stdc.string;
private import tango.stdc.stringz;

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
		author = getObjectAuthor(at, ts);
	}

	//log.trace("S10UserIsPermissionTargetAuthor #4 author = {}, user = {}", fromStringz(author), fromStringz(user));
	return (author !is null && strcmp(user, author) == 0);

}

private char* getObjectAuthor(char* elementId, TripleStorage ts)
{
	//log.trace("getObjectAuthor #START elementId = {}", fromStringz(elementId));
	uint* iterator_facts_of_document = ts.getTriples(elementId, null, null);
	//log.trace("getObjectAuthor #1");
	if(iterator_facts_of_document !is null)
	{
		uint next_element0 = 0xFF;
		while(next_element0 > 0)
		{
			//log.trace("getObjectAuthor #2");
			byte* triple0 = cast(byte*) *iterator_facts_of_document;
			//log.trace("getObjectAuthor #3");
			if(triple0 !is null)
			{
				//log.trace("getObjectAuthor #4");
				char* triple0_p = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1);
				//log.trace("getObjectAuthor #5");
				if(strcmp(triple0_p, CREATOR.ptr) == 0)
				{
					//log.trace("getObjectAuthor #6");
					char* result = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);
					//log.trace("getObjectAuthor #1 {}", fromStringz(result));
					return result;
				}
			}
			next_element0 = *(iterator_facts_of_document + 1);
			iterator_facts_of_document = cast(uint*) next_element0;
		}
	}
	return null;
}

private char* getRightRecordAuthor(char* elementId, TripleStorage ts)
{
	//	log.trace("getRightRecordAuthor #START");
	uint* iterator_facts_of_document = ts.getTriples(elementId, null, null);
	//	log.trace("getRightRecordAuthor #1");
	if(iterator_facts_of_document !is null)
	{
		uint next_element0 = 0xFF;
		while(next_element0 > 0)
		{
			//			log.trace("getRightRecordAuthor #2");
			byte* triple0 = cast(byte*) *iterator_facts_of_document;
			//			log.trace("getRightRecordAuthor #3");
			if(triple0 !is null)
			{
				//		log.trace("getRightRecordAuthor #4");
				char* triple0_p = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1);
				//				log.trace("getRightRecordAuthor #5");
				if(strcmp(triple0_p, AUTHOR_SUBSYSTEM_ELEMENT.ptr) == 0)
				{
					char* result = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);
					//					log.trace("getRightRecordAuthor #RESULT {}", fromStringz(result));
					return result;
				}
			}
			next_element0 = *(iterator_facts_of_document + 1);
			iterator_facts_of_document = cast(uint*) next_element0;
		}
	}
	return null;
}