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
	// Stdout.format("rightType = {}", rightType).newline;
	// Если документ хотят редактировать или удалять
	// Но он находится в документообороте
	char* df_right = isInDocFlow(elementId, ts);
	log.trace("isInDocFlow : subject = {}", fromStringz(df_right));
	if(df_right !is null)
	{

	  log.trace("isInDocFlow #1");

		uint* iterator = ts.getTriples(df_right, "magnet-ontology/authorization/acl#targetSubsystemElement", user);
		if(iterator !is null)
		{

		  log.trace("isInDocFlow #2");

			iterator = ts.getTriples(df_right, "magnet-ontology/authorization/acl#rights", null);
			if(iterator !is null)
			{

			  log.trace("isInDocFlow #3");

				byte* triple = cast(byte*) *iterator;
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
		return 0;
	}
	return -1;
}
