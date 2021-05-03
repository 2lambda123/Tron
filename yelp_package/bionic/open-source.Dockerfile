FROM ubuntu:bionic

RUN apt-get -q update && \
    DEBIAN_FRONTEND=noninteractive apt-get -q install -y --no-install-recommends \
        coffeescript \
        debhelper \
        devscripts \
        dh-virtualenv \
        dpkg-dev \
        gcc \
        gdebi-core \
        git \
        help2man \
        libffi-dev \
        libgpgme11 \
        libssl-dev \
        libdb5.3-dev \
        libyaml-dev \
        libssl-dev \
        libffi-dev \
        python3.6-dev \
        python3-pip \
        python-tox \
        wget \
    && apt-get -q clean

# Get yarn and node
RUN wget --quiet -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN wget --quiet -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN echo "deb http://deb.nodesource.com/node_10.x bionic main" > /etc/apt/sources.list.d/nodesource.list
RUN apt-get -q update && apt-get -q install -y --no-install-recommends yarn nodejs

RUN pip3 install virtualenv==16.7.7
WORKDIR /work
