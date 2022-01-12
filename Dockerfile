FROM alpine
EXPOSE 53/tcp 53/udp
ARG NEXTDNS_VERSION
ARG TARGETARCH
ARG TARGETPLATFORM

RUN case ${TARGETPLATFORM} in \
      "linux/arm/v7") TARGETARCH=armv7 ;; \
      "linux/arm/v6") TARGETARCH=armv6 ;; \
    esac \
    && wget -O /tmp/nextdns.tar.gz https://github.com/nextdns/nextdns/releases/download/v${NEXTDNS_VERSION}/nextdns_${NEXTDNS_VERSION}_linux_$TARGETARCH.tar.gz \
    && tar xf /tmp/nextdns.tar.gz -C /usr/bin nextdns \
    && rm /tmp/nextdns.tar.gz \
    && apk --no-cache add bind-tools

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
