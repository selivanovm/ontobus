package ru.magnetosoft.rastore.server

import org.junit.Test
import junit.framework.TestCase
import junit.framework.Assert._ 

import ru.magnetosoft.rastore.core._

import scala.collection.mutable.Set

class MessageParserTest {

  @Test
  def splitTest() = {
    val tripletsLine = "<s1><p1><o1>. <s2> <p2> \"o2\". <s3> <p3> \"o3\" ."
    val expected = Set("<s1><p1><o1>.", "<s2> <p2> \"o2\".", "<s3> <p3> \"o3\" .")
    val result = MessageParser.split(tripletsLine)
    assertEquals(expected, result)

    val tripletsLine2 = "<subject><store> \"uid1\" . " +
    "<uid1><argument> <do_it_yourself#1> ." +
    "<uid1><argument> <do_it_yourself#2> ." +
    "<subject><store> \"uid2\" . " + 
    "<uid2><argument> \"<do> <it> <yourself#3> .\" ." +
    "<uid2><argument> \"<do> <it> <yourself#4> .\" ." +
    "<subject><store> \"uid3\" . " +
    "<uid3><argument> {<do> <it> <yourself#5> .<do> <it> <yourself#6>.} ."

    val expected2 = Set("<subject><store> \"uid1\" .", "<uid1><argument> <do_it_yourself#1> .", "<uid1><argument> <do_it_yourself#2> .", 
                        "<subject><store> \"uid2\" .", "<uid2><argument> \"<do> <it> <yourself#3> .\" .", 
                        "<uid2><argument> \"<do> <it> <yourself#4> .\" .", "<subject><store> \"uid3\" ." ,
                        "<uid3><argument> {<do> <it> <yourself#5> .<do> <it> <yourself#6>.} .")

    val result2 = MessageParser.split(tripletsLine2)

    def cmp (e1: String, e2: String): Boolean = (e1.compare(e2) > 0)
    println(expected2.toList.sort(cmp))
    println()
    println()

    assertEquals(expected2.toList.sort(cmp), result2.toList.sort(cmp))


  }

  @Test
  def functionsFromMessageTest() = {

    val cmd1 = new Triplet(0, "subject", "store", "uid1", TripletModifier.Literal.id)
    val args1 = Set[Triplet](new Triplet(0, "uid1", "argument", "do_it_yourself#1", TripletModifier.Subject.id), 
                             new Triplet(0, "uid1", "argument", "do_it_yourself#2", TripletModifier.Subject.id))

    val cmd2 = new Triplet(0, "subject", "store", "uid2", TripletModifier.Literal.id)
    val args2 = Set[Triplet](new Triplet(0, "uid2", "argument", "<do> <it> <yourself#3> .",TripletModifier.Literal.id), 
                             new Triplet(0, "uid2", "argument", "<do> <it> <yourself#4> .", TripletModifier.Literal.id))

    val cmd3 = new Triplet(0, "subject", "store", "uid3", TripletModifier.Literal.id)
    val args3 = Set[Triplet](new Triplet(0, "uid3", "argument", "<do> <it> <yourself#5> .<do> <it> <yourself#6>.",TripletModifier.TripletSet.id))

    val args_string = "<do> <it> <yourself#7> .<do> <it> <yourself#8>."
    val cmd4 = new Triplet(0, "subject", "store", "uid-" + args_string.hashCode, TripletModifier.Literal.id)
    val args4 = Set[Triplet](new Triplet(0, "uid-" + args_string.hashCode, "argument", "<do> <it> <yourself#7> .",TripletModifier.TripletSet.id),
                             new Triplet(0, "uid-" + args_string.hashCode, "argument", "<do> <it> <yourself#8>.",TripletModifier.TripletSet.id))

    val of1 = new OntoFunction(cmd1, args1)
    val of2 = new OntoFunction(cmd2, args2)
    val of3 = new OntoFunction(cmd3, args3)
    val of4 = new OntoFunction(cmd4, args4)

    val message = "<subject><store> \"uid1\" . " +
    "<uid1><argument> <do_it_yourself#1> ." +
    "<uid1><argument> <do_it_yourself#2> ." +
    "<subject><store> \"uid2\" . " + 
    "<uid2><argument> \"<do> <it> <yourself#3> .\" ." +
    "<uid2><argument> \"<do> <it> <yourself#4> .\" ." +
    "<subject><store> \"uid3\" . " +
    "<uid3><argument> {<do> <it> <yourself#5> .<do> <it> <yourself#6>.} ." +
    "<subject><store>{<do> <it> <yourself#7> .<do> <it> <yourself#8>.}."

    val functions = MessageParser.functionsFromMessage(message)

    assertTrue(functions.contains(of1))
    assertTrue(functions.contains(of2))
    assertTrue(functions.contains(of3))
    assertTrue(functions.contains(of4))
  }

}
