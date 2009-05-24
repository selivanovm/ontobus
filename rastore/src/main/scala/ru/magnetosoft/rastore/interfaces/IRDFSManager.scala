/*
 * IRDFSManager.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package ru.magnetosoft.rastore.interfaces

import ru.magnetosoft.rastore.core.Triplet
import java.sql.Connection
import scala.collection.mutable.Set

trait IRDFSManager {

  def setConnection(c: Connection)

  def putTriplet(triplet: Triplet): Int

  def putTriplets(triplets: Set[Triplet])

  def dropDataBase()

  def getTriplets(id: Long, subj: String, obj: String, pred: String): Set[Triplet]

  def removeTriplets(id: Long, subj: String, obj: String, pred: String)

/*  def getTripletById(id: Int): Triplet

  def getTripletsByObject(obj: String): Set[Triplet]

  def getTripletsBySubject(subject: String): Set[Triplet]

  def getTripletsByPredicate(predicate: String): Set[Triplet]

  def getTripletsByQuery(query: String): Set[Triplet]
  */  
}
