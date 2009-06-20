package ru.magnetosoft.rastore.core

import java.util.Date
import java.text.SimpleDateFormat
import java.io.File
import java.io.BufferedWriter
import java.io.FileWriter

class Logger(obj: AnyRef) {

  def error(msg: String) = LogManager.error(msg, obj)

  def info(msg: String) = LogManager.info(msg, obj)

  def debug(msg: String) = LogManager.debug(msg, obj)
  
}
