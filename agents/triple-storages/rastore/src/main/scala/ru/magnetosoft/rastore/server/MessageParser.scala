package ru.magnetosoft.rastore.server

import scala.collection.mutable.Set
import scala.collection.mutable.HashMap

import ru.magnetosoft.rastore.util.Common
import ru.magnetosoft.rastore.core.Triplet
import ru.magnetosoft.rastore.core.TripletModifier
import ru.magnetosoft.rastore.core.Logger

import scala.collection.jcl.ArrayList

object MessageParser {

  val logger = new Logger(MessageParser)

  def functionsFromMessage(message: String): Set[OntoFunction] = {

    logger.debug("Got message for parsing [ " + message + " ]")

    val functions = HashMap[String, OntoFunction]()
    val argumentsMap = HashMap[String, Set[Triplet]]()
    
    val lines = split(message)

    for(line <- lines) {
      val triplet = Common.tripletFromLine(line)
      
      if (triplet.subj == "subject") {
        if (triplet.mod == TripletModifier.TripletSet.id) { // триплет с набором триплетов в объекте ?
          val new_triplet_uid = "uid-" + triplet.obj.hashCode
          for(s <- split(triplet.obj)) {
            if (argumentsMap.get(new_triplet_uid) == None)
              argumentsMap += (new_triplet_uid -> Set[Triplet]())
            argumentsMap(new_triplet_uid) += new Triplet(0, new_triplet_uid, "argument", s, TripletModifier.TripletSet.id)
          }

          if (functions.get(new_triplet_uid) == None) {
            triplet.obj_=(new_triplet_uid)
              triplet.mod_=(TripletModifier.Literal.id)
                functions += (new_triplet_uid -> new OntoFunction(triplet, Set[Triplet]()))
          }

        } else if (functions.get(triplet.obj) == None)
          functions += (triplet.obj -> new OntoFunction(triplet, Set[Triplet]()))
      } else if (triplet.pred == "argument") {
        if (argumentsMap.get(triplet.subj) == None)
          argumentsMap += (triplet.subj -> Set[Triplet]())
        argumentsMap(triplet.subj) += triplet
      }
    }

    val result = Set[OntoFunction]()
    for(key <- argumentsMap.keySet) {
      functions(key).arguments ++ argumentsMap(key)
      result += functions(key)
    }

    logger.debug("OntoFunctions created [ " + result + " ]")
    return result
  }

  def split(tripletsLine: String): Set[String] = {

    val result = Set[String]()
    val indexes = new ArrayList[Int]()

    var isBeetweenTokens = false
    var delim_number = 1

    var prev_delimiter = ' '

    def searchParams(char: Char, delim_number: Int) = {
      prev_delimiter = char
      delim_number match {
        case 0 => (false, 1)
        case 1 => (true, 2)
        case 2 => (false, 3)
        case 3 => (true, 4)
        case 4 => (false, 5)
        case 5 => (true, 6)
        case 6 => (true, 0)
      }
    }
    for(i <- 0 until tripletsLine.length) {
      val c = tripletsLine.charAt(i)
      if (c != ' ') { // если пробел, пох
        val isProcessNeeded = 
          delim_number match {
            case 0 => c == '<'
            case 1 => c == '>'
            case 2 => c == '<'
            case 3 => c == '>'
            case 4 => {
              (c == '"' || c == '<' || c == '{')
            }
            case 5 => 
              prev_delimiter match {
                case '"' => (c == '"')
                case '<' => (c == '>')
                case '{' => (c == '}')
                case _ => false
              }
            case 6 => c == '.'
            case _ => false
          }
        if (isProcessNeeded) { // если один из разделителей, то не пох
          if (c == '.') // ага, конец триплета
            indexes += i // закидываем индекс конца триплета в список
          val search_params = searchParams(c, delim_number) // берем следующий tuple (разделитель, мы_между_тоекнами, номер_разделителя) для поиска
          //          nextChar = search_params._1
          isBeetweenTokens = search_params._1
          delim_number = search_params._2
        } else if (isBeetweenTokens) {
          val search_params = if (delim_number == 0 && indexes.size > 0) {
            indexes.remove(indexes.size - 1)
            searchParams(prev_delimiter, 5)
          } else searchParams(c, delim_number)
          //          nextChar = search_params._1
          isBeetweenTokens = search_params._1
          delim_number = search_params._2
        }
      }
    }
    
    var prev = 0
    for(i <- indexes) {
      result += tripletsLine.substring(prev, i + 1).trim
      prev = i + 1
    }
    result
  }
}
