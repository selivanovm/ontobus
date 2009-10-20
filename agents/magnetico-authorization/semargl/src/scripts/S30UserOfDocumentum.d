module scripts.S30UsersOfDocumentum;

import TripleStorage;

public bool calculate(char* user, char* elementId, uint rightType, TripleStorage ts, uint* iterator_facts_of_document)
{
	/*
	 def oupDepId = "c7750205-e7bd-47a8-b0e0-f13953a22d9c";
	 def documentTypeNames = ["Входящий документ (Documentum)","Приказ (Documentum)"];
	 
	 if(rightType != RightType.READ) return false
	 
	 //Необрабатываемые параметры        	  
	 if ((null==elementId)||('*'==elementId)) {
	 log.debug('Не поддерживаемый идентификатор :'+elementId)
	 return false
	 }
	 // получаем идентификатор подразделения пользователя
	 if (null == processFlow.store['getDepartmentUidByUserUid:'+ticket.userId]) { processFlow.store['getDepartmentUidByUserUid:'+ticket.userId]=iSystem.userManagementComponent.getDepartmentUidByUserUid(ticket.userId) }
	 def userDepId = processFlow.store['getDepartmentUidByUserUid:'+ticket.userId]
	 if ((userDepId==null)&&(oupDepId != ticket.userId)) return false

	 log.debug('Подразделение пользователя | :'+userDepId)
	 //если пользователь не в ОУП, выходим
	 if(!userDepId.equals(oupDepId)){
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
	 def inSet = documentTypeNames.contains(documentTypeName)
	 //узнаем, находится ли объект в документообороте
	 
	 //пересечем результат
	 return inSet
	 */
	return false;
}