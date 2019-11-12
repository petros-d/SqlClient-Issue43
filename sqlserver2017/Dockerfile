FROM microsoft/mssql-server-windows-developer

ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=TempPass123
ENV MSSQL_PID=Developer
ENV MSSQL_TCP_PORT=1433 
        
WORKDIR /
COPY . .

#Does not work yet, start.ps1 need to be run first to set the sa password.
RUN (sqlcmd -S localhost -U sa -P TempPass123 -i test_db.sql)