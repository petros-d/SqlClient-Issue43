# PKI

The issue with SqlClient seems to be related to certificates with a CRL definied. To reproduce, I followed the steps below to create a certificate that SQL Server can use, with the CRL set to `http://doesnotexist.example.local/crl.pem` (set in `openssl.conf`).

Command were run in WSL.

PKI based on https://github.com/kaarolch/pki-openssl-example.

## Process to create cert:

 openssl genrsa -aes256 -passout pass:ca-pass123 -out private/ca-key.pem 4096
 openssl req -config openssl.conf -key private/ca-key.pem -passin pass:ca-pass123  -new -x509 -days 3650 -sha256 -extensions v3_ca -out certs/ca.pem

Assuming the SQL Server is installed on a server with the hostname: `DESKTOP-K0D29BB`. CA key is protected with the `ca-pass123` password. Exported .pfx is protected with the `cer-pass123` password.

Replace `DESKTOP-K0D29BB` with your hostname.
```
openssl genrsa -out private/DESKTOP-K0D29BB-key.pem
openssl req -config openssl.conf -key private/DESKTOP-K0D29BB-key.pem  -new -sha256 -out csr/DESKTOP-K0D29BB-csr.pem -subj "/C=GB/ST=London/O=Example PKI/CN=DESKTOP-K0D29BB"
```
```
openssl ca -config openssl.conf -extensions srv_cert -notext -md sha256 -in csr/DESKTOP-K0D29BB-csr.pem -out certs/DESKTOP-K0D29BB-cert.pem
```
```
openssl pkcs12 -export -out certs/DESKTOP-K0D29BB-cert.pfx -passout pass:cert-pass123 -inkey private/DESKTOP-K0D29BB-key.pem -in certs/DESKTOP-K0D29BB-cert.pem -certfile certs/ca.pem
```