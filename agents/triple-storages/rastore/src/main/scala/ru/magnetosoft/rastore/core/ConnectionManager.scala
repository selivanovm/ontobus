/*
 * ConnectionManager.scala
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package ru.magnetosoft.rastore.core

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

object ConnectionManager {

    private var c: Connection = null

    def getConnection(): Connection = {

        if (c == null || c.isClosed()) {
            Class.forName(StoreConfiguration.getProperties.getProperty("database_driver_class"));
            val url:String = StoreConfiguration.getProperties.getProperty("database_url");
            val user:String = StoreConfiguration.getProperties.getProperty("database_user");
            val pwds:String  = StoreConfiguration.getProperties.getProperty("database_password");
            c = DriverManager.getConnection(url, user, pwds);
        }
        return c;

    }

}
