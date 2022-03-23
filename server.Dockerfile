FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends software-properties-common \
    curl wget cmake make pkg-config locales git gcc-10 g++-10 \
    openssl libssl-dev libjsoncpp-dev uuid-dev zlib1g-dev libc-ares-dev\
    postgresql-server-dev-all libmariadbclient-dev libsqlite3-dev libhiredis-dev \
    libboost-all-dev python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    CC=gcc-10 \
    CXX=g++-10 \
    AR=gcc-ar-10 \
    RANLIB=gcc-ranlib-10 \
    IROOT=/install

# Drogon (TODO: use drogonframework/drogon docker image. but currently there is only 1.7.1)
ENV DROGON_ROOT="$IROOT/drogon"
ADD https://api.github.com/repos/an-tao/drogon/git/refs/heads/master $IROOT/version.json
RUN git clone https://github.com/an-tao/drogon $DROGON_ROOT
WORKDIR $DROGON_ROOT
RUN ./build.sh

# Nlohmann (TODO: use a package)
ENV NLOHMANN_ROOT="$IROOT/json/"
RUN git clone https://github.com/nlohmann/json $NLOHMANN_ROOT
WORKDIR $NLOHMANN_ROOT
RUN cmake . -DJSON_BuildTests=OFF && make install

# Cavoke
RUN pip3 install requests

CMD ["/bin/bash"]