FROM markvnext/mono

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV DNX_USER_HOME /opt/dnx

RUN apt-get -qq update && apt-get -qqy install \
    unzip \
    supervisor \
    autoconf \
    automake \
    build-essential \
    libtool
    
# Install libuv for Kestrel from source code (binary is not in wheezy and one in jessie is still too old)
RUN LIBUV_VERSION=1.4.1 \
    && curl -sSL https://github.com/libuv/libuv/archive/v${LIBUV_VERSION}.tar.gz | tar zxfv - -C /usr/local/src \
    && cd /usr/local/src/libuv-$LIBUV_VERSION \
    && sh autogen.sh && ./configure && make && make install \
    && cd / \
    && rm -rf /usr/local/src/libuv-$LIBUV_VERSION \
    && ldconfig


RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

RUN curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.sh | DNX_BRANCH=dev sh \
    && source $DNX_USER_HOME/dnvm/dnvm.sh \
    && dnvm upgrade

CMD ["/usr/bin/supervisord"]
