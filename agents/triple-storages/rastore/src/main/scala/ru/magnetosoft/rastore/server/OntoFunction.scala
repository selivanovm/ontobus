package ru.magnetosoft.rastore.server

import ru.magnetosoft.rastore.core.Triplet
import ru.magnetosoft.rastore.util.Common

import scala.collection.mutable.Set

class OntoFunction () {

  var command: Triplet = null
  var arguments: Set[Triplet] = null
  
  def this(command: Triplet, arguments: Set[Triplet]) {
    this()
    this.command_=(command)
    this.arguments_=(arguments)
  }

  override def equals(other: Any): Boolean = 
    if (!other.isInstanceOf[OntoFunction]) false 
    else {
      val of = other.asInstanceOf[OntoFunction]
      if (this.command != of.command) false
      else if (this.arguments.size != of.arguments.size) false
      else if (Common.setEqualityCheck(this.arguments, of.arguments)) true
      else false
    }

  override def toString(): String = "OntoFunction: command = " + command + ", arguments = \n" + arguments.mkString("\n\t")

  override def hashCode(): Int = { 
    var result = 17
    result = 31 * result + command.hashCode
    arguments.foreach(arg =>
      result = 31 * result + arg.hashCode) 
    return result
  }

}
