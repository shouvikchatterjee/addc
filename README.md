Automated Database Deployment Console (ADDC)
====


This small interactive program simplifies the MySql database setup task seamlessly. The best part is that it can also be run via  continuous integration servers like Jenkins, TeamCity etc.

<hr>

# How To use this program #

Using ADDC is very easy. Invoke it from the prompt of your command interpreter as follows: 

<code>sudo sh addc.sh -a project_name</code>
OR
<code>sudo sh addc.sh -a project_name -r release_name -p your_password</code>

Supported flags:

    [-a] Application/project name.
    [-s] Sql source file with path. Used when creating a fresh database.
    [-r] Release name.
    [-p] Password of the new database. Leaving blank will generate the default password.
    [-h] Displays the help

![Screenshot](http://shouvik.net/images/addc/01.png)

To see this in action, we will create a new database, named magento and import an SQL file (
magento_db.sql) to it. The SQL file should contain the db schema and may contain data. Skipping the -s flag will create an empty database. Enter the following command:


<code>sudo sh 'addc.sh' -a magento -s 'magento_db.sql' -p 'Ks#gg@7b'</code>

Hitting the Enter key will execute the above command. Notice the password is quoted in single quotes. The quotes are required if the password contains special chars.
![Screenshot](http://shouvik.net/images/addc/02.jpeg)
![Screenshot](http://shouvik.net/images/addc/03.jpeg)

What just happened?

* ADDC created a fresh database.
* Imported the SQL file to it.

* Created 2 users with the password Ks#gg@7b
    a) magento_user (with full permission). We use this user to login to phpMyAdmin to make changes.
    b) magento_appuser (with only SELECT, UPDATE, DELETE permissions). We use this user in our application for security purpose.
* Assigned these 2 users to the magento database.
* Displayed us the New Database information.

Next, we will see how to clone an existing database. We will create a clone of the magento database along with its data for a UAT (User Acceptance Testing) release, named "uat1". Enter the following command:


<code>sudo sh 'addc.sh' -a magento -r uat1</code>

Hitting the Enter key will execute the above command. Note that we are not supplying the -p flag which as a result will generate  a pre-set password.
 

![Screenshot](http://shouvik.net/images/addc/04.jpeg)
![Screenshot](http://shouvik.net/images/addc/05.jpeg)

What just happened?

* ADDC created a clone of the existing database magento and named it magento_uat1
* Assigned the existing 2 users (magento_user and magento_appuser) to the magento_uat1 database with the password Monsoon12345
* Displayed us the New Database information.

