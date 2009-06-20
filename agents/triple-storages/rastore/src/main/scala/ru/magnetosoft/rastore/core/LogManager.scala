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

  def log(msg: String, obj: AnyRef, level: Int) = {
    val currentLogLevel = logLevel(StoreConfiguration.getProperties.getProperty("log_level", "debug"))
    if (level <= currentLogLevel) {
      val logFilter = StoreConfiguration.getProperties.getProperty("log_filter", "")

      val isFilterMathes = 
        if (logFilter == "") true
        else if (logFilter.split(";").filter((el: String) => obj.getClass.getName.endsWith(el)).size == 0) false
        else true
      
      if (isFilterMathes) {
        val logLine = getDate(new Date()) + " | " + LogLevel(level) + " " * (5 - LogLevel(level).toString.length) + " | " + obj.getClass.getName + " | " + msg
        val logMode = StoreConfiguration.getProperties.getProperty("log_mode", "sysout")
        if (logMode == "file")
          writeToFile(logLine)
        else if (logMode == "sysout")
          println(logLine)
      }
    }
  }

  def error(msg: String, obj: AnyRef) = {
    log(msg, obj, LogLevel.ERROR.id)
  }

  def info(msg: String, obj: AnyRef) = {
    log(msg, obj, LogLevel.INFO.id)
  }

  def debug(msg: String, obj: AnyRef) = {
    log(msg, obj, LogLevel.DEBUG.id)
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
