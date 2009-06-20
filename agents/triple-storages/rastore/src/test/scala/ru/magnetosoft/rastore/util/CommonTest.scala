package ru.magnetosoft.rastore.util

import org.junit.Test
import junit.framework.TestCase
import junit.framework.Assert._ 

import scala.collection.mutable.Set

import ru.magnetosoft.rastore.core._

class CommonTest {


  @Test
  def untripledString() = {
    assertEquals("wow", Common.untripledString("<wow>"))
    assertEquals("wow", Common.untripledString("\"wow\" ."))
  }

  @Test
  def tripletFromLineTest() = {

    val line1 = "<uid1> <argument>\"<i> <have> <beautiful wife#1> .\"."
    val expected1 = new Triplet(0, "uid1", "argument", "<i> <have> <beautiful wife#1> .", TripletModifier.Literal.id)
    val result1 = Common.tripletFromLine(line1)

    assertEquals(expected1, result1)

    val line2 = "<uid1>   <argument>{<s1><p1><o1>.<s2><p2><o2>.}  ."
    val expected2 = new Triplet(0, "uid1", "argument", "<s1><p1><o1>.<s2><p2><o2>.", TripletModifier.TripletSet.id)
    val result2 = Common.tripletFromLine(line2)

    assertEquals(expected2, result2)
  }

  @Test 
  def leftSetContainsAllRightTest() = {

    val set1 = Set("One", "Two", "Tree")
    val set2 = Set("One", "Tree", "Two")
    val set3 = Set("One", "Two", "Four")
    
    assertTrue(Common.leftSetContainsAllRight(set1, set2))
    assertFalse(Common.leftSetContainsAllRight(set2, set3))

  }

  @Test
  def setEqualityCheckTest() = {

    val set1 = Set("One", "Two", "Tree")
    val set2 = Set("One", "Tree", "Two")
    val set3 = Set("One", "Two", "Four")
    val set4 = Set("One", "Two")
    val set5 = Set("One", "Two", "Four", "Three")

    assertTrue(Common.setEqualityCheck(set1, set2))
    assertFalse(Common.setEqualityCheck(set1, set3))
    assertFalse(Common.setEqualityCheck(set2, set3))
    assertFalse(Common.setEqualityCheck(set4, set5))
    assertFalse(Common.setEqualityCheck(set4, set1))

  }
}
