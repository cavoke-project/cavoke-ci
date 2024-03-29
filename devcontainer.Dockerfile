FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -yqq && apt-get install -yqq sudo 

# Cavoke Server
# -------------

RUN apt-get install -yqq --no-install-recommends software-properties-common \
    curl wget cmake make build-essential pkg-config locales git gcc-10 g++-10 \
    openssl libssl-dev libjsoncpp-dev uuid-dev zlib1g-dev libc-ares-dev\
    postgresql-server-dev-all \ 
    libboost-all-dev python3-pip \
    docker.io docker-compose \
    && locale-gen en_US.UTF-8

#  libmariadbclient-dev libsqlite3-dev libhiredis-dev

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
RUN rm -rf $DROGON_ROOT

# Nlohmann (TODO: use a package but with >=3.9.0)
ENV NLOHMANN_ROOT="$IROOT/json/"
RUN git clone https://github.com/nlohmann/json $NLOHMANN_ROOT
WORKDIR $NLOHMANN_ROOT
RUN cmake . -DJSON_BuildTests=OFF && make install
RUN rm -rf $NLOHMANN_ROOT

# JWT-CPP (TODO: use a package)
ENV JWT_ROOT="$IROOT/jwt-cpp/"
RUN git clone https://github.com/Thalhammer/jwt-cpp $JWT_ROOT
WORKDIR $JWT_ROOT
RUN cmake . -DJWT_BUILD_EXAMPLES=OFF && make install
RUN rm -rf $JWT_ROOT

# Cavoke OpenAPI
RUN pip3 install cavoke-openapi-client

# Cavoke Client
# -------------

RUN apt-get install -yqq --no-install-recommends \
    qtbase5-dev qtdeclarative5-dev libqt5networkauth5-dev qtquickcontrols2-5-dev\
    extra-cmake-modules libkf5archive-dev

# Cleanup
# -------
WORKDIR /root
RUN rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
