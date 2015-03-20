FROM markvnext/mono-git

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV DNX_USER_HOME /opt/dnx

RUN apt-get -qq update && apt-get -qqy install \
    curl \
    unzip \
    autoconf \
    automake \
    build-essential \
    libtool \
    && rm -rf /var/lib/{apt,dpkg}/ \
    && mozroots --machine --import --sync --quiet

# Install libuv for Kestrel from source code (binary is not in wheezy and one in jessie is still too old)
RUN LIBUV_VERSION=1.4.1 \
    && curl -sSL https://github.com/libuv/libuv/archive/v${LIBUV_VERSION}.tar.gz | tar zxfv - -C /usr/local/src \
    && cd /usr/local/src/libuv-$LIBUV_VERSION \
    && sh autogen.sh && ./configure && make && make install \
    && cd / \
    && rm -rf /usr/local/src/libuv-$LIBUV_VERSION \
    && ldconfig


RUN mkdir -p /var/run/sshd

RUN curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.sh | DNX_BRANCH=dev sh \
    && source $DNX_USER_HOME/dnvm/dnvm.sh \
    && dnvm install latest -a default \
    && dnvm alias default | xargs -i ln -s $DNX_USER_HOME/runtimes/{} $DNX_USER_HOME/runtimes/default

COPY NuGet.Config /tmp/
RUN mkdir -p $HOME/.config/NuGet/ && mv /tmp/NuGet.Config $HOME/.config/NuGet/

ENV PATH $PATH:$DNX_USER_HOME/runtimes/default/bin