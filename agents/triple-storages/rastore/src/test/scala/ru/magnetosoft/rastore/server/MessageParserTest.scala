package ru.magnetosoft.rastore.server

import org.junit.Test
import junit.framework.TestCase
import junit.framework.Assert._ 

import ru.magnetosoft.rastore.core._

import scala.collection.mutable.Set

class MessageParserTest {

  @Test
  def functionsFromMessageTest() = {

    val cmd1 = new Triplet(0, "subject", "store", "uid1", TripletModifier.Literal.id)
    val args1 = Set[Triplet](new Triplet(0, "uid1", "argument", "do_it_yourself#1", TripletModifier.Subject.id), 
                             new Triplet(0, "uid1", "argument", "do_it_yourself#2", TripletModifier.Subject.id))

    val cmd2 = new Triplet(0, "subject", "store", "uid2", TripletModifier.Literal.id)
    val args2 = Set[Triplet](new Triplet(0, "uid2", "argument", "<do> <it> <yourself#3> .",TripletModifier.Literal.id), 
                             new Triplet(0, "uid2", "argument", "<do> <it> <yourself#4> .", TripletModifier.Literal.id))

    val of1 = new OntoFunction(cmd1, args1)
    val of2 = new OntoFunction(cmd2, args2)

    val message = "<subject><store> \"uid1\" . \n" +
    "<uid1><argument> <do_it_yourself#1> .\n" +
    "<uid1><argument> <do_it_yourself#2> .\n" +
    "<subject><store> \"uid2\" . \n" + 
    "<uid2><argument> \"<do> <it> <yourself#3> .\" .\n" +
    "<uid2><argument> \"<do> <it> <yourself#4> .\" .\n"

    val functions = MessageParser.functionsFromMessage(message)

    assertTrue(functions.contains(of1))
    assertTrue(functions.contains(of2))

  }

}
