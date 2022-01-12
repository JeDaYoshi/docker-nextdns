# NextDNS CLI running on Docker

This is a simple Docker image that allows you to containerize
your [NextDNS CLI](https://github.com/nextdns/nextdns) client.

Tags will be automatically published under matching versions as upstream releases happen.

## Usage

You can pass what you would use with arguments as environment variables to the container.
Make sure to prefix all variables with `NEXTDNS_`, where `NEXTDNS_CONFIG=xxxxxx` would become `-config=xxxxxx` to the CLI.

In addition, in order to support
[Conditional Configuration](https://github.com/nextdns/nextdns/wiki/Conditional-Configuration) and 
[Split Horizon/Conditional Forwarders](https://github.com/nextdns/nextdns/wiki/Split-Horizon),
you can also use `NEXTDNS_CONFIG_$NAME` or `NEXTDNS_FORWARDER_$NAME` to pass additional settings
(where `$NAME` is a personal identifier, and is not passed to the CLI.)

To start it, it's how you would usually do it:

```sh
docker pull jedayoshi/nextdns:latest
docker run -d --name nextdns --restart always -p "53:53/tcp" -p "53:53/udp" --env "NEXTDNS_CONFIG=xxxxxx" --env "NEXTDNS_CACHE_SIZE=10m" --env "NEXTDNS_REPORT_CLIENT_INFO=true" jedayoshi/nextdns:latest"
```

Or, use `docker-compose`! Here's an example:

```yaml
version: "3"

services:
  nextdns:
    container_name: "nextdns"
    image: "jedayoshi/nextdns:latest"
    restart: "always"
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    environment:
      NEXTDNS_CONFIG: "xxxxxx"
      NEXTDNS_CACHE_SIZE: "10m"
      NEXTDNS_REPORT_CLIENT_INFO: "true"
    # Warning: This WILL use your DNS query quota. Since its TTL is 300s,
    # each check will be 1 query against your quota every 5 minutes. Enable carefully.
    #healthcheck:
    #  test: [
    #    "CMD", "sh", "-c",
    #    "dig +time=10 @127.0.0.1 -p $$(echo $${NEXTDNS_LISTEN:-:53} | rev | cut -d: -f1 | rev) probe-test.dns.nextdns.io"
    #  ]
    #  interval: "1m"
    #  timeout: "10s"
    #  retries: 1
    #  start_period: "5s"
```

## Why is `--use-hosts` disabled by default?

Because all what the `/etc/hosts` from the container contains is your usual
stuff plus the container name, and I'd rather avoid conflicts than to risk myself.
However, nothing stops you from using `NEXTDNS_USE_HOSTS=true` and
mounting your `/etc/hosts` from your host system as a volume:

```yaml
version: "3"

services:
  nextdns:
    container_name: "nextdns"
    image: "jedayoshi/nextdns:latest"
    restart: "always"
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    environment:
      NEXTDNS_CONFIG: "xxxxxx"
      NEXTDNS_CONFIG_HOME: "192.168.0.0/24=aaaaaa"
      NEXTDNS_CONFIG_OFFICE: "10.18.0.0/16=wwwwww"
      NEXTDNS_CACHE_SIZE: "10m"
      NEXTDNS_REPORT_CLIENT_INFO: "true"
      NEXTDNS_USE_HOSTS: "true"
    volumes:
      - "/etc/hosts:/etc/hosts:ro"
```

## License

[WTFPL](LICENSE) for the `docker-entrypoint.sh` script, since it's rather minimal.

[NextDNS CLI](https://github.com/nextdns/nextdns) is licensed under the
[MIT License](https://github.com/nextdns/nextdns/blob/master/LICENSE).
