FROM debian:stretch-slim

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		ca-certificates \
		csh \
		g++ \
		gcc \
		git \
		libc6-dev \
		make \
		pkg-config \
		wget \
	&& rm -rf /var/lib/apt/lists/*

# ripped from https://github.com/docker-library/golang/blob/2f2f3b620d61f533484f24a568c2ca46e4fda91c/1.9/stretch/Dockerfile
RUN set -eux; \
	\
	GOLANG_VERSION=1.9.3; \
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='\
a4da5f4c07dfda8194c4621611aeb7ceaab98af0b38bfb29e1be2ebb04c3556c' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='\
926d6cd6c21ef3419dca2e5da8d4b74b99592ab1feb5a62a4da244e6333189d2' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='\
065d79964023ccb996e9dbfbf94fc6969d2483fbdeeae6d813f514c5afcd98d9' ;; \
		i386) goRelArch='linux-386'; goRelSha256='\
bc0782ac8116b2244dfe2a04972bbbcd7f1c2da455a768ab47b32864bcd0d49d' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='\
c802194b1af0cd904689923d6d32f3ed68f9d5f81a3e4a82406d9ce9be163681' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='\
85e9a257664f84154e583e0877240822bb2fe4308209f5ff57d80d16e2fb95c5' ;; \
		*) goRelArch='src'; goRelSha256='\
4e3d0ad6e91e02efa77d54e86c8b9e34fbe1cbc2935b6d38784dca93331c47ae'; \
			echo >&2; echo >&2 "\
warning: current architecture ($dpkgArch) does not have a corresponding Go binary release;\
 will be building from source"; echo >&2 ;; \
	esac; \
	\
	url="https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz"; \
	wget --no-verbose -O go.tgz "$url"; \
	echo "${goRelSha256} *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	if [ "$goRelArch" = 'src' ]; then \
		echo >&2; \
		echo >&2 'error: UNIMPLEMENTED'; \
		echo >&2 'TODO install golang-any from jessie-backports for \
GOROOT_BOOTSTRAP (and uninstall after build)'; \
		echo >&2; \
		exit 1; \
	fi; \
	\
	export PATH="/usr/local/go/bin:$PATH"; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg" && chmod -R 777 "$GOPATH"

RUN useradd -ms /bin/bash user

RUN set -e ;\
    go get github.com/lloydkirk/gflow \
       	   github.com/golang/dep/cmd/dep \
	   ;\
    git clone https://github.com/gridengine/gridengine /opt/gridengine


# WORKDIR /usr/share/gridengine

ADD build-ge /opt/gridengine/source
WORKDIR /opt/gridengine/source
RUN ./build-ge

ADD install-ge /opt/gridengine/source
RUN ./install-ge
WORKDIR /ge
# ADD . /opt

# ripped from https://bitbucket.org/deardooley/agave-docker/src/dc81db2504cb6f3f7f52778493040bd4005433f4/test-containers/schedulers/gridengine/?at=master
# ADD gridengine/docker_configuration.conf /usr/share/gridengine/docker_configuration.conf
# ADD gridengine/hostgroup.conf /usr/share/gridengine/hostgroup.conf
# ADD gridengine/debug.queue /usr/share/gridengine/debug.queue

# RUN echo "$(grep "$HOSTNAME" /etc/hosts | awk '{print $1}') docker" >> /etc/hosts && \
#     echo "domain docker" >> /etc/resolv.conf && \
#     ln /var/lib/gridengine/bin/lx-amd64/qmake_sge /var/lib/gridengine/bin/lx-amd64/qmake && \
#     ln -s /var/lib/gridengine/utilbin /usr/share/gridengine/utilbin && \
#     ln -s /var/lib/gridengine/bin /usr/share/gridengine/bin && \
#     ./inst_sge -x -m -auto /usr/share/gridengine/docker_configuration.conf && \
#     cd /usr/share/gridengine/default/common && \
#     . /usr/share/gridengine/default/common/settings.sh && \
#     echo docker > act_qmaster && \
#     qconf -Mhgrp /usr/share/gridengine/hostgroup.conf && \
#     qconf -Aq /usr/share/gridengine/debug.queue && \
#     qconf -Mq /usr/share/gridengine/debug.queue

# RUN echo 'source /usr/share/gridengine/default/common/settings.sh' >> /home/user/.bashrc

# ADD gridengine/gridengine.submit /home/user/gridengine.submit
# ADD docker_entrypoint.sh /docker_entrypoint.sh
# RUN chmod +x /docker_entrypoint.sh
# RUN chown user:user /home/user/gridengine.submit

# ENTRYPOINT ["/docker_entrypoint.sh"]
