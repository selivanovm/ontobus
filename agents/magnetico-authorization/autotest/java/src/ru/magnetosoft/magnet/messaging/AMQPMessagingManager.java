package ru.magnetosoft.magnet.messaging;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;
import com.rabbitmq.client.ConnectionParameters;
import com.rabbitmq.client.QueueingConsumer;
import com.rabbitmq.client.AMQP.BasicProperties;
import com.rabbitmq.client.QueueingConsumer.Delivery;
import com.rabbitmq.client.GetResponse;

public class AMQPMessagingManager implements IMessagingManager {
    //AMQP
    private Connection connection;
    
    private String host;
    private int port;
    private String virtualHost;
    private String login;
    private String password;
    private long responceWaitingLimit = 0;
    private    Channel channel;

    private TripleUtils tripleUtils = new TripleUtils();
    
    public AMQPMessagingManager() {
    }
    
    synchronized public void init(String host, Integer port, String virtualHost, String userName, String password, 
				  long responceWaitingLimit) throws Exception {
	this.host = host;
	this.port = port;
	this.virtualHost = virtualHost;
	this.login = userName;
	this.password = password;
	this.responceWaitingLimit = responceWaitingLimit;


        getConnection();

	    channel = getConnection().createChannel();
	    channel.queueDeclare("semargl-a", true);

    }
    
    /**
     * {@inheritDoc}
     * 
     * @throws IOException
     */
    synchronized public void sendMessage(String to, String message) {
	try {
	    //	    long start = System.nanoTime();
	    
//	    channel.queueDeclare(to);

//            String uid = java.util.UUID.randomUUID().toString();
	    //	    System.out.println(String.format("[%s] Отправка в очередь '%s' сообщения \n %s", uid, to, message));
	    
	    BasicProperties props = new BasicProperties();
	    channel.basicPublish("", to, props, message.getBytes());
//	    channel.close();
	    
	    /*	    if (log.isTraceEnabled()) {
		long finish = System.nanoTime();
		double duration = (finish - start) / 1000000;
		String traceMessage = String.format("[%s] Отправлено за %5.2f msec.", uid, duration);
		log.trace(traceMessage);
		}*/
	    
	} catch (IOException e) {
	    e.printStackTrace();
	} catch (Exception e) {
	    e.printStackTrace();
	}
    }
    
    /**
     * {@inheritDoc}
     */
    synchronized public List<String> sendRequest(String uid, String to, String message,
			      boolean withWaitingLimit) throws RuntimeException {
	long start = System.nanoTime();
	
	System.out.println(String.format("%s SEND_REQUEST [%s] : START : Подготовлен пакет для получателя '%s'. Содержимое \n[\n%s\n]\n",((System.nanoTime() - start) / 1000), uid, to, message));

	List<String> result = new ArrayList();
	String tempQueue = String.format("client-%s", uid);
	Channel channel = null;

	try {
	    channel = getConnection().createChannel();
	    
	    channel.queueDeclare(tempQueue, true);
	    
	    Map<String, Object> headers = new HashMap<String, Object>();
	    headers.put("sender", tempQueue);
	    String setFromUid = java.util.UUID.randomUUID().toString();
	    message = String.format("%s<%s><%s><%s>.<%s><%s>\"%s\".<%s><%s>\"%s\".", message, setFromUid, Predicates.SUBJECT, Predicates.SET_FROM, 
				    setFromUid, Predicates.FUNCTION_ARGUMENT, tempQueue, uid, Predicates.REPLY_TO, tempQueue);
	    
	    System.out.println(String.format("%s SEND_REQUEST [%s] : Создана временная очередь для приема ответа '%s'",((System.nanoTime() - start) / 1000), uid, tempQueue));
	    
	    // отправляем пакет
	    BasicProperties props = new BasicProperties();
	    props.headers = headers;
	    
	    channel.basicPublish("", to, props, message.getBytes());
	    
	    System.out.println(String.format("%s SEND_REQUEST [%s] : Пакет отправлен. Время ожидания ответа %s",((System.nanoTime() - start) / 1000), uid, String.valueOf(responceWaitingLimit)));
	    
	    Delivery delivery = null;
	    QueueingConsumer consumer = new QueueingConsumer(channel);
	    channel.basicConsume(tempQueue, consumer);

	    /*	    long deliveryTag = 0;
	    long startWaiting = System.nanoTime();
	    while ((System.nanoTime() - startWaiting)/1000000 < responceWaitingLimit) {
		GetResponse response = channel.basicGet(tempQueue, false);
		if (response != null) {
		    result = new String(response.getBody());
		    deliveryTag = response.getEnvelope().getDeliveryTag();
		    break;
		}
		try {
		    Thread.sleep(1);		    
		} catch (Exception e) {
		    e.printStackTrace();
		}
		}*/
	    /*	    if (log.isTraceEnabled()) {
		double duration = (System.nanoTime() - startWaiting) / 1000000;
		System.out.println(String.format("AMQP_MANAGER [%s] : Прием ответа выполнен за %5.2f msec.",System.nanoTime() - start, uid, duration));
		}*/

	    /*	    long startWaiting = System.nanoTime();
	    while ((System.nanoTime() - startWaiting)/1000000 < responceWaitingLimit) {
		delivery = consumer.nextDelivery(5);
		if (delivery != null) {
		    result = new String(delivery.getBody());
		    break;
		}
		try {
		    Thread.sleep(1);		    
		} catch (Exception e) {
		    e.printStackTrace();
		}
	    }*/

	    long startWaiting = System.nanoTime();
	    boolean isStatusOk = false;
	    while (!isStatusOk) {
		if ((System.nanoTime() - startWaiting)/1000000 >= responceWaitingLimit) {
		    break;
		}

		try {
		    delivery = consumer.nextDelivery(responceWaitingLimit);
		} catch (InterruptedException e) {
		    e.printStackTrace();
		}

		if (delivery != null) {
		    String r = new String(delivery.getBody());
		    System.out.println(String.format("%s SEND_REQUEST [%s] : Получено сообщение : %s",((System.nanoTime() - start) / 1000), uid, r));
		    String status = tripleUtils.getStatusFromReply(r);
		    if (status != null && status.equals(Predicates.STATE_OK)) {
			isStatusOk = true;
		    }
		    result.addAll(tripleUtils.getDataFromReply(r));
		    try {
			channel.basicAck(delivery.getEnvelope().getDeliveryTag(), false);
		    } catch (IOException e) {
			System.out.println(String.format("%s SEND_REQUEST [%s] : Ошибка уведомления о получении.",((System.nanoTime() - start) / 1000), uid));
			e.printStackTrace();
		    }
		}
	    }

	    if (result.size() > 0) {
		System.out.println(String.format("%s SEND_REQUEST [%s] : Получен результат : %s",((System.nanoTime() - start) / 1000), uid, result.toString()));
	    } else {
		if (isStatusOk)
		    System.out.println(String.format("%s SEND_REQUEST [%s] : Получен пустой результат.",((System.nanoTime() - start) / 1000), uid));
		else
		    System.out.println(String.format("%s SEND_REQUEST [%s] : Результат не получен в течение заданного времени ожидания.",((System.nanoTime() - start) / 1000), uid));
	    }
	    
	} catch (IOException e) {
	    System.out.println(String.format("%s SEND_REQUEST [%s] : Ошибка отправки запроса.",((System.nanoTime() - start) / 1000), uid));
	    e.printStackTrace();
	} finally {
	    try {
		channel.queueDelete(tempQueue);
	    } catch (Exception e) {
	    }
	    try {
		channel.close();
	    } catch (Exception e) {
	    }
	}

	long finish = System.nanoTime();
	double duration = (finish - start) / 1000000;
	String traceMessage = String.format("%s SEND_REQUEST [%s] : FINISH : Запрос выполнен за %5.2f msec.",((System.nanoTime() - start) / 1000), uid, duration);
	System.out.println(traceMessage);
	return result;
    }
    
    /**
     * {@inheritDoc}
     */
    synchronized public String getMessage(String queueToListen, int waitingTime) {
	
	long start = System.nanoTime();
	
	String result = null;
	
	//		log
	//				.debug(String
	//						.format(
	//								"Проверка очереди [%s] на предмет нового сообщения. Время ожидания = %d мсек.",
	//								queueToListen, waitingTime));
	
	String uid = java.util.UUID.randomUUID().toString();
	Channel channel;
	try {
	    channel = getConnection().createChannel();
	} catch (Exception e) {
	    throw new RuntimeException(String.format("GET_MESSAGE [%s] Ошибка создания канала AMQP.", uid), e);
	}
	
	try {
	    channel.queueDeclare(queueToListen);
	} catch (IOException e) {
	    throw new RuntimeException(String.format("GET_MESSAGE [%s] Ошибка создания очереди для приема сообщения.", uid), e);
	}
	
	QueueingConsumer consumer = new QueueingConsumer(channel);
	try {
	    channel.basicConsume(queueToListen, consumer);
	    Delivery delivery;
	    if (waitingTime > 0) {
		delivery = consumer.nextDelivery(waitingTime);
	    } else {
		delivery = consumer.nextDelivery();
	    }
	    if (delivery != null) {
		channel.basicAck(delivery.getEnvelope().getDeliveryTag(), false);
		result = new String(delivery.getBody());
	    }
	} catch (Exception e) {
	    throw new RuntimeException(String.format("GET_MESSAGE [%s] Ошибка приема AMQP пакета.", uid), e);
	}
	
//	if (result != null) {
//	    System.out.println(String.format("GET_MESSAGE [%s] Получено сообщение : %s", uid, result));
//	} else {
//	    log.debug("Нет новых сообщений.");
//	}
	
	try {
	    channel.close();
	} catch (IOException e) {
	    System.out.println(String.format("GET_MESSAGE [%s] Ошибка закрытия AMQP канала.", uid));
	    e.printStackTrace();
	}
	
	/*	if (result != null) {
	    long finish = System.nanoTime();
	    double duration = (finish - start) / 1000000;
	    String traceMessage = String.format("GET_MESSAGE [%s] Метод отработал %5.2f msec.", uid, duration);
	    System.out.println(traceMessage);
	    }*/
	return result;
    }
    
    /**
     * Возвращает соединение.
     * 
     * @return
     */
    private Connection getConnection() throws RuntimeException {
	if (connection == null || !connection.isOpen()) {
	    
	    System.out.println(String.format(
				   "Попытка соединения с сервером AMQP : host = %s, port = %s, "
				   + "virtualHost = %s, login = %s, password = %s",
				   host, port, virtualHost, login, password));
	    
	    ConnectionParameters params = new ConnectionParameters();
	    params.setUsername(login);
	    params.setPassword(password);
	    params.setVirtualHost(virtualHost);
	    params.setRequestedHeartbeat(0);
	    
	    ConnectionFactory factory = new ConnectionFactory(params);
	    try {
		connection = factory.newConnection(host, port);
	    } catch (IOException e) {
		System.out.println("Ошибка установки AMQP соединения.");
		throw new RuntimeException("Ошибка установки AMQP соединения.", e);
	    }
	    
	    System.out.println("Соединение создано успешно.");
	    
	}
	return connection;
    }

}
