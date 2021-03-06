#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2018 Oracle and/or its affiliates. All rights reserved.
#
# Since: May, 2017
# Author: gerald.venzl@oracle.com
# Description: Checks the status of Oracle Database.
# Return codes: 0 = DB is open and ready to use
#               1 = DB is not open
#               2 = Sql Plus execution failed
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

ORACLE_SID="`grep $ORACLE_HOME /etc/oratab | cut -d: -f1`"
OPEN_MODE="READ WRITE"
ORAENV_ASK=NO
source oraenv

# Check Oracle DB status and store it in status
status=`sqlplus -s / as sysdba << EOF
   set heading off;
   set pagesize 0;
   select open_mode from v\\$database;
   exit;
EOF`

# Store return code from SQL*Plus
ret=$?

# SQL Plus execution was successful and database is open
if [ $ret -eq 0 ] && [ "$status" = "READ WRITE" ]; then
   echo "{\"statusCode\": 1 , \"message\": \"Database is in READ WRITE mode.\"}" > $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/DB_INIT
   exit 0;
# Database is not open
elif [ "$status" != "READ WRITE" ]; then
   echo "{\"statusCode\": 2 , \"message\": \"Database Creation is not successful.Please check manually.\"}" > $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/DB_INIT
   exit 1;
# SQL Plus execution failed
else
   exit 2;
fi;
