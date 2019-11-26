# Windows Docker host configuration (could not replicate issue)

This section can be ignored as the issue could not be replicated when running SQL Server in a Windows container.

Issues with Docker on Windows 1903 prevent me from building Docker images, instead a Server 2019 container host is used.

Error when building with Docker on Windows 1903:

 `hcsshim::PrepareLayer - failed failed in Win32: Incorrect function. (0x1)`

https://github.com/microsoft/hcsshim/issues/624
https://github.com/docker/for-win/issues/3884


To prepare a Windows Server 2019 VM as a container server:
```
 Install-WindowsFeature -Name Containers
 Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
 Install-Package -Name docker -ProviderName DockerMsftProvider -Force
 Start-Service docker
 Install-WindowsFeature -Name Hyper-V
 Uninstall-WindowsFeature -Name Windows-Defender
```

### Networking
Assume host IP address is 192.168.0.10, Windows Server 2019 VM is 172.17.201.20

Add the following to the hosts file `C:\Windows\System32\drivers\etc\hosts` on the host:
```
 192.168.0.10 test-host.example.local
```
Port forward SQL Server from host to VM:
```
 netsh interface portproxy add v4tov4 listenport=1433 connectaddress=172.17.201.20 connectport=1433 protocol=tcp
 netsh interface portproxy show all
 netsh interface portproxy delete  v4tov4 listenport=1433
```