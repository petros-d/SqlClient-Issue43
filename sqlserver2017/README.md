# SQL Server on Windows container

This section can be ignored as I could not replicate the issue when running SQL Server in a Windows container.

Run Windows container with SQL Server 2017:

 docker run -d -p 1433:1433 -e sa_password=TempPass123 -e ACCEPT_EULA=Y --name test-host.example.local --hostname test-host.example.local microsoft/mssql-server-windows-developer

Create custom Docker image with database and user created and certificate imported into Windows.

 docker build --isolation=hyperv -t sqlserver2017 .

Run cusom docker image with set hostname (needed as certificate must match hostname):
 docker run -d -p 1433:1433 -e sa_password=TempPass123 -e ACCEPT_EULA=Y --name test-host.example.local --hostname test-host.example.local --isolation=hyperv sqlserver2017

Get name of Docker container and exec into it using sqlcmd:
 docker exec -it ((docker ps -a | sls "mssql-server-windows-developer") -split " +")[-1] sqlcmd

Not needed when setting the hostname:
 docker exec -it test-host.example.local powershell

Create database and user for testing:
```
CREATE DATABASE TestDB;
GO
CREATE LOGIN test_user WITH PASSWORD = 'test_pass123';
USE TestDB
CREATE USER test_user FOR LOGIN test_user;
EXEC sp_addrolemember 'db_owner', 'test_user';
GO
```
Import certificate into Windows:
 $Password= ConvertTo-SecureString cert-pass123 -asplaintext -force
 Import-PfxCertificate -FilePath C:\test-host.example.local-cert.pfx -CertStoreLocation Cert:\LocalMachine\My -Password $Password

#### Confirm private key exists and get thumbprint
$thumb = dir cert:\localmachine\my | Where-Object { $_.hasPrivateKey -and $_.Subject -clike "CN=DESKTOP*"} | select Thumbprint

#### Grant permissions to SQL Server service account to the private key, required for MSSQLSERVER to use the cert
.\AddUserToCertificate.ps1 -userName 'MSSQL$SQLEXPRESS' -permission fullcontrol -certStoreLocation \LocalMachine\My -certThumbprint $thumb.Thumbprint





