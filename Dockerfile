
FROM quay.io/webcenter/che-ubi:latest

ENV \ 
    HADOLINT_VERSION="v2.6.0" \
    LOGSTASH_VERSION="1:7.5.1-1" \
    LOGSTASH_FILTER_VERIFIER_VERSION="1.6.3" \
    LS_JAVA_OPTS="-Dls.cgroup.cpuacct.path.override=/ -Dls.cgroup.cpu.path.override=/" \
    PATH=$PATH:/usr/share/logstash/bin


# Install some cli
RUN \
    echo "Install hadolint" &&\
    curl -L https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64 -o /usr/bin/hadolint &&\
    chmod +x /usr/bin/hadolint &&\
    echo "Install logstash-filter-verifier" &&\
    curl -o- -L https://github.com/magnusbaeck/logstash-filter-verifier/releases/download/${LOGSTASH_FILTER_VERIFIER_VERSION}/logstash-filter-verifier_${LOGSTASH_FILTER_VERIFIER_VERSION}_linux_amd64.tar.gz | tar xvz -C /usr/local/bin --strip-components=1 &&\
    chmod +x /usr/local/bin/logstash-filter-verifier

# Install Logstash
COPY root/ /
RUN \
    rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch &&\
    microdnf install -y java-11-openjdk-headless logstash-${LOGSTASH_VERSION} diffutils



# Clean
RUN \
    microdnf clean all && \
    rm -rf /tmp/* /var/tmp/*

SHELL ["/bin/bash", "-c"]