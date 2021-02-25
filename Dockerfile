FROM mcr.microsoft.com/mssql/rhel/server:2019-CU1-rhel-8

# Configure the required environmental variables
ENV ACCEPT_EULA=Y \
    SA_PASSWORD=Sql2019isfast \
    MSSQL_PID=Developer \
    MSSQL_TCP_PORT=1433 \
    PATH=${PATH}:/opt/mssql/bin:/var/backups

# Labels for container
LABEL name="mcr.microsoft.com/mssql/rhel/server" \
    edition="Developer" \
    version="15.0" \
    operating_system="RHEL8" \
    environment="test" \
    maintainer="ally"

# change to user root
USER root

# create /var/backups directory and set permissions
RUN mkdir -p -m 755 /var/backups && chgrp -R 0 /var/backups && chown -R mssql:root /var/backups

# wget WideWorldImporters-Full.bak backup because it is too large for github storage
# copy restorewwi.sql to the /var/backups directory
RUN wget --no-clobber --no-hsts https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak -P /var/backups
COPY restorewwi.sql /var/backups

# Default SQL Server TCP/Port
EXPOSE $MSSQL_TCP_PORT

# Launch SQL Server, confirm startup is complete
# Initiate restore of WideWorldImporters database
# Clean up backup files
# Terminate SQL Server
# Change directory permissions
RUN ( /opt/mssql/bin/sqlservr & ) | grep -q "Service Broker manager has started" && \
    /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U SA -P $SA_PASSWORD -i "/var/backups/restorewwi.sql" && \
    rm /var/backups/WideWorldImporters-Full.bak /var/backups/restorewwi.sql  && \
    pkill sqlservr && \
    chmod -R 774 /var/opt/mssql && chown -R mssql:root /var/opt/mssql

USER mssql

# Run SQL Server process
CMD ["/opt/mssql/bin/sqlservr"]