#Use AutomatedLab (https://github.com/AutomatedLab/AutomatedLab) to build out lab environment

On SQL1:
-   Install TestDB and user (test_db.sql)
-   SSMS > SQL1 > righ-click Properties > Security > SQL Server and Windows Authentication Mode
 

On CA1:
Add-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
Install-AdcsCertificationAuthority -CAType StandaloneRootCA -CACommonName "Example Root CA" -KeyLength 2048 -HashAlgorithm SHA256 -CryptoProviderName  "RSA#Microsoft Software Key Storage Provider" -ValidityPeriod Years -ValidityPeriodUnits 15
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration\Example Root CA" -Name ValidityPeriodUnits -Value 7

certutil -setreg ca\DSConfigDN "CN=Configuration,DC=example,DC=local"
certutil -setreg ca\DSDomainDN "DC=example,DC=local"
Restart-Service CertSvc

# Set CDP and AIA:
# Certification Authority > Example Root CA > right click > Properties > Extensions
# CDP (CRL):  http://sca1.example.local/cdp/<CaName><CRLNameSuffix>.crl > Include in the CDP extension of issued certificates
# AIA: http://sca1.example.local/aia/<CaName><CertificateName>.crt > Include in the AIA extension of issued certificates
# Certification Authority > Revoked Certificates > Properties > Set CRL Publication Interval = 15 Years
# Revoked Certificates > All Tasks > Publish
# Files in C:\Windows\System32\CertSrv\CertEnroll


On SCA1:

certutil -dspublish -f "ca1_Example Root CA.crt" RootCA
certutil -addstore -f root "ca1_Example Root CA.crt"
certutil -addstore -f root "Example Root CA.crl"
Add-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
Install-AdcsCertificationAuthority –CAType EnterpriseSubordinateCA –CACommonName "Example Issuing CA" –KeyLength 2048 –HashAlgorithm SHA256 –CryptoProviderName "RSA#Microsoft Software Key Storage Provider"
Add-WindowsFeature Adcs-Web-Enrollment -IncludeManagementTools

On CA1:
certreq -submit '.\sca1.example.local_Example Issuing CA.req'
certreq -retrieve 2 C:\ExampleIssuingCa.crt

On SCA1:
certutil -installcert C:\ExampleIssuingCa.crt
Restart-Service CertSvc

# IIS Manager > Sites > Add Website > 
    Set "Site Name" to "SCA1", 
        "Physical Path" to "C:\inetpub\wwwroot\PKI\", 
        "Host name" to sca1.example.local"

# IIS Manager > Sites > Sca1 > Edit Permissions > Security > Grant "EXAMPLE\Cert Publishers" Modify permissions

# Place "C:\inetpub\wwwroot\PKI\cdp\Example Root CA.crl" and "C:\inetpub\wwwroot\PKI\aia\ca1_Example Root CA.crt"
