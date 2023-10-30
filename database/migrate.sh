# !/bin/bash

# waiting for the database startup
sleep 20

/opt/mssql-tools/bin/sqlcmd \
    -S db-soletrando \
    -U sa -P sqlserver2023! \
    -d master \
    -l 20 \
    -Q "
    IF NOT EXISTS(SELECT TOP 1 1 FROM sys.databases WHERE name = 'soletrando')
    BEGIN
        CREATE DATABASE soletrando
    END
    "

/opt/mssql-tools/bin/sqlcmd \
    -S db-soletrando \
    -U sa -P sqlserver2023! \
    -d soletrando \
    -l 20 \
    -i /tmp/soletrando.sql