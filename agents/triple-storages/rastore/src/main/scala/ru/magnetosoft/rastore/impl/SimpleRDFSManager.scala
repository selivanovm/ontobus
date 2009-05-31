/*
 * SimpleRDFSManager.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package ru.magnetosoft.rastore.impl

import scala.collection.mutable.Set

import ru.magnetosoft.rastore.interfaces.IRDFSManager
import ru.magnetosoft.rastore.core.Triplet
import ru.magnetosoft.rastore.core.ConnectionManager
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

class SimpleRDFSManager extends IRDFSManager {

  private var conn: Connection = null
  private var insert: PreparedStatement = null
  private var getByO: PreparedStatement = null
  private var getByP: PreparedStatement = null
  private var getByS: PreparedStatement = null
  private var getByI: PreparedStatement = null
  private var getBySO: PreparedStatement = null
  private var getBySP: PreparedStatement = null
  private var getByOP: PreparedStatement = null
  private var getBySOP: PreparedStatement = null

  private var removeByO: PreparedStatement = null
  private var removeByP: PreparedStatement = null
  private var removeByS: PreparedStatement = null
  private var removeByI: PreparedStatement = null
  private var removeBySO: PreparedStatement = null
  private var removeBySP: PreparedStatement = null
  private var removeByOP: PreparedStatement = null
  private var removeBySOP: PreparedStatement = null

  private var remove: PreparedStatement = null
  private var removeAll: PreparedStatement = null

  def setConnection(conn: Connection) {
    this.conn = conn
    try {
      insert = conn.prepareStatement("INSERT INTO TRIPLETS (SUBJ, OBJ, PRED) VALUES (?, ?, ?);")

      getByS = conn.prepareStatement("SELECT * FROM TRIPLETS WHERE SUBJ = ?")
      getByO = conn.prepareStatement("SELECT * FROM TRIPLETS WHERE OBJ = ?")
      getByP = conn.prepareStatement("SELECT * FROM TRIPLETS WHERE PRED = ?")
      getBySO = conn.prepareStatement("SELECT * FROM TRIPLETS WHERE SUBJ = ? AND OBJ = ?")
      getBySP = conn.prepareStatement("SELECT * FROM TRIPLETS WHERE SUBJ = ? AND PRED = ?")
      getByOP = conn.prepareStatement("SELECT * FROM TRIPLETS WHERE OBJ = ? AND PRED = ?")
      getBySOP = conn.prepareStatement("SELECT * FROM TRIPLETS WHERE SUBJ = ? AND OBJ = ? AND PRED = ?")
      getByI = conn.prepareStatement("SELECT * FROM TRIPLETS WHERE ID = ?")

      removeByS = conn.prepareStatement("DELETE FROM TRIPLETS WHERE SUBJ = ?")
      removeByO = conn.prepareStatement("DELETE FROM TRIPLETS WHERE OBJ = ?")
      removeByP = conn.prepareStatement("DELETE FROM TRIPLETS WHERE PRED = ?")
      removeBySO = conn.prepareStatement("DELETE FROM TRIPLETS WHERE SUBJ = ? AND OBJ = ?")
      removeBySP = conn.prepareStatement("DELETE FROM TRIPLETS WHERE SUBJ = ? AND PRED = ?")
      removeByOP = conn.prepareStatement("DELETE FROM TRIPLETS WHERE OBJ = ? AND PRED = ?")
      removeBySOP = conn.prepareStatement("DELETE FROM TRIPLETS WHERE SUBJ = ? AND OBJ = ? AND PRED = ?")
      removeByI = conn.prepareStatement("DELETE FROM TRIPLETS WHERE ID = ?")

      removeAll = conn.prepareStatement("TRUNCATE TABLE TRIPLETS")

    } catch {
      case ex: SQLException => { ex.printStackTrace }
    }
  }

  def putTriplet(triplet: Triplet): Int = {
    checkConnection()
    try {
      insert.setString(1, triplet.subj)
      insert.setString(2, triplet.obj)
      insert.setString(3, triplet.pred)
      insert.executeBatch
      return 0;
    } catch {
      case ex: SQLException => { ex.printStackTrace }
    }
    return -1
  }

  def putTriplets(triplets: Set[Triplet]) {
    checkConnection()
    try {

      triplets.foreach { triplet =>

        insert.setString(1, triplet.subj)
        insert.setString(2, triplet.obj)
        insert.setString(3, triplet.pred)
        insert.addBatch()

      }

      insert.executeBatch

    } catch {
      case ex: SQLException => { ex.printStackTrace }
    }
    
  }

  def removeTriplet(id: Int) {
    checkConnection()
    try {
      remove.setInt(1, id);
      remove.executeUpdate();
    } catch {
      case ex: SQLException => { ex.printStackTrace }
    }
  }

  def dropDataBase() {
    checkConnection()
    try {
      removeAll.executeUpdate();
    } catch {
      case ex: SQLException => { ex.printStackTrace }
    }
  }

  def getTriplets(id: Long, subj: String, obj: String, pred: String): Set[Triplet] = {

    checkConnection()

    var result: Set[Triplet] = Set()

    try {

      if (id > -1) {
        getByI.setLong(1, id);
        val rs: ResultSet = getByI.executeQuery()
        while (rs.next()) {
          result += new Triplet(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getInt(5))
        }
      } else if (subj != "" && obj != "" && pred != "") {
        getBySOP.setString(1, subj)
        getBySOP.setString(2, obj)
        getBySOP.setString(3, pred)
        val rs: ResultSet = getBySOP.executeQuery()
        while (rs.next()) {
          result += new Triplet(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getInt(5))
        }
      } else if (subj != "" && obj  != "") {
        getBySO.setString(1, subj)
        getBySO.setString(2, obj)
        val rs: ResultSet = getBySO.executeQuery()
        while (rs.next()) {
          result += new Triplet(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getInt(5))
        }
      } else if (subj != "" && pred != "") {
          getBySP.setString(1, subj)
          getBySP.setString(2, pred)
          val rs: ResultSet = getBySP.executeQuery()
          while (rs.next()) {
          result += new Triplet(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getInt(5))
          }
        } else if (obj != "" && pred != "") {
          getByOP.setString(1, obj)
          getByOP.setString(2, pred)
          val rs: ResultSet = getByOP.executeQuery()
          while (rs.next()) {
          result += new Triplet(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getInt(5))
          }
        } else if (subj != "") {
          getByS.setString(1, subj)
          val rs: ResultSet = getByS.executeQuery()
          while (rs.next()) {
          result += new Triplet(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getInt(5))
          }
        } else if (obj != "") {
          getByS.setString(1, obj)
          val rs: ResultSet = getByO.executeQuery()
          while (rs.next()) {
          result += new Triplet(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getInt(5))
          }
        } else if (pred != "") {
          getByP.setString(1, pred)
          val rs: ResultSet = getByP.executeQuery()
          while (rs.next()) {
          result += new Triplet(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4), rs.getInt(5))
          }
        } 
      } catch {
        case ex: SQLException => { ex.printStackTrace }
      }
      return result
  }

  def removeTriplets(id: Long, subj: String, obj: String, pred: String) {
    checkConnection()
    try {
      if (id > -1) {
        removeByI.setLong(1, id);
        removeByI.executeUpdate
      } else if (subj != "" && obj != "" && pred != "") {
        removeBySOP.setString(1, subj)
        removeBySOP.setString(2, obj)
        removeBySOP.setString(1, pred)
        removeBySOP.executeUpdate
      } else if (subj != "" && obj  != "") {
        removeBySO.setString(1, subj)
        removeBySO.setString(2, obj)
        removeBySO.executeUpdate
      } else if (subj != "" && pred != "") {
        removeBySP.setString(1, subj)
        removeBySP.setString(2, pred)
        removeBySP.executeUpdate
      } else if (obj != "" && pred != "") {
        removeByOP.setString(1, obj)
        removeByOP.setString(2, pred)
        removeByOP.executeUpdate
      } else if (subj != "") {
        removeByS.setString(1, subj)
        removeByS.executeUpdate
      } else if (obj != "") {
        removeByS.setString(1, obj)
        removeByO.executeUpdate
      } else if (pred != "") {
        removeByP.setString(1, pred)
        removeByP.executeUpdate
      } 
    } catch {
      case ex: SQLException => { ex.printStackTrace }
    }
  }


  def checkConnection() {
    if (conn == null || conn.isClosed())
      setConnection(ConnectionManager.getConnection())
  }

}
