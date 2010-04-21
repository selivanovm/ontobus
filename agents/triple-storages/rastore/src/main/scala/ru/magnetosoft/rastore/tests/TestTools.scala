/*
 * TestTools.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package ru.magnetosoft.rastore.tests

object TestTools {

    def getPaddedString(in: String, padString: String, paddingLength: Int): String = {
        var result = in
        for (i <- 0 to paddingLength) {
            result += padString
        }
        return result;
    }

}
