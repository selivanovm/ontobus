package ru.magnetosoft.rastore.core

import scala.collection.mutable.Set

import java.io.BufferedWriter
import java.io.FileWriter
import java.io.File
import java.io.InputStream
import java.io.BufferedInputStream
import java.io.FileInputStream

import scala.io.Source
import scala.collection.mutable.Set

object FileStore {

  val DATA_FILE_NAME = "./triplets.data"

  val dataFile = new File(DATA_FILE_NAME)
  val logFile = new File("./triplets.log")
  val dataWriter = new BufferedWriter(new FileWriter(DATA_FILE_NAME, true))

  def putTriplets(triplets: Set[String]) = {
    dataWriter.write(triplets.mkString("\n"))
    dataWriter.newLine()
    dataWriter.flush
  }

  def tripletsCount(): Int = {
    val is = new BufferedInputStream(new FileInputStream(DATA_FILE_NAME))
    var c = new Array[Byte](1024)
    var count = 0
    var readChars = 0
    var isFinish = false
    while (!isFinish) {
      readChars = is.read(c)
      if (readChars == -1) isFinish = true
      else for (i <- 0 until readChars) {
        if (c(i) == '\n')
          count = count + 1
      }
    }
    is.close
    count
  }

  def lineIterator(): Iterator[String] = Source.fromFile(new File(DATA_FILE_NAME)).getLines()

  def tripletsAsString(fromIndex: Int, toIndex: Int): String =
    (for(i <- fromIndex to toIndex)
      yield Source.fromFile(new File(DATA_FILE_NAME)).getLine(i)).mkString("")
  
}
