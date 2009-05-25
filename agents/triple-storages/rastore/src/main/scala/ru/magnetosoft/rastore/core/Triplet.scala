/*
 * Triplet.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package ru.magnetosoft.rastore.core

class Triplet {

  var id: Int = 0
  var subj: String = null
  var obj: String = null
  var pred: String = null

  def this(id: Int, subj: String, obj: String, pred: String) {
    this()
    this.id_=(id)
    this.subj_=(subj)
    this.obj_=(obj)
    this.pred_=(pred)
  }

  override def equals(other: Any): Boolean = {
    var result = true

    if (!other.isInstanceOf[Triplet]) return false
    else {
      val rdft = other.asInstanceOf[Triplet]

      if (this.subj != rdft.subj) return false
      else if (this.obj != rdft.obj) return false
      else if (this.pred != rdft.pred) return false
      else return result;
    }
  }

  def populate(id: Int, subj: String, obj: String, pred: String): Triplet = {
    this.id_=(id)
    this.subj_=(subj)
    this.obj_=(obj)
    this.pred_=(pred)
    return this
  }

  
  override def toString(): String = {
    return "Triplet: id = " + id + ", subj = " + subj + ", obj = " + obj + ", pred = " + pred
  }

}
