module scripts.S10UserIsAuthorOfDocument;

private import Predicates;

private import tango.stdc.string;
private import TripleStorage;
private import tango.io.Stdout;
private import fact_tools;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts, uint* iterator_facts_of_document)
{

	// ! не ясно зачем это
	// Необрабатываемые параметры        	  
	//          if ((null==elementId)||('*'==elementId)) {
	//        	  log.debug('Unsupported elementId :'+elementId)
	//        	  return false
	//          }

	// ! не ясно зачем это
	// Если документа с заданным идентификатором нет (он только что созданный черновик) 
	//          def document 
	//          try 
	//	    {
	//   			  if (null == processFlow.store['getDocument:'+elementId]) { processFlow.store['getDocument:'+elementId] = iSystem.documentComponent.getDocument(elementId, false) }
	//        	  document = processFlow.store['getDocument:'+elementId]
	//          } catch (NoSuchElementException e) 
	//	    {
	//        	  log.debug('Document not commited yet.')
	//        	  return false	  
	//          } // иначе

	//	Stdout.format("UserIsAuthorOfDocument #1 document subject {}, user={}", getString(elementId), getString(user)).newline;

	// найдем автора документа
	//	uint* iterator0 = ts.getTriples(elementId, "http://purl.org/dc/elements/1.1/creator", user, false);

	if(iterator_facts_of_document !is null)
	{
		uint next_element0 = 0xFF;
		while(next_element0 > 0)
		{
			//			Stdout.format("UserIsAuthorOfDocument #2").newline;
			byte* triple0 = cast(byte*) *iterator_facts_of_document;

			if(triple0 !is null)
			{

				//			Stdout.format("UserIsAuthorOfDocument #2.1").newline;

				char* triple0_p = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1);
				//			Stdout.format("UserIsAuthorOfDocument #3 triple0_p={}", getString(triple0_p)).newline;

				if(strcmp(triple0_p, CREATOR.ptr) == 0)
				{
					char*
							triple0_o = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);

					if(strcmp(triple0_o, user) == 0)
					{
						//					Stdout.format("да! я автор документа {}", getString(elementId)).newline;
						return true;

					}
				}
			}
			next_element0 = *(iterator_facts_of_document + 1);
			iterator_facts_of_document = cast(uint*) next_element0;
		}
	}
	return false;

	/*		
	 
	 // найдем для этого автора группу
	 def authorId = document.authorId;
	 log.debug('AuthorId:'+authorId+' userId: '+ticket.userId+'.')
	 
	 if (ticket.userId == authorId){
	 if ((null!=document.documentDraftId)&&((RightType.DELETE == rightType)||(RightType.WRITE == rightType))) {
	 return false
	 } else {
	 return true
	 }
	 }    	
	 return false  
	 }
	 */
}
