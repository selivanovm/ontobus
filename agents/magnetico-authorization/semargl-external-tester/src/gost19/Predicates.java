package gost19;

public class Predicates {

    public static String NAMESPACE = "mo#";
    public static String AUTHORIZATION_FUNCTIONS_NAMESPACE = "mo/at/fn#";
    public static String AUTHORIZATION_ACL_NAMESPACE = "mo/at/acl#";
    public static String TRANSPORT_NAMESPACE = "mo/ts#";
    public static String TRANSPORT_MESSAGE_NAMESPACE = "mo/ts/msg#";
    public static String DOCUMENT_STORAGE_NAMESPACE = "mo/doc#";

    public static String FUNCTION_ARGUMENT = TRANSPORT_NAMESPACE + "arg";

    public static String RESULT_DATA = TRANSPORT_NAMESPACE + "r:d";
    public static String RESULT_STATE = TRANSPORT_NAMESPACE + "r:s";

    public static String REPLY_TO = TRANSPORT_MESSAGE_NAMESPACE + "r_t";

    public static String STATE_OK = "ok";
    public static String STATE_ERROR = "er";
    public static String STATE_WAITING = "wt";

    public static String SUBJECT = NAMESPACE + "sj";

    public static String SET_FROM = TRANSPORT_NAMESPACE + "sf";

    public static String DELETE_SUBJECTS = NAMESPACE + "ds";
    public static String DELETE_SUBJECTS_BY_PREDICATE = NAMESPACE + "dsp";    
    public static String PUT = NAMESPACE + "p";    
    public static String GET = NAMESPACE + "g";    

    // категории объектов
    public static String CATEGORY_DOCUMENT = "DOCUMENT";
    public static String CATEGORY_DOCUMENT_DRAFT = "DOCUMENTDRAFT";

    // функции авторизации
    public static String CREATE = AUTHORIZATION_FUNCTIONS_NAMESPACE + "cr";
    public static String UPDATE = AUTHORIZATION_FUNCTIONS_NAMESPACE + "up";
    public static String GET_AUTHORIZATION_RIGHT_RECORDS = AUTHORIZATION_FUNCTIONS_NAMESPACE + "garr";
    public static String IS_IN_DOCFLOW = AUTHORIZATION_FUNCTIONS_NAMESPACE + "iid";
    public static String IS_ADMIN = AUTHORIZATION_FUNCTIONS_NAMESPACE + "ia";
    public static String GET_DELEGATE_ASSIGNERS = AUTHORIZATION_FUNCTIONS_NAMESPACE + "gda";
    public static String GET_DELEGATE_ASSIGNERS_TREE = AUTHORIZATION_FUNCTIONS_NAMESPACE + "gdat";
    public static String LIST_DELEGATES = AUTHORIZATION_FUNCTIONS_NAMESPACE + "getDelegatorsRecords";
    public static String AUTHORIZE = AUTHORIZATION_FUNCTIONS_NAMESPACE + "a";

    // делегаты
    public static String DELEGATION_DELEGATE = AUTHORIZATION_ACL_NAMESPACE + "de";
    public static String DELEGATION_OWNER = AUTHORIZATION_ACL_NAMESPACE + "ow";
    public static String DELEGATION_WITH_TREE = AUTHORIZATION_ACL_NAMESPACE + "wt";
    public static String DELEGATION_DOCUMENT_ID = AUTHORIZATION_ACL_NAMESPACE + "dg_doc_id";

    // функции модуля справочников
    public static String GET_DICTIONARY_ID_BY_ATTRIBUTE_ID = NAMESPACE + "gdibai";
    public static String GET_DICTIONARY_ID_BY_RECORD_ID = NAMESPACE + "gdibri";
    public static String GET_DICTIONARY_RECORD_NAME_BY_ATTRIBUTE_ID = NAMESPACE + "grnbai";

    // функции модуля аутентификации
    public static String GET_USER_BY_TICKET = NAMESPACE + "gubt";
    public static String IS_BANNED = NAMESPACE + "ib";

    // документ
    public static String DOCUMENT_TYPE_NAME = DOCUMENT_STORAGE_NAMESPACE + "tpnm";
    public static String DOCUMENT_TEMPLATE_ID = DOCUMENT_STORAGE_NAMESPACE + "tmplid";
    public static String INHERIT = DOCUMENT_STORAGE_NAMESPACE+ "inherit_rights";

    // запись о праве
    public static String AUTHOR_SYSTEM = AUTHORIZATION_ACL_NAMESPACE + "atS";
    public static String AUTHOR_SUBSYSTEM = AUTHORIZATION_ACL_NAMESPACE + "atSs";
    public static String AUTHOR_SUBSYSTEM_ELEMENT = AUTHORIZATION_ACL_NAMESPACE + "atSsE";
    public static String TARGET_SYSTEM = AUTHORIZATION_ACL_NAMESPACE + "tgS";
    public static String TARGET_SUBSYSTEM = AUTHORIZATION_ACL_NAMESPACE + "tgSs";
    public static String TARGET_SUBSYSTEM_ELEMENT = AUTHORIZATION_ACL_NAMESPACE + "tgSsE";
    public static String CATEGORY = AUTHORIZATION_ACL_NAMESPACE + "cat";
    public static String DATE_FROM = AUTHORIZATION_ACL_NAMESPACE + "dtF";
    public static String DATE_TO = AUTHORIZATION_ACL_NAMESPACE + "dtT";
    public static String ELEMENT_ID = AUTHORIZATION_ACL_NAMESPACE + "eId";
    public static String RIGHTS = AUTHORIZATION_ACL_NAMESPACE + "rt";

    public static String CREATOR = "pcr";
    public static String IDENTIFIER = "pid";
    public static String HAS_PART = NAMESPACE + "hsPt";
    public static String MEMBER_OF = NAMESPACE + "mmbOf";
    public static String LOGIN_NAME = "login";

}

/*public class Predicates {

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

    // делегаты
    public static String DELEGATION_DELEGATE = AUTHORIZATION_ACL_NAMESPACE + "delegate";
    public static String DELEGATION_OWNER = AUTHORIZATION_ACL_NAMESPACE + "owner";
    public static String DELEGATION_WITH_TREE = AUTHORIZATION_ACL_NAMESPACE + "withTree";

    // функции модуля справочников
    public static String GET_DICTIONARY_ID_BY_ATTRIBUTE_ID = NAMESPACE + "get_dictionary_id_by_attribute_id";
    public static String GET_DICTIONARY_ID_BY_RECORD_ID = NAMESPACE + "get_dictionary_id_by_record_id";
    public static String GET_DICTIONARY_RECORD_NAME_BY_ATTRIBUTE_ID = NAMESPACE + "get_record_name_by_attribute_id";

    // функции модуля аутентификации
    public static String GET_USER_BY_TICKET = NAMESPACE + "get_user_by_ticket";
    public static String IS_BANNED = NAMESPACE + "is_banned";

    // документ
    public static String DOCUMENT_TYPE_NAME = DOCUMENT_STORAGE_NAMESPACE + "type_name";
    public static String DOCUMENT_TEMPLATE_ID = DOCUMENT_STORAGE_NAMESPACE + "template_id";

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
}*/