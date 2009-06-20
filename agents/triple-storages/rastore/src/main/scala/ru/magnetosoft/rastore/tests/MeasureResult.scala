/*
 * MeasureResult.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package ru.magnetosoft.rastore.tests

class MeasureResult {
    
	private var results: Set[Double] = Set[Double]()

	def putResult(result: Double) {
		results += result
	}

	def getAverage(): Double = {
		var sum: Double = 0

		for (value <- results) {
			sum += value
		}
		
        if (results.size > 0)
            return sum / results.size
        else
            return -1
	}

}
