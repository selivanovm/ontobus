package ru.magnetosoft.rastore.util

import ru.magnetosoft.rastore.core.Triplet
import ru.magnetosoft.rastore.core.TripletModifier

import scala.collection.mutable.Set

object Common {

  def tripletFromLine(line: String): Triplet = {
    val i1 = line.indexOf(">")
    if (i1 > -1) {
      val subj = escapeString(line.substring(1, i1))
      val i2 = line.indexOf(">", i1 + 1)
      if (i2 > -1) { 
        val i3 = line.indexOf("<", i1)
        val pred = escapeString(line.substring(i3 + 1, i2))       
        val obj_token = line.substring(i2 + 1, line.length).trim
        val obj = untripledString(obj_token)
        val mod = if (obj_token.startsWith("<")) TripletModifier.Subject.id else TripletModifier.Literal.id
        new Triplet(0, subj, pred, obj, mod)
      } else return null
    } else return null
  }

  def escapeString(line: String): String = {
    var sb = new StringBuilder()
    for (i <- 0 until line.length) {
      val c = line.charAt(i)
      sb.append(
        c match {
          case '\t' => "\\t"
          case '\n' => "\\n"
          case '\r' => "\\r"
          case '\\' => "\\\\"
          case '\"' => "\\\""
          case _ => c
        }
      )
    }
    return sb.toString
  }

  def untripledString(string: String): String =
    if (string.startsWith("\"") || string.startsWith("<")) {
      if (string.endsWith(">"))
        string.substring(1, string.length - 1)
      else
        string.substring(1, string.length - 3)
    } else string

  def setEqualityCheck[T](s1: Set[T], s2: Set[T]): Boolean =
    if (s1.size != s2.size) return false
    else if (!leftSetContainsAllRight(s1, s2)) return false
      else if (!leftSetContainsAllRight(s2, s1)) return false
        else return true

  def leftSetContainsAllRight[T](s1: Set[T], s2: Set[T]): Boolean = {
    s2.foreach(el => {
      if (!s1.contains(el)) {
        return false
      }
    })
    return true
  }
}
