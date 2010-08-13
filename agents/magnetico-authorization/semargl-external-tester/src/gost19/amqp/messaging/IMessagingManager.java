package gost19.amqp.messaging;

import java.util.List;

public interface IMessagingManager {

    public static String DICTIONARY_QUEUE = "ba-dictionary";
    public static String AUTHENTICATION_QUEUE = "ba-authentication";
    public static String AUTHORIZATION_QUEUE = "semargl";

    /**
     * Инициализация компонента, создание соединения с системой обмена сообщениями.
     * @throws Exception 
     */
    public void init(String host, Integer port, String virtualHost, String userName, String password, long responceWaitingLimit) throws Exception;
    
    /**
     * Отправляет сообщение адресату.
     */
    public void sendMessage(String to, String message);
    
    /**
     * Отправляет сообщение адресату, ждет ответ в течение заданного времени если выставлен флаг, иначе ждет 
     * бесконечно. Если ответ не получен возвращает null.
     * @param to адресат
     * @param message текст сообщения
     * @param withWaitingLimit время ожидания конечно ?
     * @return ответ
     */
    public List<String> sendRequest(String uid, String to, String message, boolean withWaitingLimit);
    
    /**
     * Слушает очередь на предмет поступления новых сообщений.
     * @param queueToListen очередь сообщения из которой нужно принять сообщения.
     * @param waitingTime время в течение которого нужно ждать.
     * @return строка с сообщением. если оно не получено - возвращает null.
     */
    public String getMessage(String queueToListen, int waitingTime);
    
}
