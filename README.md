# EZcerts: Generate certs for multiple nodes

Generating certs are tiring task for multiple nodes in distributed systems.
This set of sciripts generate certs for you.

## Requirements

* The Go Language
* GNU make
* cfssl, cfssljson (will be installed automatically)

## Step 1: Create config for cfssl

* CA needs ca-config.json and ca-csr.json
* ca-config.json can be used the ca-config.json.example as it is
* \*-csr.config shoud be modified for your environment

```bash
$ git clone https://github.com/ktateish/ezcerts.git
$ cd ezcerts/config
$ for i in *.json.example; do cp $i $(basename $i .example); done
$ vi ca-csr.json
# Edit to suit your needs

...

$ cd ..
```

## Step 2: Create config for server nodes and clients

* create entries in node.list for server nodes, in client.list for clients
  * entry syntax:
```
<name of an entry>
<name of another entry>		<alias 1> <alias 2> ...
<name of yet another entry>	<alias 1> <alias 2> ...
				...
        			<alias n>
```
  * An entry at each line
  * you can specifiy aliases sparated with white space
  * entry declaration can be continued next line when started with white space
  * the entry name and all aliases in each entry plus `localhost` and
    `127.0.0.1` are listed as alternative name in generated cert for the entry 

```
$ cp node.list.example node.list
$ cp client.list.example client.list
# Edit them
```

## Step 3: Generate certs

```
# Generate Makefile
$ ./update.sh
# Generate certs with make
$ make
mkdir -p ca
cfssl gencert --initca config/ca-csr.json | cfssljson --bare ca/ca
2016/08/28 11:26:13 [INFO] generating a new CA key and certificate from CSR
2016/08/28 11:26:13 [INFO] generate received request

...

```

* CA cert and key are generated in the directory ca/
* Certs for server nodes are in node/, for clients are in client/
* Check the generated certs
```
$ openssl x509 -in node/node.pem -text -noout
ertificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            08:ce:cb:fe:b8:23:00:c2:65:03:58:ba:75:6c:e9:1a:e5:33:6a:44
    Signature Algorithm: ecdsa-with-SHA384
        Issuer: C=Japan, L=Chiyoda, O=Example.org, CN=Example CA
        Validity
            Not Before: Aug 28 02:27:00 2016 GMT
            Not After : Aug 28 02:27:00 2017 GMT
        Subject: C=Japan, L=Chiyoda, O=Example.org, CN=Example Servers
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (384 bit)
                pub:
                    04:ca:a6:18:3f:dd:e0:86:bf:79:42:15:f4:81:29:
                    81:61:8e:bc:45:7b:b5:17:c1:7b:5e:d1:a3:2f:d2:
                    55:24:5c:27:93:0c:39:15:2f:80:ba:53:cd:72:55:
                    57:6f:ad:85:38:b5:eb:9c:e2:79:f1:75:bf:56:6e:
                    34:46:81:09:9c:13:d9:9a:9c:ed:41:37:30:9e:bc:
                    fc:38:91:14:e9:fd:44:71:6a:e3:c1:a5:a0:b8:a5:
                    34:34:31:f0:34:fc:9c
                ASN1 OID: secp384r1
                NIST CURVE: P-384
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication, TLS Web Client Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                CE:8B:62:59:A7:B2:7D:3A:09:79:02:D8:9D:1C:B6:AB:F3:86:46:23
            X509v3 Authority Key Identifier:
                keyid:89:9C:80:45:84:1C:CC:F7:8D:D0:FC:8C:F5:2E:49:45:66:46:4C:44

            X509v3 Subject Alternative Name:
                DNS:localhost, DNS:etcd, DNS:etcd.example.org, DNS:etcd0, DNS:etcd0.example.org, DNS:etcd1, DNS:etcd1.example.org, DNS:etcd2, DNS:etcd2.example.org, IP Address:127.0.0.1, IP Address:192.168.1.10, IP Address:192.168.1.11, IP Address:192.168.1.12
    Signature Algorithm: ecdsa-with-SHA384
         30:64:02:30:24:26:18:9b:31:ba:5b:75:61:3e:76:9f:83:4a:
         97:b7:8d:c6:cd:ce:69:0c:d5:2c:0c:40:23:16:bd:99:a8:e1:
         f8:10:5f:e9:47:97:18:a0:03:05:8c:09:9b:9c:7b:a7:02:30:
         37:78:29:05:c1:87:6e:8a:96:22:ec:ed:75:5b:8c:bf:3c:ea:
         89:9e:54:7d:15:45:ba:2c:bd:be:fd:42:6f:d3:8b:8f:0c:ba:
         a3:65:00:23:24:80:a8:31:a7:92:7d:4f
```

## Notes

* If you update client.list or node.list, re-do ./update.sh and make
