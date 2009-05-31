package ru.magnetosoft.rastore.core

import org.junit.Test
import junit.framework.TestCase
import junit.framework.Assert._ 

class TripletTest {
  @Test
  def equalsTest() = {
    val tr1 = new Triplet(0, "s1", "p1", "o1", TripletModifier.Literal.id)
    val tr2 = new Triplet(0, "s1", "p1", "o1", TripletModifier.Literal.id)
    val tr3 = new Triplet(0, "s1", "p2", "o1", TripletModifier.Literal.id)

    assertTrue(tr1 == tr2)
    assertFalse(tr1 == tr3)

  }
}
