#!/bin/bash
#@author Shouvik Chatterjee for Monsoon Consulting
#@desc Utility to create database, exports from existing database and imports to new db. Create users, assigns users to database.
#@usage sudo sh PATH/TO/script.sh -a myapplication -s 'PATH/TO/database.sql' -p abc123

#Root Login Information. To be altered by sys admin
MYSQLADM="root"
MYSQLADMPASS="root"
MYSQLADMIP="localhost"
MYSQL=/usr/bin/mysql

#Dynamic Database Information. DO NOT TOUCH
CURDIR=$(dirname $0)/
SCRIPTNAME="Automatic Database Deployment Console (ADDC)"
DEFAULTDBPASS="Monsoon12345"

while getopts a:s:r:p:h option
do
    case "$option" in
    a)
         APP=$OPTARG
	 NEWDBUSER1=${APP}_user
	 NEWDBUSER2=${APP}_appuser
         ;;
    s)
         SQL=$OPTARG
         ;;
    r)
         RELEASENAME=$OPTARG
         ;;
    p)
         NEWDBPASS=$OPTARG
         ;;
    h)
	echo ""
	echo "~~~~~Welcome to the $SCRIPTNAME Help~~~~~"
	echo "### Copyright (c) 2012 By Shouvik Chatterjee for Monsoon Consulting ###"
	echo ""
	echo "[-a] Application name. The db will be created with this name."
	echo "[-s] Sql source file with path. Used when creating a fresh database. Does not work with [-r]."
	echo "[-r] Release name."
	echo "[-p] Password of the new database. Leaving blank will generate the default password."
	echo ""
	echo "Usage Eg1: PATH/TO/script.sh -a myapplication -s 'PATH/TO/database.sql' -p abc123"
	echo ""
	echo "Usage Eg2: PATH/TO/script.sh -a myapplication -r uat1 -p abc123"
	echo ""
	exit
         ;;
    *)
        echo "Hmm, an invalid option was received. -a, -r and -p require an argument."
        return
        ;;
        esac
done


	#if application name is not specified
	if [ -z $APP ] 
	then
		echo "*****FATAL ERROR*****"
		echo "Application name is mandatory."
		exit
	fi

	#if sql file name is specified, use it to import to the new database
	if [ ! -z $SQL ]
	then
		##if release name is also specified
		if [ ! -z $RELEASENAME ] 
		then
			echo "*****WARNING*****"
			echo "You cannot specify both -s and -r flags. Remove the -r flag and try."
			exit	
		fi
	fi


	##if release name is not specified
	if [ -z $RELEASENAME ] 
	then
		NEWDBNAME=${APP}
	else
		NEWDBNAME=${APP}_${RELEASENAME}
	fi


	###if new db user password is not specified
	if [ -z $NEWDBPASS ] 
	then
		NEWDBPASS=$DEFAULTDBPASS
	fi

usage(){
    echo "*****WARNING*****"		
    echo "Usage: $0 -a project-name -r release-name -p new-db-password"
    exit 1
}


is_db_exists(){
    local d=$NEWDBNAME
    /usr/bin/mysql -u "$MYSQLADM" -h "$MYSQLADMIP" -p"$MYSQLADMPASS"  -e "use $d;" 2>/dev/null
    if [ $? -eq 0 ]
    then
	echo "*****FATAL ERROR*****"
        echo "$d database exists. Cannot create a new one."
        exit 2
    fi
}

[ $# -lt 2 ] && usage


is_db_exists $NEWDBNAME


echo "Work in Progress. Please wait...."

	#if the arg for release name is passed
	if [ ! -z $RELEASENAME ] 
	then
		#Export the existing database.
		mysqldump $APP > "${CURDIR} ${APP}.sql" -u "$MYSQLADM" -p"$MYSQLADMPASS"
	fi


	#2) Create the new database and the user, assign the user to the database with full access
	"$MYSQL" -u "$MYSQLADM" -h "$MYSQLADMIP" -p"$MYSQLADMPASS" mysql -e "CREATE DATABASE $NEWDBNAME; GRANT ALL ON  $NEWDBNAME.* TO $NEWDBUSER1@$MYSQLADMIP IDENTIFIED BY '$NEWDBPASS'; GRANT SELECT, UPDATE, DELETE ON  $NEWDBNAME.* TO  $NEWDBUSER2@$MYSQLADMIP IDENTIFIED BY '$NEWDBPASS'"

	
	#if SQL file is specified, import it to the new database.
	if [ ! -z $SQL ]
	then
		mysql "$NEWDBNAME" < "$SQL" -u "$MYSQLADM" -p"$MYSQLADMPASS"
	fi


	#if the arg for release name is passed
	if [ ! -z $RELEASENAME ] 
	then
		#3) Import the current database data to the new database
		mysql "$NEWDBNAME" < "${CURDIR} ${APP}.sql" -u "$MYSQLADM" -p"$MYSQLADMPASS"
	fi






echo "-----------WORK COMPLETED-----------"
echo "New Database Information:"
echo "+ Database Name : $NEWDBNAME"
echo "+ Username1 (ALL Privileges) : $NEWDBUSER1"
echo "+ Username2  (Limited Privileges) : $NEWDBUSER2"
echo "+ Database Password : $NEWDBPASS"

