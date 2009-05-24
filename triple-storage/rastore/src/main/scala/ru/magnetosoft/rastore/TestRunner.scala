package ru.magnetosoft.rastore

import scala.io.Source
import scala.collection.mutable.Set

import ru.magnetosoft.rastore.tests._
import ru.magnetosoft.rastore.core.Store
import ru.magnetosoft.rastore.core.Triplet

object TestRunner {

  def main(args: Array[String]) {

    if (args.size == 2) {

      var iterations = args(1).toInt
      
      try {

        Store.getManager.dropDataBase

        val mrWrite = new MeasureResult()
        val mrRead = new MeasureResult()
        val mrDelete = new MeasureResult()
        val mrReadSpeed = new MeasureResult()
        val mrWriteSpeed = new MeasureResult()        
        val mrDeleteSpeed = new MeasureResult()

        while(iterations > 0) {

          iterations = iterations - 1
        
          print("Writing started...")

          val startWrite = System.nanoTime()

          var i = 0
          var a = Set[Triplet]()
          Source.fromFile(args(0)).getLines.foreach { line =>
            if (i < 1000) {
              a += tripletFromLine(line)
              i = i + 1
            } else {
              i = 0
              Store.getManager.putTriplets(a)
            }
          }
          if (i > 0)
             Store.getManager.putTriplets(a)
          
          val write = System.nanoTime() - startWrite

          println("done.")

          print("Reading started...")

          val startRead = System.nanoTime()

          val tripletsIds = Store.getManager().getTriplets(-1, "", "", "http://magnetosoft.ru/ontology/id")

          for(triplet <- tripletsIds) {
            Store.getManager().getTriplets(-1, triplet.subj, "", "")
          }

          val read = System.nanoTime() - startRead

          println("done.")

          print("Deleting started...")

          val startDelete = System.nanoTime()

          for(triplet <- tripletsIds) {
            Store.getManager().removeTriplets(-1, triplet.subj, "", "")
          }
        
//          Store.getManager.removeAllTriplets

          val delete = System.nanoTime() - startDelete

          println("done.")

          mrWrite.putResult(write / 1000000000.0)
          mrWriteSpeed.putResult(tripletsIds.size / (write / 1000000000.0))

          mrRead.putResult(read / 1000000000.0)
          mrReadSpeed.putResult(tripletsIds.size / (read / 1000000000.0))

          mrDelete.putResult(delete / 1000000000.0)
          mrDeleteSpeed.putResult(tripletsIds.size / (delete / 1000000000.0))

          println(new java.util.Date() + " : " + iterations + " iterations left.")

        }        

        println("=====================================================")
        println("Avg. writing  time  " + mrWrite.getAverage + " sec.")
        println("Avg. reading  time  " + mrRead.getAverage + " sec.")
        println("Avg. removing time  " + mrDelete.getAverage + " sec.")
        println("Avg. writing  speed " + mrWriteSpeed.getAverage + " docs/sec.")
        println("Avg. reading  speed " + mrReadSpeed.getAverage + " docs/sec.")
        println("Avg. removing speed " + mrDeleteSpeed.getAverage + " docs/sec.")

      } catch {

        case ex: Exception => ex.printStackTrace

      }


    } else {
      System.out.println("Usage: ")
    }
  }

  def tripletFromLine(line: String): Triplet = {
    val tokens: Array[String] = line.split("[>]")
    val subj = escapeString(tokens(0).trim.substring(1))
    val pred = escapeString(tokens(1).trim.substring(1))
    val obj = escapeString(tokens(2).substring(0, tokens(2).length - 2).substring(2, tokens(2).length - 4))
    return new Triplet(0, subj, obj, pred)
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

}
