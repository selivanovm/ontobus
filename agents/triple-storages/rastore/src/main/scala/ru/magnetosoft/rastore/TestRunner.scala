package ru.magnetosoft.rastore

import scala.io.Source
import scala.collection.mutable.Set
import ru.magnetosoft.rastore.util._
import ru.magnetosoft.rastore.tests._
import ru.magnetosoft.rastore.core.Store
import ru.magnetosoft.rastore.core.Triplet
import ru.magnetosoft.rastore.core.Logger
import java.io.File

object TestRunner {

  val logger = new Logger(TestRunner)

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
          Source.fromFile(new File(args(0))).getLines().foreach { line =>
            if (i < 1000) {
              a += Common.tripletFromLine(line)
              i = i + 1
            } else {
              i = 0
              Store.getManager.putTriplets(a)
            }
          }
          if (i > 0)
             Store.getManager.putTriplets(a)
          
          val write = System.nanoTime() - startWrite

          logger.info("done.")

          print("Reading started...")

          val startRead = System.nanoTime()

          val tripletsIds = Store.getManager().getTriplets(-1, "", "", "http://magnetosoft.ru/ontology/id")

          for(triplet <- tripletsIds) {
            Store.getManager().getTriplets(-1, triplet.subj, "", "")
          }

          val read = System.nanoTime() - startRead

          logger.info("done.")

          print("Deleting started...")

          val startDelete = System.nanoTime()

          for(triplet <- tripletsIds) {
            Store.getManager().removeTriplets(-1, triplet.subj, "", "")
          }
        
//          Store.getManager.removeAllTriplets

          val delete = System.nanoTime() - startDelete

          logger.info("done.")

          mrWrite.putResult(write / 1000000000.0)
          mrWriteSpeed.putResult(tripletsIds.size / (write / 1000000000.0))

          mrRead.putResult(read / 1000000000.0)
          mrReadSpeed.putResult(tripletsIds.size / (read / 1000000000.0))

          mrDelete.putResult(delete / 1000000000.0)
          mrDeleteSpeed.putResult(tripletsIds.size / (delete / 1000000000.0))

          logger.info(new java.util.Date() + " : " + iterations + " iterations left.")

        }        

        logger.info("=====================================================")
        logger.info("Avg. writing  time  " + mrWrite.getAverage + " sec.")
        logger.info("Avg. reading  time  " + mrRead.getAverage + " sec.")
        logger.info("Avg. removing time  " + mrDelete.getAverage + " sec.")
        logger.info("Avg. writing  speed " + mrWriteSpeed.getAverage + " docs/sec.")
        logger.info("Avg. reading  speed " + mrReadSpeed.getAverage + " docs/sec.")
        logger.info("Avg. removing speed " + mrDeleteSpeed.getAverage + " docs/sec.")

      } catch {

        case ex: Exception => ex.printStackTrace

      }

    } else {
      System.out.println("Usage: ")
    }
  }
}
