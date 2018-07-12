FROM debian:stretch-slim

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

ADD install-go /tmp/install-go
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		ca-certificates \
		csh \
		g++ \
		gcc \
		git \
		libc6-dev \
		make \
		pkg-config \
		wget \
	&& rm -rf /var/lib/apt/lists/* ;\
	/tmp/install-go

#TODO: don't use global gopath for user pkgs
RUN set -e ;\
    useradd --create-home --shell /bin/bash user ;\
    echo '[[ -f /ge/default/common/settings.sh ]] \
    && source /ge/default/common/settings.sh' >> /home/user/.bashrc ;\
    echo "export GOPATH=$GOPATH" >> /home/user/.bashrc ;\
    echo 'export PATH="/usr/local/go/bin:$PATH"' >> /home/user/.bashrc ;\
    su --preserve-environment -c"export PATH=$PATH"'; HOME=~user ;\
    go get github.com/lloydkirk/gflow\
       	   github.com/golang/dep/cmd/dep;\
    (cd $GOPATH/src/github.com/lloydkirk/gflow; git checkout v1/6)' user ;\
    git clone https://github.com/gridengine/gridengine /tmp/gridengine

ADD build-ge /tmp/gridengine/source
WORKDIR /tmp/gridengine/source
RUN ./build-ge
ADD install-ge /tmp/gridengine/source
ADD config /ge/config
RUN ./install-ge
WORKDIR /ge

RUN rm -r /tmp/*
ADD docker_entrypoint.sh /docker_entrypoint.sh
ADD gridengine.submit /home/user

ENTRYPOINT ["/docker_entrypoint.sh"]
