/**
 * Copyright (c) 2007-2008, Magnetosoft, LLC
 * All rights reserved.
 * 
 * Licensed under the Magnetosoft License. You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.magnetosoft.ru/LICENSE
 *
 */
package ru.magnetosoft.objects.organization;

import java.io.Serializable;

import ru.magnetosoft.bigarch.wsclient.bl.organizationservice.AttributeType;
import ru.magnetosoft.bigarch.wsclient.bl.organizationservice.EntityType;

/**
 *
 * @author SheringaA
 */
public class User implements Serializable {

    private static final long serialVersionUID = 1L;
    private String id;
    private String name;
    private String firstName;
    private String middleName;
    private String lastName;
    private String position;
    private Department department;
    private String email;
    private String login;
    private long tabNomer;
    private String telephone;
    private String internalId;

    public User() {
    }

    public User(EntityType blObject, String locale) {
        setId(blObject.getUid());

        if (blObject.getAttributes() != null) {
            for (AttributeType a : blObject.getAttributes().getAttributeList()) {
                if (a.getName().equalsIgnoreCase("firstName" + locale)) {
                    setFirstName(a.getValue());
                } // end if
                else if (a.getName().equalsIgnoreCase("secondname" + locale)) {
                    setMiddleName(a.getValue());
                } // end else if
                else if (a.getName().equalsIgnoreCase("surname" + locale)) {
                    setLastName(a.getValue());
                } // end else if
                else if (a.getName().equals("domainName")) {
                    setLogin(a.getValue());
                } // end else if
                else if (a.getName().equals("email")) {
                    setEmail(a.getValue());
                } // end else if
                else if (a.getName().equalsIgnoreCase("post" + locale)) {
                    setPosition(a.getValue());
                } // end else if
                else if (a.getName().equalsIgnoreCase("pid")) {
                    setTabNomer(a.getValue());
                } // end else if
                else if (a.getName().equalsIgnoreCase("phone")) {
                    setTelephone(a.getValue());
                } // end else if
                else if (a.getName().equalsIgnoreCase("id")) {
                    setInternalId(a.getValue());
                } // end else if
            }
        }

        if (lastName != null && firstName != null) {
            name = lastName + " " + firstName;
        }
    }

    public String getFullName() {
        return lastName + " " + firstName + " " + middleName;
    }

    public String getShortName() {
        if (lastName != null && firstName != null) {
            return lastName + " " + firstName;
        }
        return login;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public Department getDepartment() {
        return department;
    }

    public void setDepartment(Department department) {
        this.department = department;
    }

    public long getTabNomer() {
        return tabNomer;
    }

    public void setTabNomer(String tabNomer) {
        try {
            this.tabNomer = new Long(tabNomer);
        } catch (Exception ex) {
            ex.printStackTrace();
            this.tabNomer = 0;
        }
    }

    public String getMiddleName() {
        return middleName;
    }

    public void setMiddleName(String middleName) {
        this.middleName = middleName;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public String getInternalId() {
        return internalId;
    }

    public void setInternalId(String internalId) {
        this.internalId = internalId;
    }
}