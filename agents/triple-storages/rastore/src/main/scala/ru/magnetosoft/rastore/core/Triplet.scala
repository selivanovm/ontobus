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
  var mod: Int = 0

  def this(id: Int, subj: String, pred: String, obj: String, mod: Int) {
    this()
    this.id_=(id)
    this.subj_=(subj)
    this.obj_=(obj)
    this.pred_=(pred)
    this.mod_=(mod)
  }

  override def equals(other: Any): Boolean = 
    if (!other.isInstanceOf[Triplet]) return false
    else {
      val rdft = other.asInstanceOf[Triplet]
      if (this.subj != rdft.subj) false
      else if (this.obj != rdft.obj) false
      else if (this.pred != rdft.pred) false
      else if (this.mod != rdft.mod) false
      else true
    }

  def populate(id: Int, pred: String, subj: String, obj: String, mod: Int): Triplet = {
    this.id_=(id)
    this.subj_=(subj)
    this.obj_=(obj)
    this.pred_=(pred)
    this.mod_=(mod)
    return this
  }

  
  override def toString(): String = "Triplet: id = " + id + ", subj = " + subj + ", pred = " + pred + ", obj = " + obj + ", mod = " + mod
  
  override def hashCode(): Int = {
    var result = 17
    result = 31 * result + subj.hashCode
    result = 31 * result + pred.hashCode
    result = 31 * result + obj.hashCode
    result = 31 * result + mod
    return result
  }
}
