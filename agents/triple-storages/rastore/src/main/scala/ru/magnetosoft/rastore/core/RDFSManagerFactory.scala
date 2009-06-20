/*
 * RDFSManagerFactory.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package ru.magnetosoft.rastore.core

import ru.magnetosoft.rastore.interfaces.IRDFSManager
import ru.magnetosoft.rastore.impl.SimpleRDFSManager

object RDFSManagerFactory {

    def getManager(managerClass: String): IRDFSManager = {

        if (managerClass == "SimpleRDFSManager") {
            return new SimpleRDFSManager()
        }
        throw new Exception("Unknown RDFSManager")
    }
}
