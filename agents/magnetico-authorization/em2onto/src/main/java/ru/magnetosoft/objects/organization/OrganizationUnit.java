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

import ru.magnetosoft.objects.ObjectsHelper;

/**
 *
 * @author SheringaA
 */
public class OrganizationUnit implements Serializable {
	
	private static final long serialVersionUID = 7236181962950149947L;
	private String id;
    private String name;
    private String fullName;
    private String position;
    private String department;
    private String tag;
    private String email;
    private long tabNomer;
    private String telephone;

    public OrganizationUnit() {}

    public OrganizationUnit(User user) {
        if (user != null) {
            id = user.getId();
            name = user.getName();
            fullName = user.getFullName();
            position = user.getPosition();
            telephone = user.getTelephone();
            if (user.getDepartment() != null) {
                department = user.getDepartment().getName();
            }
            email = user.getEmail();
            tabNomer = user.getTabNomer();
        } else {
            id = "";
            name = "Пользователь";
            fullName = "Пользователь";
            position = "Должность";
            telephone = "Телефон";
            department = "Подразделение";
            email = "E-mail";
            tabNomer = 0;
        }
        tag = ObjectsHelper.userTag;
    }

    public OrganizationUnit(Department department) {
        id = department.getId();
        name = department.getName();
        this.department = department.getName();
        tag = ObjectsHelper.deptTag;
    }

    public OrganizationUnit(String position, String department) {
        name = position;
        this.position = position;
        id = name;
        this.department = department;
        tag = ObjectsHelper.posnTag;
    }

    public OrganizationUnit(String position) {
        name = position;
        this.position = position;
        id = name;
        tag = ObjectsHelper.posnTag;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public String getTag() {
        return tag;
    }

    public void setTag(String tag) {
        this.tag = tag;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public long getTabNomer() {
        return tabNomer;
    }

    public void setTabNomer(long tabNomer) {
        this.tabNomer = tabNomer;
    }

    public String getFullName() {
        return fullName;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public void setName(String name) {
        this.name = name;
    }
}