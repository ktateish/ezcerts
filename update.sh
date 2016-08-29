#!/bin/sh

go get github.com/cloudflare/cfssl/cmd/cfssl
go get github.com/cloudflare/cfssl/cmd/cfssljson
go build fmt.go

exec > Makefile

cat << 'EOM'
.PHONY: all allcerts allnodes allclients clean cleanall

all: allcerts

ca/ca.csr: config/ca-csr.json
	mkdir -p ca
	cfssl gencert --initca config/ca-csr.json | cfssljson --bare ca/ca

EOM

for target in node client
do
	./fmt < ${target}.list | while read entry hostnames
	do
		cat << EOM
${target}/${entry}.csr: config/${target}-csr.json
	mkdir -p ${target}
	cfssl gencert --ca ca/ca.pem --ca-key ca/ca-key.pem \
		--config config/ca-config.json \
		--hostname localhost,127.0.0.1,${hostnames} \
		config/${target}-csr.json | cfssljson --bare ${target}/${entry}
	chmod 0600 ${target}/${entry}-key.pem
	chmod 0644 ${target}/${entry}.csr ${target}/${entry}.pem

EOM
	done
	cat << EOM
all${target}s: $(echo $(awk '/^[^ \t]/ {print $1}' < ${target}.list | \
	sed -e "s,^,${target}/," -e 's/$/.csr/'))

EOM
done

cat << EOM

allcerts: ca/ca.csr allnodes allclients

clean:
	rm -rf node client

cleanall: clean
	rm -rf ca

EOM

