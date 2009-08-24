module scripts.S05InDocFlow;

import RightTypeDef;
import TripleStorage;
private import tango.io.Stdout;
import str_tool;
import script_util;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts)
{
	// Stdout.format("rightType = {}", rightType).newline;
	// Если документ хотят редактировать или удалять
	if((rightType == RightType.WRITE) || (rightType == RightType.DELETE))
	{
		// Но он находится в документообороте
		if(isInDocFlow(elementId, ts))
		{
			//  			   log.debug('Документ находится в документообороте. Доступ для модификации запрещён.')
			return true;
		}

	}
	return false;

}
