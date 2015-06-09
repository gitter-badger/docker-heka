FROM golang:1.4

RUN apt-get update && apt-get install -y \
            cmake python-sphinx protobuf-compiler patch \
            --no-install-recommends \
        && rm -rf /var/lib/apt/lists/*

ENV HEKA_VERSION 0.9.2

COPY plugin_loader.cmake /tmp/plugin_loader.cmake

RUN git clone https://github.com/mozilla-services/heka --depth=1 --branch=v$HEKA_VERSION /usr/src/heka \
    && mv /tmp/plugin_loader.cmake /usr/src/heka/cmake \
    && cd /usr/src/heka/ && ./build.sh 2>&1 \
    && mv /usr/src/heka/build/heka/bin/* /usr/local/bin \
    && mv /usr/src/heka/build/heka/include/* /usr/local/include \
    && mv /usr/src/heka/build/heka/lib/* /usr/local/lib \
    && mkdir -p /usr/share/heka/lua_decoders \
    && mkdir -p /usr/share/heka/lua_encoders \
    && mkdir -p /usr/share/heka/lua_filters \
    && mkdir -p /usr/share/heka/lua_modules \
    && mkdir -p /usr/share/heka/dasher \
    && cp /usr/src/heka/sandbox/lua/decoders/* /usr/share/heka/lua_decoders \
    && cp /usr/src/heka/sandbox/lua/encoders/* /usr/share/heka/lua_encoders \
    && cp /usr/src/heka/sandbox/lua/filters/* /usr/share/heka/lua_filters \
    && cp /usr/src/heka/sandbox/lua/modules/* /usr/share/heka/lua_modules \
    && cp /usr/src/heka/build/heka/modules/*.lua /usr/share/heka/lua_modules \
    && cp -r /usr/src/heka/dasher/* /usr/share/heka/dasher \
    && rm -rf /usr/src/heka

COPY dashboard.toml /etc/heka.d/

EXPOSE 4352

CMD ["hekad", "--config", "/etc/heka.d"]