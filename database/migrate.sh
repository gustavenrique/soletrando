# !/bin/bash

# waiting for the database startup
sleep 25

/opt/mssql-tools/bin/sqlcmd \
    -S ${MSSQL_SERVER} \
    -U ${MSSQL_USER} -P ${MSSQL_PASSWORD} \
    -d master \
    -l 20 \
    -Q "
    IF NOT EXISTS(SELECT TOP 1 1 FROM sys.databases WHERE name = 'soletrando')
    BEGIN
        CREATE DATABASE soletrando
    END
    "

/opt/mssql-tools/bin/sqlcmd \
    -S ${MSSQL_SERVER} \
    -U ${MSSQL_USER} -P ${MSSQL_PASSWORD} \
    -d soletrando \
    -l 20 \
    -i /tmp/soletrando.sql