package ru.magnetosoft.rastore.server

import scala.collection.mutable.Set
import scala.collection.mutable.HashMap

import ru.magnetosoft.rastore.util.Common
import ru.magnetosoft.rastore.core.Triplet

object MessageParser {

  def functionsFromMessage(message: String): Set[OntoFunction] = {

    val functions = HashMap[String, OntoFunction]()
    
    val lines = message.split("[\n]")

    for(line <- lines) {
      val triplet = Common.tripletFromLine(line)
      
      if (triplet.subj == "subject") {
        if (functions.get(triplet.obj) == None) {
          functions += (triplet.obj -> new OntoFunction(triplet, Set[Triplet]()))
        }
      } else if (triplet.pred == "argument") {
        if (functions(triplet.subj) == None) {
          functions += (triplet.subj -> new OntoFunction(triplet, Set[Triplet]()))
        }
        functions(triplet.subj).arguments += triplet
      }
    }

    val result = Set[OntoFunction]()
    for(key <- functions.keySet)
      result += functions(key)

    return result
  }

}
