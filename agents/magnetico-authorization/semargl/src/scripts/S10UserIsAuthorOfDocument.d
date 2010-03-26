module scripts.S10UserIsAuthorOfDocument;

private import tango.stdc.string;
private import tango.io.Stdout;

private import TripleStorage;
private import HashMap;
private import fact_tools;
private import Predicates;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts, triple_list_element* iterator_facts_of_document)
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

	{
		while(iterator_facts_of_document !is null)
		{
			//			Stdout.format("UserIsAuthorOfDocument #2").newline;
			Triple* triple0 = iterator_facts_of_document.triple;

			if(triple0 !is null)
			{

				//			Stdout.format("UserIsAuthorOfDocument #2.1").newline;

				char* triple0_p = cast(char*) triple0.p;
				//			Stdout.format("UserIsAuthorOfDocument #3 triple0_p={}", getString(triple0_p)).newline;

				if(strcmp(triple0_p, CREATOR.ptr) == 0)
				{
					char*	triple0_o = triple0.o;

					if(strcmp(triple0_o, user) == 0)
					{
						//					Stdout.format("да! я автор документа {}", getString(elementId)).newline;
						return true;

					}
				}
			}
			iterator_facts_of_document = iterator_facts_of_document.next_triple_list_element;
		}
	}
	return false;

}
