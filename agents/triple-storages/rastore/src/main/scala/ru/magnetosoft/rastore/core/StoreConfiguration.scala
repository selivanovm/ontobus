/*
 * StoreConfiguration.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package ru.magnetosoft.rastore.core

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.Properties;

object StoreConfiguration {

    private val PROPERTIES_FILE_PATH:String  = "rastore.properties"
    private var properties:Properties = null
    var isCustomProperties:Boolean = false

    def getProperties(): Properties = {
        if (properties == null) loadProperties
        return properties
    }

    protected def getDefaults():Properties = {
        var result = new Properties();
        result.setProperty("database_url", "jdbc:h2:file:db/rdfstore");
        result.setProperty("database_driver_class", "org.h2.Driver");
        result.setProperty("database_user", "user");
        result.setProperty("database_password", "password");
        result.setProperty("database_recreate", "true");
        result.setProperty("database_schema", "simple_schema.sql");
        result.setProperty("connection_pool_size", "10");
        result.setProperty("rdfs_manager_class", "SimpleRDFSManager");

        result.setProperty("amqp_username", "rastore");
        result.setProperty("amqp_password", "rspass");
        result.setProperty("amqp_vhost", "rs");
        result.setProperty("amqp_heartbeat", "0")
        result.setProperty("amqp_host", "localhost")
        result.setProperty("amqp_port", "5672")
        result.setProperty("amqp_queue", "rsinbox")
        result.setProperty("amqp_exchange", "rsexchange")
        result.setProperty("amqp_exchange_type", "direct")
        result.setProperty("amqp_routing_key", "rskey")

        result.setProperty("server_mode", "file")
        result.setProperty("thread_for_message_parser", "false")

        result.setProperty("log_level", "debug")
        result.setProperty("log_mode", "sysout")
        result.setProperty("log_file_path", "./server.log")

        return result;
    }

    private def loadProperties() {
        properties = new Properties()

        var fis:FileInputStream = null

        try {
            fis = new FileInputStream(PROPERTIES_FILE_PATH);
            properties.load(fis)
        } catch {
            case ex: Exception => {
                ex.printStackTrace()
            }
        } finally {
            try {
                fis.close();
            } catch {
                case ex: Exception => { ex.printStackTrace() }
            }
        }

        isCustomProperties = !(properties.size() == 0 || properties.equals(getDefaults()))

        if (!isCustomProperties) {
            properties = getDefaults()
            save
            LogManager.info("Turn to default properties.")
        }
            
    }
    
    protected def save() {

        var fos:FileOutputStream = null
        try {
            fos = new FileOutputStream(PROPERTIES_FILE_PATH)
            properties.store(fos, "RDFStore properties")
        } catch {
            case ex:Exception => { ex.printStackTrace() }
        } finally {
            try {
                fos.close();
            } catch {
                case ex:Exception => { ex.printStackTrace() }
            }
        }

    }

}
