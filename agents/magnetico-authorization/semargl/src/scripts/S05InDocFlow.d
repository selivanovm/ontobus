module scripts.S05InDocFlow;

import RightTypeDef;
import TripleStorage;
import tango.stdc.stringz;
private import tango.io.Stdout;
//import str_tool;
import script_util;
private import Log;

public int calculate(char* user, char* elementId, uint rightType, TripleStorage ts)
{

	uint* iterator = ts.getTriples(null, "magnet-ontology/authorization/acl#elementId", elementId);
	char* ACL_subject;

	bool is_in_docflow = false;

	if(iterator !is null)
	{
	  uint next_element = 0xFF;
	  while(next_element > 0)
	  {
	    byte* triple = cast(byte*) *iterator; // берем субъект с нужным элементом
	    if(triple !is null)
	      {
		ACL_subject = cast(char*) triple + 6;
		uint* iterator1 = ts.getTriples(ACL_subject, "magnet-ontology/authorization/acl#authorSystem", "DOCFLOW");

		if(iterator1 !is null) // если не null, значит право с найденным субъектом создал документооборот
		  {
		    
		    log.trace("isInDocFlow : subject = {}", fromStringz(ACL_subject));
		    
		    uint* iterator2 = ts.getTriples(ACL_subject, "magnet-ontology/authorization/acl#targetSubsystemElement", user);
		    if(iterator2 !is null) // если не null, значит target для права это наш user
		      {
			
			log.trace("isInDocFlow #2");
			is_in_docflow = true;
			uint* iterator3 = ts.getTriples(ACL_subject, "magnet-ontology/authorization/acl#rights", null);
			if(iterator3 !is null) 
			  {
			    
			    log.trace("isInDocFlow #3");
			    
			    triple = cast(byte*) *iterator3;
			    if(triple !is null)
			      {
				
				log.trace("isInDocFlow #4");
				
				// проверим, есть ли тут требуемуе нами право
				char* triple2_o = cast(char*) (triple + 6 + (*(triple + 0) << 8) 
							       + *(triple + 1) + 1 + (*(triple + 2) << 8) + *(triple + 3) + 1);
				
				while(*triple2_o != 0)
				  {
				    log.trace("lookRightOfIterator ('{}' || '{}' == '{}' ?)", *triple2_o, *(triple2_o + 1), rightType);
				    if(*triple2_o == *(rt_symbols + rightType) || *(triple2_o + 1) == *(rt_symbols + rightType))
				      return 1;
				    triple2_o++;
				  }
			      }
			    
			  }
			
		      }
		  }
	      }
	    next_element = *(iterator + 1);
	    iterator = cast(uint*) next_element;
	  }

	}
	if(is_in_docflow)
	  return 0;
	else
	  return -1;
}
