package ru.magnetosoft.em2onto;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.net.MalformedURLException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.xml.namespace.QName;

import ru.magnetosoft.bigarch.wsclient.bl.documentservice.BigArchiveServerException_Exception;
import ru.magnetosoft.bigarch.wsclient.bl.documentservice.DocumentType;
import ru.magnetosoft.bigarch.wsclient.bl.documentservice.DocumentTemplateType;
import ru.magnetosoft.bigarch.wsclient.bl.organizationservice.AttributeType;
import ru.magnetosoft.bigarch.wsclient.bl.organizationservice.EntityType;
import ru.magnetosoft.objects.document.Document;
import ru.magnetosoft.objects.documenttype.TypeAttribute;
import ru.magnetosoft.objects.organization.Department;
import ru.magnetosoft.magnet.messaging.Predicates;

public class Fetcher {

    private static String documentTypeId;
    private static String ticketId;
    private static String SEARCH_URL;
    private static QName SEARCH_QNAME = new QName("http://search.bigarchive.magnetosoft.ru/", "SearchService");
    private static String DOCUMENT_URL;
    private static String pathToDump;
    private static boolean fake = false;
    private static Properties properties = new Properties();
    private static ArrayList<String> roles = new ArrayList<String>();
    private static ArrayList<String> admins = new ArrayList<String>();
    private static String dbUser;
    private static String dbPassword;
    private static String dbUrl;

    public static void main(String[] args) {

        loadProperties();

        if (args.length == 1) {

            if (args[0].equals("dir")) {
                fetchDirectives();
            } else if (args[0].equals("org")) {
                fetchOrganization();
            } else if (args[0].equals("all")) {
                fetchAllDocuments();
            } else if (args[0].equals("dtp")) {
                fetchDocumentTypes();
            } else if (args[0].equals("att")) {
                //fetchAttachments();
            } else if (args[0].equals("auth")) {
                fetchAuthorizationData();
            }

        }

    }

    /**
     * Выгружает все типы документов
     * в виде триплетов
     */
    private static void fetchDocumentTypes() {

        try {

            long fetchStart = System.nanoTime();

            BufferedWriter out = null;
            if (!fake) {
                out = new BufferedWriter(new FileWriter(pathToDump));
            }

            List<DocumentTemplateType> types = DocumentUtil.getInstance().listDocumentTypes(DOCUMENT_URL, ticketId);

            System.out.println("Got " + types.size() + " docTypes");

            for (DocumentTemplateType documentTypeType : types) {
                System.out.println(String.format("<%s><%s><%s>.", documentTypeType.getId(), Predicates.CREATOR,
                        documentTypeType.getAuthorId()));
            }

            if (!fake) {
                out.close();
            }

            System.out.println("TOTAL: Finished in "
                    + ((System.nanoTime() - fetchStart) / 1000000000.0)
                    + " s. for " + types.size() + " docs.");

            System.out.println("TOTAL: Averall extracting speed  = " + types.size()
                    / ((System.nanoTime() - fetchStart) / 1000000000.0)
                    + " docs/s");

        } catch (Exception ex) {
            ex.printStackTrace();
        }

    }

    /**
     * Выгружает все документы в виде триплетов
     */
    private static void fetchAllDocuments() {

        try {

            int docCount = 0;
            long fetchStart = System.nanoTime();

            BufferedWriter out = null;
            if (!fake) {
                out = new BufferedWriter(new FileWriter(pathToDump));
            }

            // берем все типы
            List<DocumentTemplateType> types = DocumentUtil.getInstance().listDocumentTypes(DOCUMENT_URL, ticketId);

            Map<String, DocumentTemplateType> typesMap = new HashMap<String, DocumentTemplateType>();
            for (DocumentTemplateType type : types) {
                typesMap.put(type.getId(), type);
            }

            System.out.println("Got " + types.size() + " docTypes");

            // берем все документы
            List<String> typelist = DocumentUtil.getInstance().listDocuments(DOCUMENT_URL, ticketId);

            int i = 0;

            for (String documentType : typelist) {
                String[] arr = documentType.split(":");

                if (arr.length == 3) {
                    writeTriplet(arr[0], Predicates.CREATOR, arr[1], true, out);
                    writeTriplet(arr[0], Predicates.DOCUMENT_TEMPLATE_ID, arr[2], true, out);
                    DocumentTemplateType t = typesMap.get(arr[2]);
                    if (t != null) {
                        writeTriplet(arr[0], Predicates.DOCUMENT_TYPE_NAME, t.getName(), true, out);

                    }
                    docCount++;
                }
                if (i++ % 1000 == 0 && i == typelist.size()) {
                    System.out.println(String.format("Обработано %s документов из %s.", i, typelist.size()));
                }

            }

            if (!fake) {
                out.close();
            }

            System.out.println("TOTAL: Finished in "
                    + ((System.nanoTime() - fetchStart) / 1000000000.0)
                    + " s. for " + docCount + " docs.");

            System.out.println("TOTAL: Averall extracting speed  = " + docCount
                    / ((System.nanoTime() - fetchStart) / 1000000000.0)
                    + " docs/s");

        } catch (MalformedURLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (BigArchiveServerException_Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

    }

    private static void fetchDirectives() {

        Map<String, String> map = new HashMap<String, String>();
        map.put("search-type", "attributive");
        map.put("search-objects", "documents");
        map.put("attributiveSearch.typeId", documentTypeId);
        ArrayList<String> docIds;

        try {
            docIds = SearchUtil.getInstance().getAllDocumentsOfType(
                    SEARCH_QNAME, SEARCH_URL, ticketId, map);

            long start = System.currentTimeMillis();

            BufferedWriter out = null;
            if (!fake) {
                out = new BufferedWriter(new FileWriter(pathToDump));
            }

            long blankNumber = 0;
            // String blankPrefix = "_:Directive";

            for (String id : docIds) {

                try {
                    DocumentType type = DocumentUtil.getInstance().getDocumentById(DOCUMENT_URL, id, ticketId);

                    String blankNode = id;
                    // blankPrefix + blankNumber;
                    writeTriplet(blankNode, "magnet-ontology#subject",
                            "DOCUMENT", true, out);

                    Document doc = new Document(type);
                    writeTriplet(blankNode,
                            "http://purl.org/dc/elements/1.1/creator", doc.getAuthor().getId(), true, out);

                    for (TypeAttribute attr : doc.getValues()) {

                        if (blankNumber == 0) {
                            System.out.println(attr.getName());
                        }

                        String object = attr.getDefaultValue();

                        if (attr.getName().equals("Подписывающий")) {
                            writeTriplet(blankNode, "magnet-ontology#signer",
                                    object, true, out);
                        } else if (attr.getName().equals("Содержание")) {
                            writeTriplet(blankNode, "magnet-ontology#content",
                                    object, true, out);
                        } else if (attr.getName().equals("Ключевые слова")) {
                            writeTriplet(blankNode, "magnet-ontology#keywords",
                                    object, true, out);
                        } else if (attr.getName().equals("Инициатор")) {
                            writeTriplet(blankNode,
                                    "magnet-ontology#initiator", object, true,
                                    out);
                        } else if (attr.getName().equals("Заголовок")) {
                            writeTriplet(blankNode,
                                    "http://purl.org/dc/elements/1.1/title",
                                    object, true, out);
                        } else if (attr.getName().equals("Вложения")) {
                            writeTriplet(blankNode,
                                    "magnet-ontology#fileAttachment", object,
                                    true, out);
                        } else if (attr.getName().equals(
                                "Регистрационный номер")) {
                            writeTriplet(blankNode,
                                    "magnet-ontology#registrationNumber",
                                    object, true, out);
                        } else if (attr.getName().equals("Статус")) {
                            writeTriplet(blankNode, "magnet-ontology#status",
                                    object, true, out);
                        } else if (attr.getName().equals("Статус-история")) {
                            writeTriplet(blankNode,
                                    "magnet-ontology#statusHistory", object,
                                    true, out);
                        } else if (attr.getName().equals("Связанные документы")) {
                            writeTriplet(blankNode,
                                    "magnet-ontology#relatedDocuments", object,
                                    true, out);
                        } else if (attr.getName().equals("Дата регистрации")) {
                            writeTriplet(blankNode,
                                    "magnet-ontology#registrationDate", object,
                                    true, out);
                        } else if (attr.getName().equals("Приказ/распоряжение")) {
                            writeTriplet(blankNode,
                                    "magnet-ontology#directiveNumber", object,
                                    true, out);
                        } else if (attr.getName().equals("Вид документа")) {
                            writeTriplet(blankNode,
                                    "magnet-ontology#documentType", object,
                                    true, out);
                        } else if (attr.getName().equals("$private")) {
                            writeTriplet(blankNode,
                                    "magnet-ontology#isPrivate", object, true,
                                    out);
                        } else if (attr.getName().equals("archived")) {
                            writeTriplet(blankNode,
                                    "magnet-ontology#isArchived", object, true,
                                    out);
                        } else {
                            writeTriplet(blankNode, attr.getName(), object,
                                    false, out);
                        }
                    }

                    blankNumber++;
                } catch (Exception ex) {
                    System.out.println("Error !");
                    ex.printStackTrace();
                }
            }
            if (!fake) {
                out.close();
            }

            System.out.println("Finished in "
                    + ((System.currentTimeMillis() - start) / 1000)
                    + " s. for " + docIds.size() + " docs.");
            System.out.println("Querying speed  = " + docIds.size()
                    / ((System.currentTimeMillis() - start) / 1000)
                    + " docs/s");
        } catch (Exception e) {

            System.out.println("Error !");

            e.printStackTrace();

            printUsage();

        }
    }

    /**
     * Выгружает данные орг. структуры в виде триплетов
     */
    private static void fetchOrganization() {

        try {

            long start = System.currentTimeMillis();

            prepareRoles();
            populateAdmins();

            BufferedWriter out = null;
            if (!fake) {
                out = new BufferedWriter(new FileWriter(pathToDump));
            }

            OrganizationUtil organizationUtil = new OrganizationUtil(properties.getProperty("organizationUrl"), properties.getProperty("organizationNameSpace"), properties.getProperty("organizationName"));

            List<Department> deps = organizationUtil.getDepartments();

            // находим родителей для всех подразделений
            int buCounter = 0;
            Map<String, String> newToInternalIdMap = new HashMap<String, String>();
            HashMap<String, ArrayList<String>> childs = new HashMap<String, ArrayList<String>>();
            HashMap<String, String> childToParent = new HashMap<String, String>();
            for (Department department : deps) {
                List<Department> childDeps = organizationUtil.getDepartmentsByParentId(department.getInternalId(),
                        "Ru");

                ArrayList<String> breed = new ArrayList<String>();
                for (Department child : childDeps) {
                    breed.add(child.getInternalId());
                    childToParent.put(child.getId(), department.getId());
                }
                childs.put(department.getId(), breed);

                newToInternalIdMap.put(department.getInternalId(), department.getId());
                buCounter++;
            }

            // выгружаем BusinessUnit'ы
            buCounter = 0;
            // String blankNodePrefix = "magnet-ontology#BusinessUnit";
            for (Department department : deps) {
                // String subject = blankNodePrefix + buCounter++;
                writeTriplet(department.getId(),
                        Predicates.CREATOR,
                        department.getName(), true, out);
                // writeTriplet(subject,
                // "magnet-ontology#entityId", department
                // .getId(), true, out);
                for (String child : childs.get(department.getId())) {
                    writeTriplet(department.getId(), Predicates.HAS_PART,
                            newToInternalIdMap.get(child), true, out);
                }
                writeTriplet(department.getId(), Predicates.MEMBER_OF,
                        childToParent.get(department.getId()), true, out);
            }

            long end = System.currentTimeMillis();
            System.out.println("Finished in " + ((end - start) / 1000)
                    + " s. for " + deps.size() + " departments.");
            System.out.println("Querying speed  = " + deps.size()
                    / ((end - start) / 1000) + " deps/s");

            // Выгружаем пользователей

            start = System.currentTimeMillis();

            // String blankNodePrefix = "magnet-ontology#Employee";

            List<EntityType> list = organizationUtil.getUsers();
            for (EntityType userEntity : list) {

                // String prefix = blankNodePrefix + personCount++;

                String prefix = userEntity.getUid();

                for (AttributeType a : userEntity.getAttributes().getAttributeList()) {
                    if (a.getName().equalsIgnoreCase("firstNameRu")) {
                        writeTriplet(prefix,
                                "http://swrc.ontoware.org/ontology#firstName",
                                a.getValue(), true, "Ru", out);
                    } else if (a.getName().equalsIgnoreCase("firstNameEn")) {
                        writeTriplet(prefix,
                                "http://swrc.ontoware.org/ontology#firstName",
                                a.getValue(), true, "En", out);
                    } else if (a.getName().equalsIgnoreCase("secondnameRu")) {
                        writeTriplet(prefix, "magnet-ontology#secondName", a.getValue(), true, "Ru", out);
                    } else if (a.getName().equalsIgnoreCase("secondnameEn")) {
                        writeTriplet(prefix, "magnet-ontology#secondName", a.getValue(), true, "En", out);
                    } else if (a.getName().equalsIgnoreCase("surnameRu")) {
                        writeTriplet(prefix,
                                "http://swrc.ontoware.org/ontology#lastName", a.getValue(), true, "Ru", out);
                    } else if (a.getName().equalsIgnoreCase("surnameEn")) {
                        writeTriplet(prefix,
                                "http://swrc.ontoware.org/ontology#lastName", a.getValue(), true, "En", out);
                    } else if (a.getName().equals("domainName")) {

                        writeTriplet(prefix, Predicates.LOGIN_NAME, a.getValue(), true, out);

                        if (admins.contains(a.getValue())) {
                            writeTriplet(prefix, "magnet-ontology#isAdmin",
                                    "true", true, out);
                        }

                    } else if (a.getName().equals("email")) {
                        writeTriplet(prefix,
                                "http://swrc.ontoware.org/ontology#email", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("postRu")) {
                        // String thing = postTitleToThing.get(a.getValue());
                        // if (thing == null) {
                        // thing = "magnet-ontology#Post"
                        // + postCount;
                        // writeTriplet(thing,
                        // "http://purl.org/dc/elements/1.1/title", a
                        // .getValue(), true, out);
                        // postTitleToThing.put(a.getValue(), thing);
                        // postCount++;
                        // }
                        writeTriplet(prefix, "magnet-ontology#onPosition", a.getValue(), true, "Ru", out);
                    } else if (a.getName().equalsIgnoreCase("postEn")) {
                        writeTriplet(prefix, "magnet-ontology#onPosition", a.getValue(), true, "En", out);
                    } else if (a.getName().equalsIgnoreCase("id")) {
                        writeTriplet(prefix, "magnet-ontology#id",
                                a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("pid")) {
                        writeTriplet(prefix, "magnet-ontology#pid", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("pager")) {
                        writeTriplet(prefix, "magnet-ontology#pager", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("phone")) {
                        writeTriplet(prefix,
                                "http://swrc.ontoware.org/ontology#phone", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("phone")) {
                        writeTriplet(prefix,
                                "http://swrc.ontoware.org/ontology#phone", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("offlineDateBegin")) {
                        writeTriplet(prefix,
                                "magnet-ontology#offlineDateBegin", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("offlineDateEnd")) {
                        writeTriplet(prefix, "magnet-ontology#offlineDateEnd",
                                a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("departmentId")) {
                        String department = newToInternalIdMap.get(a.getValue());
                        writeTriplet(prefix, Predicates.MEMBER_OF,
                                department, true, out);
                    } else if (a.getName().equalsIgnoreCase("mobilePrivate")) {
                        writeTriplet(prefix,
                                "http://swrc.ontoware.org/ontology#phone", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("phoneExt")) {
                        writeTriplet(prefix,
                                "http://swrc.ontoware.org/ontology#phone", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("mobile")) {
                        writeTriplet(prefix,
                                "http://swrc.ontoware.org/ontology#phone", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("active")) {
                        writeTriplet(prefix, "magnet-ontology#isActive", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase(
                            "employeeCategoryR3")) {
                        writeTriplet(prefix,
                                "magnet-ontology#employeeCategoryR3", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("r3_ad")) {
                        writeTriplet(prefix, "magnet-ontology#r3_ad", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("photo")) {
                        writeTriplet(prefix,
                                "http://swrc.ontoware.org/ontology#photo", a.getValue(), true, out);
                    } else if (a.getName().equalsIgnoreCase("photoUID")) {
                        writeTriplet(prefix, "magnet-ontology#photoUID", a.getValue(), true, out);
                    } else if (!writeRole(prefix, a, out)) {
                        writeTriplet(prefix, "magnet-ontology#unknown"
                                + a.getName(), a.getValue(), true, out);
                    }
                }
            }

            end = System.currentTimeMillis();
            System.out.println("Finished in " + ((end - start) / 1000)
                    + " s. for " + list.size() + " persons.");
            /*			System.out.println("Querying speed  = " + list.size()
            / ((end - start + 1) / 1000) + " persons/s");*/

            System.out.println("-----------------------------------------");

            if (!fake) {
                out.close();
            }

        } catch (Exception e) {

            System.out.println("Error !");

            e.printStackTrace();

            printUsage();

        }
    }

    private static void loadProperties() {

        try {
            properties.load(new FileInputStream("em2onto.properties"));

            documentTypeId = properties.getProperty("documentTypeId", "");
            ticketId = properties.getProperty("sessionTicketId", "");
            SEARCH_URL = properties.getProperty("searchUrl", "");
            DOCUMENT_URL = properties.getProperty("documentsUrl", "");
            fake = new Boolean(properties.getProperty("fake", "false"));
            pathToDump = properties.getProperty("pathToDump");
            dbUser = properties.getProperty("dbUser", "ba");
            dbPassword = properties.getProperty("dbPassword", "123456");
            dbUrl = properties.getProperty("dbUrl", "localhost:3306");
        } catch (IOException e) {
            writeDefaultProperties();
        }

    }

    private static void writeDefaultProperties() {

        System.out.println("Writing default properties.");

        properties.setProperty("documentTypeId", "fake-type-2mn3-6n3m");
        properties.setProperty("sessionTicketId", "fake-tiket-4abe-8c5f-a30d6c251165");
        properties.setProperty("searchUrl", "http://localhost:9874/ba-server/SearchServices?wsdl");
        properties.setProperty("documentsUrl", "http://localhost:9874/ba-server/DocumentServices?wsdl");
        properties.setProperty("fake", "false");
        properties.setProperty("pathToDump", "/tmp/docments.n3");
        properties.setProperty("organizationName", "OrganizationEntityService");
        properties.setProperty("organizationNameSpace", "http://organization.magnet.magnetosoft.ru/");
        properties.setProperty("organizationUrl", "http://localhost:9874/organization/OrganizationEntitySvc?wsdl");
        properties.setProperty("dictionaryUrl", "http://localhost:9874/ba-server/DictionaryServices?wsdl");
        properties.setProperty("dbUser", "ba");
        properties.setProperty("dbPassword", "123456");

        try {
            properties.store(new FileOutputStream("em2onto.properties"), null);
        } catch (IOException e) {
        }
    }

    private static void printUsage() {
        System.out.println("Usage  : java -cp em2onto.jar ru.magnetosoft.em2onto.Fetcher [ fetchType(directive|organization) [ docType [ pathToDump [ ticketId [ searchServicesWsdl [ searchQname [ docUrl [ fake(if exists => true) ] ] ] ] ] ]");
        System.out.println("Example: java -cp em2onto.jar ru.magnetosoft.em2onto.Fetcher "
                + documentTypeId
                + " "
                + pathToDump
                + " "
                + ticketId
                + " " + SEARCH_URL + " " + DOCUMENT_URL);
    }

    /**
     * Записывает триплет с заданным субъектом, предивактом и объектом в заданный BufferedWriter, с учетом локали
     */
    private static void writeTriplet(String subject, String predicate,
            String object, boolean isObjectLiteral, String locale,
            BufferedWriter bw) throws IOException {

        if (locale != null && locale.length() > 0) {
            writeTriplet(subject, predicate, object + "@"
                    + locale.toLowerCase(), isObjectLiteral, bw);
        } else {
            writeTriplet(subject, predicate, object, isObjectLiteral, bw);
        }
    }

    /**
     * Записывает триплет с заданным субъектом, предивактом и объектом в заданный BufferedWriter без учета локали
     */
    private static void writeTriplet(String subject, String predicate,
            String object, boolean isObjectLiteral, BufferedWriter bw)
            throws IOException {

        StringBuilder builder = new StringBuilder("<");

        builder.append(subject);
        builder.append("> <");
        builder.append(predicate);
        builder.append("> ");

        if (isObjectLiteral) {
            builder.append("\"");
        } else {
            builder.append("<");
        }

        builder.append(escape(object));

        if (isObjectLiteral) {
            builder.append("\"");
        } else {
            builder.append(">");
        }

        builder.append(" .\n");

        if (fake) {
            System.out.println(builder.toString());
        } else {
            bw.write(builder.toString());
        }
    }

    public static String escape(String string) {

        if (string != null) {
            StringBuilder sb = new StringBuilder();

            char c = ' ';

            for (int i = 0; i < string.length(); i++) {

                c = string.charAt(i);

                if (c == '\n') {
                    sb.append("\\n");
                } else if (c == '\r') {
                    sb.append("\\r");
                } else if (c == '\\') {
                    sb.append("\\\\");
                } else if (c == '"') {
                    sb.append("\\\"");
                } else if (c == '\t') {
                    sb.append("\\t");
                } else {
                    sb.append(c);
                }
            }
            return sb.toString();
        } else {
            return "";
        }
    }

    private static boolean writeRole(String subject, AttributeType a,
            BufferedWriter bw) {
        if (roles.contains(a.getName())) {
            try {
                writeTriplet(subject, "magnet-ontology#" + a.getName(), a.getValue(), true, bw);
                return true;
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    private static void prepareRoles() {
        roles.add("Mdispatcher");
        roles.add("scannerCP");
        roles.add("RVZ");
        roles.add("scannerCP");
        roles.add("head");
        roles.add("contractCoordinator");
        roles.add("contractExecutor");
        roles.add("mainEngineer");
        roles.add("chiefOfDrawingDepartment");
        roles.add("SPPexecutor");
        roles.add("archiverConstructionRequest");
        roles.add("archiverChangeConstructionRequest");
        roles.add("archiverSketch");
        roles.add("archiverConstructionProject");
        roles.add("IRSpecialist");
        roles.add("scanner");
    }

    /*
     * Метод считывает из файла пары соответсвий имен атрибутов объекта
     * свойствам owl-описания и возвращает Map<имя атрибута, свойство owl>.
     * Каждой паре соответсвует строка файла. Имя атрибута в файле отделяется от
     * свойства запятой.
     */
    private static Map<String, String> getPropertyMap(String fileName) {
        Map<String, String> result = new HashMap<String, String>();
        File file = new File(fileName);

        try {
            BufferedReader bufferedReader = new BufferedReader(new FileReader(
                    file));
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                String[] pair = line.split(",");
                if (pair.length > 1) {
                    result.put(pair[0], pair[1]);
                }
            }
        } catch (IOException e) {
            System.out.println("Exception raised while reading attribute-property map from "
                    + fileName);
        }

        return result;
    }

    /*
     * Метод производит поиск документов и возвращает список идентификаторов
     * найденных документов
     */
    private static List<String> getDocumentsByType(String type) {

        ArrayList<String> result = new ArrayList<String>();

        Map<String, String> map = new HashMap<String, String>();
        map.put("search-type", "attributive");
        map.put("search-objects", "documents");
        map.put("attributiveSearch.typeId", type);

        try {
            long start = System.nanoTime();
            result = SearchUtil.getInstance().getAllDocumentsOfType(
                    SEARCH_QNAME, SEARCH_URL, ticketId, map);

            System.out.println("Got " + result.size()
                    + " documents with type id = " + type + " in "
                    + ((System.nanoTime() - start) / 1000000) + " ms.");

        } catch (Exception e) {
            System.out.println("Exception raised while document searching : "
                    + e.getMessage());
        }
        return result;
    }

    private static void populateAdmins() {
        admins.add("shafikovn");
        admins.add("Syk-PortalMS");
        admins.add("syk-portalms");
    }

    private static void fetchAuthorizationData() {
        System.out.println("Fetching authorization data...");
        Connection connection = null;
        try {
            Class.forName("com.mysql.jdbc.Driver").newInstance();
            connection = DriverManager.getConnection("jdbc:mysql://" + dbUrl, dbUser, dbPassword);
            String authDataQuery = "select authorSystem, authorSubsystem, authorSubsystemElement, "
                    + "targetSystem, targetSubsystem, targetSubsystemElement, category, elementId, dateFrom, dateTo, "
                    + "_create, _read, _update, _delete from authorization_db.authorizationrightrecords";
            ResultSet authData = connection.createStatement().executeQuery(authDataQuery);

            BufferedWriter out = null;
            if (!fake) {
                out = new BufferedWriter(new FileWriter(pathToDump));
            }
            String ns = "mo/at/acl#";

            int i = 0;
            while (authData.next()) {
                String authorSystem = authData.getString(1);
                String authorSubsystem = authData.getString(2);
                String authorSubsystemElement = authData.getString(3);
                String targetSystem = authData.getString(4);
                String targetSubsystem = authData.getString(5);
                String targetSubsystemElement = authData.getString(6);
                String category = authData.getString(7);
                String elementId = authData.getString(8);
                String dateFrom = authData.getString(9);
                String dateTo = authData.getString(10);
                String _create = authData.getString(11);
                String _read = authData.getString(12);
                String _update = authData.getString(13);
                String _delete = authData.getString(14);

                String recordId = ns + "RR" + i;

                if (!isEmpty(authorSystem)) {
                    writeTriplet(recordId, Predicates.AUTHOR_SYSTEM, authorSystem, true, out);
                }
                if (!isEmpty(authorSubsystem)) {
                    writeTriplet(recordId, Predicates.AUTHOR_SUBSYSTEM, authorSubsystem, true, out);
                }
                if (!isEmpty(authorSubsystemElement)) {
                    writeTriplet(recordId, Predicates.AUTHOR_SUBSYSTEM_ELEMENT, authorSubsystemElement, true, out);
                }
                if (!isEmpty(targetSystem)) {
                    writeTriplet(recordId, Predicates.TARGET_SYSTEM, targetSystem, true, out);
                }
                if (!isEmpty(targetSubsystem)) {
                    writeTriplet(recordId, Predicates.TARGET_SUBSYSTEM, targetSubsystem, true, out);
                }
                if (!isEmpty(targetSubsystemElement)) {
                    writeTriplet(recordId, Predicates.TARGET_SUBSYSTEM_ELEMENT, targetSubsystemElement, true, out);
                }
                if (!isEmpty(category)) {
                    writeTriplet(recordId, Predicates.CATEGORY, category, true, out);
                }
                if (!isEmpty(elementId)) {
                    writeTriplet(recordId, Predicates.ELEMENT_ID, elementId, true, out);
                }
                if (!isEmpty(dateFrom)) {
                    writeTriplet(recordId, Predicates.DATE_FROM, dateFrom, true, out);
                }
                if (!isEmpty(dateTo)) {
                    writeTriplet(recordId, Predicates.DATE_TO, dateTo, true, out);
                }

                String rights = "";
                if (!isEmpty(_create)) {
                    rights += 'c';
                }
                if (!isEmpty(_read)) {
                    rights += 'r';
                }
                if (!isEmpty(_update)) {
                    rights += 'u';
                }
                if (!isEmpty(_delete)) {
                    rights += 'd';
                }
                writeTriplet(recordId, Predicates.RIGHTS, rights, true, out);
            }
            if (!fake) {
                out.close();
            }
        } catch (Exception ex) {
            System.out.println("Error fetching authorization data.");
            ex.printStackTrace();
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        System.out.println("Fetching authorization data...done");
    }

    private static boolean isEmpty(String str) {
        if (str == null && str.trim().length() == 0) {
            return true;
        } else {
            return false;
        }
    }
}
