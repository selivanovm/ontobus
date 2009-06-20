package ru.magnetosoft.rastore.core

import java.util.Date
import java.text.SimpleDateFormat
import java.io.File
import java.io.BufferedWriter
import java.io.FileWriter

object LogManager {

  object LogLevel extends Enumeration {
    val ERROR = Value("error")
    val INFO = Value("info")
    val DEBUG = Value("debug")
  }

  def writeToFile(msg: String) = {
    val logFile = new File(StoreConfiguration.getProperties.getProperty("log_file_path", "./server.log"))
    val dataWriter = new BufferedWriter(new FileWriter(logFile, true))
    dataWriter.write(msg)
    dataWriter.newLine
    dataWriter.close
  }

  def log(msg: String, level: Int) = {
    val currentLogLevel = logLevel(StoreConfiguration.getProperties.getProperty("log_level"))
    if (level <= currentLogLevel) {
      val logLine = getDate(new Date()) + " | " + LogLevel(level) + " " * (5 - LogLevel(level).toString.length) + " | " + msg
      val logMode = StoreConfiguration.getProperties.getProperty("log_mode", "sysout")
      if (logMode == "file")
        writeToFile(logLine)
      else if (logMode == "sysout")
        println(logLine)
    }
  }

  def error(msg: String) = {
    log(msg, LogLevel.ERROR.id)
  }

  def info(msg: String) = {
    log(msg, LogLevel.INFO.id)
  }

  def debug(msg: String) = {
    log(msg, LogLevel.DEBUG.id)
  }

  def getDate(date: Date): String = new SimpleDateFormat("yyyy.MM.dd-HH:mm:ss").format(date)

  def logLevel(levelString: String): Int = { 
    val lvl = LogLevel.valueOf(levelString)
    if (lvl != None)
      lvl.get.id
    else
      LogLevel.INFO.id
  }

}
