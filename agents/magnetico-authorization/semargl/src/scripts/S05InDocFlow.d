module scripts.S05InDocFlow;

import RightTypeDef;
import TripleStorage;
import tango.stdc.stringz;
private import tango.io.Stdout;
//import str_tool;
import script_util;
private import Log;
private import HashMap;

public int calculate(char* user, char* elementId, uint rightType, TripleStorage ts)
{

	triple_list_element* iterator = ts.getTriples(null, "magnet-ontology/authorization/acl#elementId", fromStringz(elementId));
	char[] ACL_subject;

	bool is_in_docflow = false;

	while(iterator !is null)
	{
		triple* triple_ptr = iterator.triple_ptr;
	    if(triple_ptr !is null)
	      {
		      ACL_subject = *triple_ptr.s;
		      triple_list_element* iterator1 = ts.getTriples(ACL_subject, "magnet-ontology/authorization/acl#authorSystem", "DOCFLOW");

		      if(iterator1 !is null) // если не null, значит право с найденным субъектом создал документооборот
		      {
			      log.trace("isInDocFlow : subject = {} | s1", ACL_subject);
			      is_in_docflow = true;			  
			      triple_list_element* iterator2 = ts.getTriples(ACL_subject, "magnet-ontology/authorization/acl#targetSubsystemElement", fromStringz(user));
			      if(iterator2 !is null) // если не null, значит target для права это наш user
			      {

				      log.trace("isInDocFlow #2 {}", ACL_subject);

				      triple_list_element* iterator3 = ts.getTriples(ACL_subject, "magnet-ontology/authorization/acl#rights", null);
				      if(iterator3 !is null) 
				      {
			    
					      log.trace("isInDocFlow #3 | {}", ACL_subject);
			    
					      triple_ptr = iterator3.triple_ptr;
					      if(triple_ptr !is null)
					      {
						      log.trace("isInDocFlow #4 | {}", triple_ptr.s);
				
						      // проверим, есть ли тут требуемуе нами право

						      bool is_actual = false;
						      for(int i = 0; i < triple_ptr.o.length; i++)
						      {
							      log.trace("lookRightOfIterator ('{}' == '{}' ?)", triple_ptr.o[i], rightType);
							      if(*triple_ptr.o[i] == *(rt_symbols + rightType))
							      {
								      if(!is_actual)
									      is_actual = is_right_actual(ACL_subject.ptr, ts);
								      if(is_actual)
									      return 1;
								      else
									      break;
							      }
						      }
					      }
			    
				      }
			
			      }
		      }
	      }
	    iterator = iterator.next_triple_list_element;
	}
	if(is_in_docflow)
	  return 0;
	else
	  return -1;
}
