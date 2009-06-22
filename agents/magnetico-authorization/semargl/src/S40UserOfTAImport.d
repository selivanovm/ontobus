module S40UsersOfTAImport;

import TripleStorage;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts,
                      uint* iterator_facts_of_document)
{
/*	
		def mondiDepId = '92e57b6d-83e3-485f-8885-0bade363f759';
		def documentTypeNames = ['Чертеж-IMPORT', 'Конструкторский проект-IMPORT'];
		
		if(rightType != RightType.READ) {
			return false
		}
		
	    //Необрабатываемые параметры        	  
	    if ((null == elementId) || ('*' == elementId)) {
	    	log.debug('Не поддерживаемый идентификатор :'+elementId)
	        return false
	    }
	    // получаем идентификатор подразделения пользователя
        if (null == processFlow.store['getDepartmentUidByUserUid:'+ticket.userId]) {
        	processFlow.store['getDepartmentUidByUserUid:'+ticket.userId] = iSystem.userManagementComponent.getDepartmentUidByUserUid(ticket.userId)
        }
        def userDepId = processFlow.store['getDepartmentUidByUserUid:'+ticket.userId]
        if (userDepId == null) {
        	return false
        }

   	    log.debug('Подразделение пользователя | :'+userDepId)
   	    //если пользователь не в Монди (или в нижележащем подразделении), выходим
   	    //if (null == processFlow.store['getDepartmentTreePathUids:'+userDepId]) {
   	    //	processFlow.store['getDepartmentTreePathUids:'+userDepId] = iSystem.userManagementComponent.getDepartmentTreePathUids(userDepId)
   	    //}
   	    if (null == processFlow.store['getDepartmentTreePath:'+userDepId]) {
   	    	processFlow.store['getDepartmentTreePath:'+userDepId] = iSystem.userManagementComponent.getDepartmentTreePath(userDepId, 'ru')
   	    }
   	    //def treePath = processFlow.store['getDepartmentTreePathUids:'+userDepId]
   	    def treePathIds = processFlow.store['getDepartmentTreePath:'+userDepId].collect {
   	    	it.getId()
   	    }
   	    if(!treePathIds.contains(mondiDepId)) {
            return false
   	    }
   	    
	    //Если документа с заданным идентификатором нет (он только что созданный черновик) 
        def document = null;
        try {
 			if (null == processFlow.store['getDocument:'+elementId]) { processFlow.store['getDocument:'+elementId] = iSystem.documentComponent.getDocument(elementId, false) }
 	        document = processFlow.store['getDocument:'+elementId]
        } catch (NoSuchElementException e) {
        	log.debug('Документ в состоянии черновика.');
        	return false
        }// иначе
	    //получим тип документа
        def documentTypeId = document.typeId 
        def documentType = null;
        try {
	    	documentType = iSystem.documentComponent.getDocumentType(documentTypeId, false);
	    } catch (NoSuchElementException e) {
	    	log.debug('Невозможно найти тип документа для идентификатора :'+ documentTypeId);
    		return false
	    }
	    
	    //получаем имя типа документа
	    def documentTypeName = documentType.name
	    //проверим есть ли это имя в нашем множестве имен типов документов
	    boolean inSet = documentTypeNames.contains(documentTypeName)
	    
		//пересечем результат
		return inSet
	}
*/
	return false;
}