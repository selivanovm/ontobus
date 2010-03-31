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
public class Department implements Serializable {

    private static final long serialVersionUID = 1;
    private String name;
    private String id;
    private String internalId;

    public Department() {
    }

    public Department(EntityType blObject, String locale) {
        setId(blObject.getUid());

        if (blObject.getAttributes() != null) {
            for (AttributeType a : blObject.getAttributes().getAttributeList()) {
                if (a.getName().equalsIgnoreCase("name" + locale)) {
                    setName(a.getValue());
                } // end else if
                else if (a.getName().equalsIgnoreCase("id")) {
                    setInternalId(a.getValue());
                } // end else if
            }
        } // end create_department()
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

    public void setName(String name) {
        this.name = name;
    }

    public String getInternalId() {
        return internalId;
    }

    public void setInternalId(String internalId) {
        this.internalId = internalId;
    }
}
