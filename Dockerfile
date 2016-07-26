FROM ubuntu:15.04
MAINTAINER Octoblu <docker@octoblu.com>

RUN apt-get update && \
    apt-get install -y awscli jq && \
    rm -rf /var/lib/apt/lists/*

COPY run.sh run.sh

CMD ["./run.sh"]
