#!/bin/bash

ip=$1
if [ -z "$ip" ]
then
      echo "1st arguement: Cert IP is missing! e.g. 192.168.1.123"
      exit 1
fi


#Create root CA & Private key
openssl req -x509 \
            -sha256 -days 356 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=$ip/C=MY/L=PG" \
            -keyout ./rootCA.key -out ./rootCA.crt

#1. Generate Private key
openssl genrsa -out ./self-signed.key 2048

#2. Create csr conf
cat > csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn
[ dn ]
C = MY
ST = PG
L = PG
O = $ip
OU = $ip
CN = $ip
[ req_ext ]
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = $ip
DNS.2 = www.$ip
IP.1 = $ip
IP.2 = $ip
EOF

#3. create CSR request using private key from step 1
openssl req -new -key self-signed.key -out self-signed.csr -config csr.conf

#4. Create a external config file for the certificate
cat > cert.conf <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $ip
EOF

#5. Create SSl with self signed CA
openssl x509 -req \
    -in self-signed.csr \
    -CA rootCA.crt -CAkey rootCA.key \
    -CAcreateserial -out self-signed.crt \
    -days 365 \
    -sha256 -extfile cert.conf
