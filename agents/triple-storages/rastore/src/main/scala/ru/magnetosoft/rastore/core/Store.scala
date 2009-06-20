package ru.magnetosoft.rastore.core

import ru.magnetosoft.rastore.interfaces.IRDFSManager
import java.sql.SQLException
import java.io.IOException
import java.io.BufferedReader
import java.sql.Statement
import java.io.InputStream;
import java.io.InputStreamReader;

object Store {

  val logger = new Logger(Store)
  val c = ConnectionManager.getConnection()
  private var rdfsManager: IRDFSManager = null

  def getManager(): IRDFSManager = {
    if (rdfsManager == null) {
      try {
        if (StoreConfiguration.getProperties.getProperty("database_recreate") == "true") {
          recreateDb()
        }

        rdfsManager = RDFSManagerFactory.getManager(StoreConfiguration.getProperties.getProperty("rdfs_manager_class"));
        rdfsManager.setConnection(c);

      } catch {
        case ex: SQLException => { ex.printStackTrace; System.exit(1); }
        case ex: ClassNotFoundException => { ex.printStackTrace; System.exit(2); }
      }
    }
    return rdfsManager
  }

  private def recreateDb() {

    var br: BufferedReader = null

    try {
      val st: Statement = c.createStatement()
      val schema: String  = StoreConfiguration.getProperties.getProperty("database_schema")

      logger.info("Try to get DB Schema from " + schema)
      val is: InputStream = getClass().getResourceAsStream("/" + schema)
      val br: BufferedReader = new BufferedReader(new InputStreamReader(is))

      var line: String = br.readLine()
      while (line != null) {
        logger.info("Schema Update : " + line)
        st.executeUpdate(line)
        line = br.readLine()
      }

    } catch {
      case ex: IOException => { ex.printStackTrace }
      case ex: SQLException => { ex.printStackTrace }
    } finally {
      try {
        if (br != null) {
          br.close()
        }
      } catch {
        case ex: IOException => { ex.printStackTrace }
      }
    }
  }
}
