module scripts.S10UserIsPermissionTargetAuthor;

private import tango.stdc.string;
private import tango.stdc.stringz;
private import tango.io.Stdout;

private import Predicates;
private import TripleStorage;
private import triple;
private import Log;

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
	triple_list_element* iterator_facts_of_document = ts.getTriples(elementId, null, null);
	triple_list_element* iterator_facts_of_document_FE = iterator_facts_of_document;
	//log.trace("getObjectAuthor #1");
	{
		while(iterator_facts_of_document !is null)
		{
			//log.trace("getObjectAuthor #2");
			Triple* triple0 = iterator_facts_of_document.triple;
			//log.trace("getObjectAuthor #3");
			if(triple0 !is null)
			{
				//log.trace("getObjectAuthor #4");
				char* triple0_p = cast(char*) triple0.p;
				//log.trace("getObjectAuthor #5");
				if(strcmp(triple0_p, CREATOR.ptr) == 0)
				{
					//log.trace("getObjectAuthor #6");
					char*	result = cast(char*) triple0.o;
					//log.trace("getObjectAuthor #1 {}", fromStringz(result));
					ts.list_no_longer_required (iterator_facts_of_document_FE);
					return result;
				}
			}
			iterator_facts_of_document = iterator_facts_of_document.next_triple_list_element;
		}
		ts.list_no_longer_required (iterator_facts_of_document_FE);

	}
	return null;
}

private char* getRightRecordAuthor(char* elementId, TripleStorage ts)
{
	//	log.trace("getRightRecordAuthor #START");
	triple_list_element* iterator_facts_of_document = ts.getTriples(elementId, null, null);
	triple_list_element* iterator_facts_of_document_FE = iterator_facts_of_document; 
	 //	log.trace("getRightRecordAuthor #1");
	{
		while(iterator_facts_of_document !is null)
		{
			//			log.trace("getRightRecordAuthor #2");
			Triple* triple0 = iterator_facts_of_document.triple;
			//			log.trace("getRightRecordAuthor #3");
			if(triple0 !is null)
			{
				//		log.trace("getRightRecordAuthor #4");
				char* triple0_p = cast(char*) triple0.p;
				//				log.trace("getRightRecordAuthor #5");
				if(strcmp(triple0_p, AUTHOR_SUBSYSTEM_ELEMENT.ptr) == 0)
				{
					char*	result = cast(char*) triple0.o;
					//					log.trace("getRightRecordAuthor #RESULT {}", fromStringz(result));
					ts.list_no_longer_required (iterator_facts_of_document_FE);
					return result;
				}
			}
			iterator_facts_of_document = iterator_facts_of_document.next_triple_list_element;
		}
		ts.list_no_longer_required (iterator_facts_of_document_FE);

	}
	return null;
}