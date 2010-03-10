module Predicates;

/////////////////////////////////////////////////////////////////////////////////////////

public static const char[] result_data_header_with_bracets = "><" ~ RESULT_DATA ~ ">{";
public static const char[] result_data_header = "><" ~ RESULT_DATA ~ ">\"";
public static const char[] result_state_ok_header = "><" ~ RESULT_STATE ~ ">\"ok\". ";
public static const char[] result_state_err_header = "><" ~ RESULT_STATE ~ ">\"er\". ";

alias char[] String;

/////////////////////////////////////////////////////////////////////////////////////////

public static const String NAMESPACE = "mo#";
public static const String AUTHORIZATION_FUNCTIONS_NAMESPACE = "mo/at/fn#";
public static const String AUTHORIZATION_ACL_NAMESPACE = "mo/at/acl#";
public static const String TRANSPORT_NAMESPACE = "mo/ts#";
public static const String TRANSPORT_MESSAGE_NAMESPACE = "mo/ts/msg#";
public static const String DOCUMENT_STORAGE_NAMESPACE = "mo/doc#";

public static const String FUNCTION_ARGUMENT = TRANSPORT_NAMESPACE ~ "arg";

public static const String RESULT_DATA = TRANSPORT_NAMESPACE ~ "r:d";
public static const String RESULT_STATE = TRANSPORT_NAMESPACE ~ "r:s";

public static const String REPLY_TO = TRANSPORT_MESSAGE_NAMESPACE ~ "r_t";

public static const String STATE_OK = "ok";
public static const String STATE_ERROR = "er";
public static const String STATE_WAITING = "wt";

public static const String SUBJECT = NAMESPACE ~ "sj";

public static const String SET_FROM = TRANSPORT_NAMESPACE ~ "sf";

public static const String DELETE_SUBJECTS = NAMESPACE ~ "ds";
public static const String DELETE_SUBJECTS_BY_PREDICATE = NAMESPACE ~ "dsp";    
public static const String PUT = NAMESPACE ~ "p";    
public static const String GET = NAMESPACE ~ "g";    

// категории объектов
//public static const String CATEGORY_DOCUMENT = "DOCUMENT";
//public static const String CATEGORY_DOCUMENT_DRAFT = "DOCUMENT_DRAFT";

// функции авторизации
public static const String CREATE = AUTHORIZATION_FUNCTIONS_NAMESPACE ~ "cr";
public static const String UPDATE = AUTHORIZATION_FUNCTIONS_NAMESPACE ~ "up";
//public static const String REMOVE_RECORDS_FOR_ELEMENT = AUTHORIZATION_FUNCTIONS_NAMESPACE ~ "rrfe";
public static const String GET_AUTHORIZATION_RIGHT_RECORDS = AUTHORIZATION_FUNCTIONS_NAMESPACE ~ "garr";
public static const String IS_IN_DOCFLOW = AUTHORIZATION_FUNCTIONS_NAMESPACE ~ "iid";
public static const String IS_ADMIN = AUTHORIZATION_FUNCTIONS_NAMESPACE ~ "ia";
public static const String GET_DELEGATE_ASSIGNERS = AUTHORIZATION_FUNCTIONS_NAMESPACE ~ "gda";
public static const String GET_DELEGATE_ASSIGNERS_TREE = AUTHORIZATION_FUNCTIONS_NAMESPACE ~ "gdat";
public static const String AUTHORIZE = AUTHORIZATION_FUNCTIONS_NAMESPACE ~ "a";

// делегаты
public static const String DELEGATION_DELEGATE = AUTHORIZATION_ACL_NAMESPACE ~ "de";
public static const String DELEGATION_OWNER = AUTHORIZATION_ACL_NAMESPACE ~ "ow";
public static const String DELEGATION_WITH_TREE = AUTHORIZATION_ACL_NAMESPACE ~ "wt";

// функции модуля справочников
public static const String GET_DICTIONARY_ID_BY_ATTRIBUTE_ID = NAMESPACE ~ "gdibai";
public static const String GET_DICTIONARY_ID_BY_RECORD_ID = NAMESPACE ~ "gdibri";
public static const String GET_DICTIONARY_RECORD_NAME_BY_ATTRIBUTE_ID = NAMESPACE ~ "grnbai";

// функции модуля аутентификации
public static const String GET_USER_BY_TICKET = NAMESPACE ~ "gubt";
public static const String IS_BANNED = NAMESPACE ~ "ib";

// документ
public static const String DOCUMENT_TYPE_NAME = DOCUMENT_STORAGE_NAMESPACE ~ "tpnm";
public static const String DOCUMENT_TEMPLATE_ID = DOCUMENT_STORAGE_NAMESPACE ~ "tmplid";

// запись о праве
public static const String AUTHOR_SYSTEM = AUTHORIZATION_ACL_NAMESPACE ~ "atS";
public static const String AUTHOR_SUBSYSTEM = AUTHORIZATION_ACL_NAMESPACE ~ "atSs";
public static const String AUTHOR_SUBSYSTEM_ELEMENT = AUTHORIZATION_ACL_NAMESPACE ~ "atSsE";
public static const String TARGET_SYSTEM = AUTHORIZATION_ACL_NAMESPACE ~ "tgS";
public static const String TARGET_SUBSYSTEM = AUTHORIZATION_ACL_NAMESPACE ~ "tgSs";
public static const String TARGET_SUBSYSTEM_ELEMENT = AUTHORIZATION_ACL_NAMESPACE ~ "tgSsE";
public static const String CATEGORY = AUTHORIZATION_ACL_NAMESPACE ~ "cat";
public static const String DATE_FROM = AUTHORIZATION_ACL_NAMESPACE ~ "dtF";
public static const String DATE_TO = AUTHORIZATION_ACL_NAMESPACE ~ "dtT";
public static const String ELEMENT_ID = AUTHORIZATION_ACL_NAMESPACE ~ "eId";
public static const String RIGHTS = AUTHORIZATION_ACL_NAMESPACE ~ "rt";

public static const String CREATOR = "pcr";
public static const String IDENTIFIER = "pid";
public static const String HAS_PART = NAMESPACE ~ "hsPt";
public static const String MEMBER_OF = NAMESPACE ~ "mmbOf";

