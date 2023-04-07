#! /bin/bash

read -p 'IP Address: ' DOMAIN
read -p 'Country: ' COUNTRY
read -p 'State: ' STATE
echo

# Create root CA & Private key

openssl req -x509 \
            -sha256 -days 356 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=${DOMAIN}/C=${COUNTRY}/L=${STATE}" \
            -keyout rootCA.key -out rootCA.crt 

# Generate Private key 

openssl genrsa -out self-signed.key 2048

# Create csr conf

cat > csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = ${COUNTRY}
ST = ${STATE}
L = ${STATE}
O = ${DOMAIN}
OU = ${DOMAIN}
CN = ${DOMAIN}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${DOMAIN}
DNS.2 = www.${DOMAIN}
IP.1 = ${DOMAIN}
IP.2 = ${DOMAIN}

EOF

# create CSR request using private key

openssl req -new -key self-signed.key -out self-signed.csr -config csr.conf

# Create a external config file for the certificate

cat > cert.conf <<EOF

authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN}

EOF

# Create SSl with self signed CA

openssl x509 -req \
    -in self-signed.csr \
    -CA rootCA.crt -CAkey rootCA.key \
    -CAcreateserial -out self-signed.crt \
    -days 365 \
    -sha256 -extfile cert.conf
