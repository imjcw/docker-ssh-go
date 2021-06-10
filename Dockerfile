# 指定创建的基础镜像
FROM ubuntu:20.04

# 替换阿里云的源
RUN echo '' > /etc/apt/sources.list; \
    { \
        echo 'deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse'; \
	echo 'deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse'; \
	echo 'deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse'; \
	echo 'deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse'; \
	echo 'deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse'; \
	echo 'deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse'; \
	echo 'deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse'; \
	echo 'deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse'; \
	echo 'deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse'; \
	echo 'deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse'; \
    } | tee /etc/apt/sources.list; \
    apt update; \
    apt install -y tzdata make gcc; \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    apt install -y openssh-server git; \
    sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config; \
    echo "root:1" | chpasswd; \
    cd /root; \
    mkdir .ssh;

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.16.3

RUN cd /tmp; \
    wget -c https://golang.google.cn/dl/go1.16.3.linux-amd64.tar.gz -O go.tar.gz; \
    tar -xz -C /usr/local -f go.tar.gz; \
    rm -rf go.tar.gz; \
    go version;

ENV GOPATH /root/go
ENV PATH $GOPATH/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"; \
    echo "PATH=/root/go/bin:/usr/local/go/bin:$PATH" >> /root/.bashrc;

RUN go get github.com/uudashr/gopkgs/v2/cmd/gopkgs; \
    go get github.com/ramya-rao-a/go-outline; \
    go get github.com/cweill/gotests/gotests; \
    go get github.com/fatih/gomodifytags; \
    go get github.com/josharian/impl; \
    go get github.com/haya14busa/goplay/cmd/goplay; \
    go get github.com/go-delve/delve/cmd/dlv; \
    go get honnef.co/go/tools/cmd/staticcheck; \
    go get golang.org/x/tools/gopls;

# RUN go get github.com/beego/bee/v2; \
#     go get github.com/beego/beego/v2; \
#     go get github.com/beego/beego/v2/core/validation; \
#     go get github.com/beego/beego/v2/client/orm; \
#     go get github.com/gin-gonic/gin;

RUN go env -w GO111MODULE="on"; \
    go env -w GOPROXY=https://goproxy.cn,direct;

WORKDIR $GOPATH

# 开放22端口
EXPOSE 22

RUN touch /docker-entrypoint; \
    {\
        echo '#!/usr/bin/env sh'; \
	echo ''; \
	echo '/etc/init.d/ssh start -D'; \
    } | tee /docker-entrypoint; \
    chmod +x /docker-entrypoint

RUN echo 'AuthorizedKeysFile .ssh/authorized_keys' >> /etc/ssh/sshd_config;

ENTRYPOINT ["/docker-entrypoint"]
