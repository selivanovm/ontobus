/**
 * Copyright (c) 2006-2009, Magnetosoft, LLC
 * All rights reserved.
 *
 * Licensed under the Magnetosoft License. You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.magnetosoft.ru/LICENSE
 * 
 */

package gost19.amqp.messaging;

public class Predicates {

    public static String NAMESPACE = "magnet-ontology#";
    public static String AUTHORIZATION_FUNCTIONS_NAMESPACE = "magnet-ontology/authorization/functions#";
    public static String AUTHORIZATION_ACL_NAMESPACE = "magnet-ontology/authorization/acl#";
    public static String TRANSPORT_NAMESPACE = "magnet-ontology/transport#";
    public static String TRANSPORT_MESSAGE_NAMESPACE = "magnet-ontology/transport/message#";
    public static String DOCUMENT_STORAGE_NAMESPACE = "magnet-ontology/documents#";

    public static String FUNCTION_ARGUMENT = TRANSPORT_NAMESPACE + "argument";

    public static String RESULT_DATA = TRANSPORT_NAMESPACE + "result:data";
    public static String RESULT_STATE = TRANSPORT_NAMESPACE + "result:state";

    public static String REPLY_TO = TRANSPORT_MESSAGE_NAMESPACE + "reply_to";

    public static String STATE_OK = "ok";
    public static String STATE_ERROR = "error";
    public static String STATE_WAITING = "waiting";

    public static String SUBJECT = NAMESPACE + "subject";

    public static String SET_FROM = TRANSPORT_NAMESPACE + "set_from";

    public static String DELETE_SUBJECTS = NAMESPACE + "delete_subjects";
    public static String DELETE_SUBJECTS_BY_PREDICATE = NAMESPACE + "delete_subjects_by_predicate";    
    public static String PUT = NAMESPACE + "put";    
    public static String GET = NAMESPACE + "get";    

    // категории объектов
    public static String CATEGORY_DOCUMENT = "DOCUMENT";
    public static String CATEGORY_DOCUMENT_DRAFT = "DOCUMENT_DRAFT";

    // функции авторизации
    public static String CREATE = AUTHORIZATION_FUNCTIONS_NAMESPACE + "create";
    public static String UPDATE = AUTHORIZATION_FUNCTIONS_NAMESPACE + "update";
    public static String REMOVE_RECORDS_FOR_ELEMENT = AUTHORIZATION_FUNCTIONS_NAMESPACE + "remove_records_for_element";
    public static String GET_AUTHORIZATION_RIGHT_RECORDS = AUTHORIZATION_FUNCTIONS_NAMESPACE + "get_authorization_rights_records";
    public static String IS_IN_DOCFLOW = AUTHORIZATION_FUNCTIONS_NAMESPACE + "is_in_docflow";
    public static String IS_ADMIN = AUTHORIZATION_FUNCTIONS_NAMESPACE + "is_admin";
    public static String GET_DELEGATE_ASSIGNERS = AUTHORIZATION_FUNCTIONS_NAMESPACE + "get_delegate_assigners";
    public static String GET_DELEGATE_ASSIGNERS_TREE = AUTHORIZATION_FUNCTIONS_NAMESPACE + "get_delegate_assigners_tree";
    public static String AUTHORIZE = AUTHORIZATION_FUNCTIONS_NAMESPACE + "authorize";

    // функции модуля справочников
    public static String GET_DICTIONARY_ID_BY_ATTRIBUTE_ID = NAMESPACE + "get_dictionary_id_by_attribute_id";
    public static String GET_DICTIONARY_ID_BY_RECORD_ID = NAMESPACE + "get_dictionary_id_by_record_id";
    public static String GET_DICTIONARY_RECORD_NAME_BY_ATTRIBUTE_ID = NAMESPACE + "get_record_name_by_attribute_id";

    // функции модуля аутентификации
    public static String GET_USER_BY_TICKET = NAMESPACE + "get_user_by_ticket";
    public static String IS_BANNED = NAMESPACE + "is_banned";

    // документ
    public static String DOCUMENT_TYPE_NAME = DOCUMENT_STORAGE_NAMESPACE + "type_name";

    // запись о праве
    public static String AUTHOR_SYSTEM = AUTHORIZATION_ACL_NAMESPACE + "authorSystem";
    public static String AUTHOR_SUBSYSTEM = AUTHORIZATION_ACL_NAMESPACE + "authorSubsystem";
    public static String AUTHOR_SUBSYSTEM_ELEMENT = AUTHORIZATION_ACL_NAMESPACE + "authorSubsystemElement";
    public static String TARGET_SYSTEM = AUTHORIZATION_ACL_NAMESPACE + "targetSystem";
    public static String TARGET_SUBSYSTEM = AUTHORIZATION_ACL_NAMESPACE + "targetSubsystem";
    public static String TARGET_SUBSYSTEM_ELEMENT = AUTHORIZATION_ACL_NAMESPACE + "targetSubsystemElement";
    public static String CATEGORY = AUTHORIZATION_ACL_NAMESPACE + "category";
    public static String DATE_FROM = AUTHORIZATION_ACL_NAMESPACE + "dateFrom";
    public static String DATE_TO = AUTHORIZATION_ACL_NAMESPACE + "dateTo";
    public static String ELEMENT_ID = AUTHORIZATION_ACL_NAMESPACE + "elementId";
    public static String RIGHTS = AUTHORIZATION_ACL_NAMESPACE + "rights";

    public static String CREATOR = "http://purl.org/dc/elements/1.1/creator";
    public static String IDENTIFIER = "http://purl.org/dc/elements/1.1/identifier";
    public static String HAS_PART = NAMESPACE + "hasPart";
    public static String MEMBER_OF = NAMESPACE + "memberOf";
}