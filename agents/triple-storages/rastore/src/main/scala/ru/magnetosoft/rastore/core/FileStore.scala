package ru.magnetosoft.rastore.core

import ru.magnetosoft.rastore.core.Triplet
import scala.collection.mutable.Set

import java.io.BufferedWriter
import java.io.FileWriter
import java.io.File

object FileStore {

  val dataFile = new File("./data")
  val logFile = new File("./data.log")
  val dataWriter = new BufferedWriter(new FileWriter("./data"))

  def putTriplets(triplets: Set[String]) = {
    for(triplet <- triplets) {
      dataWriter.write(triplet)
      dataWriter.newLine()
    }
  }

}
