#!/bin/bash

WORKDIR="/tmp/k8s_tools"

if [ -d ${WORKDIR} ] ; then
    rm -fr ${WORKDIR} && mkdir -pv ${WORKDIR}
else
    mkdir -pv ${WORKDIR}
fi

cd ${WORKDIR}

curl -fsSL -o ./helm.tar.gz https://get.helm.sh/helm-v3.10.3-linux-amd64.tar.gz
tar xzf ./helm.tar.gz
mv -v ./linux-amd64/helm /usr/local/bin

curl -fsSL -o ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.26.7/k9s_Linux_x86_64.tar.gz
tar xzf ./k9s.tar.gz
mv -v ./k9s /usr/local/bin


curl -fsSL -o ./stern.tar.gz https://github.com/stern/stern/releases/download/v1.22.0/stern_1.22.0_linux_amd64.tar.gz
tar xzf ./stern.tar.gz
mv -v ./stern /usr/local/bin

exit 0
