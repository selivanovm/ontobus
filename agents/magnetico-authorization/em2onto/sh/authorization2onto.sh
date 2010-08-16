#!/bin/sh

db_host="mg-sv02"

ns='mo/at/acl#'

tmpSqlFile="./tmp.sql"

#queryPostfix=" where category = 'DOCUMENT'"

#########################
# Authorization records #
#########################

resultFile="./authorization_db.onto"
rm $resultFile 

echo `date +%H:%M`" - Authorization records extracting..."

rm $tmpSqlFile 

mysql -uba -p123456 -h $db_host -e "select authorSystem, authorSubsystem, authorSubsystemElement, targetSystem, targetSubsystem, targetSubsystemElement, category, elementId, dateFrom, dateTo, _create, _read, _update, _delete from authorization_db.authorizationrightrecords $queryPostfix;" > $tmpSqlFile

i=0

cat $tmpSqlFile | while read line; do

    echo $line | { read authorSystem authorSubsystem authorSubsystemElement targetSystem targetSubsystem targetSubsystemElement category elementId dateFrom dateTo _create _read _update _delete; 

	if [ $i -gt 0 ]; then
#		echo "<${ns}RightsRecord$i> <${ns}id> \"$id\" ." >> $resultFile
#		if [ -z "$dateTo" -o "$dateTo" = "0" -o ! -z "$dateTo" -a "$dateTo" != "0" -a "$dateTo" -gt "1251979200000" ]; then 
		    if [ ! -z "$dateTo" -a "$dateTo" != "0" ]; then echo "<${ns}RR$i> <${ns}dtT> \"$dateTo\" ." >> $resultFile; fi
		    if [ ! -z "$authorSystem" ]; then echo "<${ns}RR$i> <${ns}atS> \"$authorSystem\" ." >> $resultFile; fi
		    if [ ! -z "$authorSubsystem" ]; then echo "<${ns}RR$i> <${ns}atSs> \"$authorSubsystem\" ." >> $resultFile; fi
		    if [ ! -z "$authorSubsystemElement" ]; then echo "<${ns}RR$i> <${ns}atSsE> \"$authorSubsystemElement\" ." >> $resultFile; fi

		    if [ ! -z "$targetSystem" ]; then echo "<${ns}RR$i> <${ns}tgS> \"$targetSystem\" ." >> $resultFile; fi
		    if [ ! -z "$targetSubsystem" ]; then echo "<${ns}RR$i> <${ns}tgSs> \"$targetSubsystem\" ." >> $resultFile; fi
		    if [ ! -z "$targetSubsystemElement" ]; then echo "<${ns}RR$i> <${ns}tgSsE> \"$targetSubsystemElement\" ." >> $resultFile; fi
		    if [ ! -z "$category" ]; then echo "<${ns}RR$i> <${ns}cat> \"$category\" ." >> $resultFile; fi

		    if [ ! -z "$elementId" ]; then echo "<${ns}RR$i> <${ns}eId> \"$elementId\" ." >> $resultFile; fi
		    if [ ! -z "$dateFrom" -a "$dateFrom" != "0" ]; then echo "<${ns}RR$i> <${ns}dtF> \"$dateFrom\" ." >> $resultFile; fi

		    if [ ! -z "$_read" -a "$_read" = "1" ]; then _read="r"; else _read=""; fi
		    if [ ! -z "$_create" -a "$_create" = "1" ]; then _create="c"; else _create=""; fi
		    if [ ! -z "$_delete" -a "$_delete" = "1" ]; then _delete="d"; else _delete=""; fi
		    if [ ! -z "$_update" -a "$_update" = "1" ]; then _update="u"; else _update=""; fi

		    echo "<${ns}RR$i> <${ns}rt> \"${_create}${_read}${_update}${_delete}\" ." >> $resultFile

#		if [ ! -z "$authorSystem" ]; then echo "<${authorSubsystemElement}> <${ns}group> \"$authorSystem\" ." >> $resultFile; fi

		    i=$((i + 1))
#		fi
	fi
    }
    i=$((i + 1))
done

echo `date +%H:%M`" - done."

#############
# Delegates #
#############

echo `date +%H:%M`" - Delegates extracting..."

rm $tmpSqlFile 

mysql -uba -p123456 -h $db_host -e "select * from authorization_db.delegates $queryPostfix;" > $tmpSqlFile

i=0

cat $tmpSqlFile | while read line; do

    echo $line | { read id fromUserId toUserId withDelegatesTree ; 
	if [ $i -gt 0 ]; then
#	    echo "<${ns}DelegatesRecord$i> <${ns}id> \"$id\" ." >> $resultFile
	    if [ ! -z "$fromUserId" ]; then echo "<${ns}DR$i> <${ns}ow> \"$fromUserId\" ." >> $resultFile; fi
	    if [ ! -z "$toUserId" ]; then echo "<${ns}DR$i> <${ns}de> \"$toUserId\" ." >> $resultFile; fi
	    if [ ! -z "$withDelegatesTree" -a "$withDelegatesTree" != "0" ]; then echo "<${ns}DR$i> <${ns}wt> \"$withDelegatesTree\" ." >> $resultFile; fi
	fi
    }
    i=$((i+1))

done

echo `date +%H:%M`" - done."

exit 0

#######################################################################################################################################################################
##############################################################                  EXIT              #####################################################################
#######################################################################################################################################################################

#########
# Roles #
#########

resultFile="./authentication_db.onto"
rm $resultFile 

echo `date +%H:%M`" - Roles extracting..."

rm $tmpSqlFile 

mysql -uroot -pmysql -e "select * from authentication_db.roles $queryPostfix;" > $tmpSqlFile

i=0

cat $tmpSqlFile | while read line; do

    echo $line | { read id name authenticationType ; 
	if [ $i -gt 0 ]; then
	    echo "<${ns}RoleRecord$i> <${ns}id> \"$id\" ." >> $resultFile
	    echo "<${ns}RoleRecord$i> <${ns}name> \"$name\" ." >> $resultFile
	    echo "<${ns}RoleRecord$i> <${ns}authenticationType> \"$authenticationType\" ." >> $resultFile
	fi
    }
    i=$((i+1))

done

echo `date +%H:%M`" - done.\n"

########################
# Session Ticket Roles #
########################

echo `date +%H:%M`" - Session Ticket Roles extracting..."

rm $tmpSqlFile 

mysql -uroot -pmysql -e "select * from authentication_db.sessionticketroles $queryPostfix;" > $tmpSqlFile

i=0

cat $tmpSqlFile | while read line; do

    echo $line | { read tickId roleId ; 
	if [ $i -gt 0 ]; then
	    echo "<${ns}SessionTicketRole$i> <${ns}tickId> \"$tickId\" ." >> $resultFile
	    echo "<${ns}SessionTicketRole$i> <${ns}roleId> \"$roleId\" ." >> $resultFile
	fi
    }
    i=$((i+1))

done

echo `date +%H:%M`" - done.\n"

####################
# Session Tickets  #
####################

echo `date +%H:%M`" - Session Tickets extracting..."

rm $tmpSqlFile 

mysql -uroot -pmysql -e "select * from authentication_db.sessiontickets $queryPostfix;" > $tmpSqlFile

i=0

cat $tmpSqlFile | while read line; do

    echo $line | { read id applicationName applicationNamespace authenticationType expired issueDate lastAccessDate sessionValidityPeriod source user_id; 
	if [ $i -gt 0 ]; then
	    echo "<${ns}SessionTicket$i> <${ns}id> \"$id\" ." >> $resultFile
	    echo "<${ns}SessionTicket$i> <${ns}applicationName> \"$applicationName\" ." >> $resultFile
	    echo "<${ns}SessionTicket$i> <${ns}applicationNamespace> \"$applicationNamespace\" ." >> $resultFile
	    echo "<${ns}SessionTicket$i> <${ns}authenticationType> \"$authenticationType\" ." >> $resultFile
	    echo "<${ns}SessionTicket$i> <${ns}expired> \"$expired\" ." >> $resultFile
	    echo "<${ns}SessionTicket$i> <${ns}issueDate> \"$issueDate\" ." >> $resultFile
	    echo "<${ns}SessionTicket$i> <${ns}lastAccessDate> \"$lastAccessDate\" ." >> $resultFile
	    echo "<${ns}SessionTicket$i> <${ns}sessionValidityPeriod> \"$sessionValidityPeriod\" ." >> $resultFile
	    echo "<${ns}SessionTicket$i> <${ns}source> \"$source\" ." >> $resultFile
	    echo "<${ns}SessionTicket$i> <${ns}user_id> \"$user_id\" ." >> $resultFile
	fi
    }
    i=$((i+1))

done

echo `date +%H:%M`" - done.\n"


##########
# Users  #
##########

echo `date +%H:%M`" - Users extracting..."

rm $tmpSqlFile 

mysql -uroot -pmysql -e "select * from authentication_db.users $queryPostfix;" > $tmpSqlFile

i=0

cat $tmpSqlFile | while read line; do

    echo $line | { read id name authenticationType; 
	if [ $i -gt 0 ]; then
	    echo "<${ns}User$i> <${ns}id> \"$id\" ." >> $resultFile
	    echo "<${ns}User$i> <${ns}name> \"$name\" ." >> $resultFile
	    echo "<${ns}User$i> <${ns}authenticationType> \"$authenticationType\" ." >> $resultFile
	fi
    }
    i=$((i+1))

done

echo `date +%H:%M`" - done.\n"


