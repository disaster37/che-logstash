
FROM quay.io/webcenter/che-ubi:latest

ENV \ 
    HADOLINT_VERSION="v2.6.0" \
    LOGSTASH_VERSION="1:7.5.1-1" \
    LOGSTASH_FILTER_VERIFIER_VERSION="1.6.3" \
    KUBECTL_VERSION="v1.18.20" \
    RANCHER_VERSION="v2.4.6" \
    BUILDKIT_VERSION="0.1.3" \
    LS_JAVA_OPTS="-Dls.cgroup.cpuacct.path.override=/ -Dls.cgroup.cpu.path.override=/" \
    PATH=$PATH:/usr/share/logstash/bin


# Install some cli
RUN \
    echo "Install hadolint" &&\
    curl -L https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64 -o /usr/bin/hadolint &&\
    chmod +x /usr/bin/hadolint &&\
    echo "Install logstash-filter-verifier" &&\
    curl -o- -L https://github.com/magnusbaeck/logstash-filter-verifier/releases/download/${LOGSTASH_FILTER_VERIFIER_VERSION}/logstash-filter-verifier_${LOGSTASH_FILTER_VERIFIER_VERSION}_linux_amd64.tar.gz | tar xvz -C /usr/local/bin --strip-components=1 &&\
    chmod +x /usr/local/bin/logstash-filter-verifier &&\
    echo "Install kubectl" &&\
    curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl &&\
    chmod +x /usr/bin/kubectl &&\
    echo "Install rancher" &&\
    curl -o- -L https://github.com/rancher/cli/releases/download/${RANCHER_VERSION}/rancher-linux-amd64-${RANCHER_VERSION}.tar.gz | tar xvz -C /usr/local/bin --strip-components=2 &&\
    chmod +x /usr/local/bin/rancher &&\
    echo " Install buildkit for kubectl" &&\
    rpm -i https://github.com/vmware-tanzu/buildkit-cli-for-kubectl/releases/download/v${BUILDKIT_VERSION}/kubectl-buildkit-${BUILDKIT_VERSION}-1.el7.x86_64.rpm

# Tempory fix kubectl-buildkit
COPY root/ /
RUN chmod +x /usr/bin/kubectl-*


# Install Logstash and somme tools
COPY root/ /
RUN \
    rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch &&\
    rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    microdnf install -y java-11-openjdk-headless logstash-${LOGSTASH_VERSION} diffutils yamllint python3 pylint



# Clean
RUN \
    microdnf clean all && \
    rm -rf /tmp/* /var/tmp/*

SHELL ["/bin/bash", "-c"]