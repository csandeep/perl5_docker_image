FROM alpine:3.6
MAINTAINER csandeep <csandeep@gmail.com>

RUN apk update && apk upgrade && apk add curl tar make gcc build-base wget gnupg libev libev-dev mariadb-dev mariadb-client mariadb-libs mysql-client bash

RUN mkdir -p /usr/src/perl

WORKDIR /usr/src/perl

## from perl; `true make test_harness` because 3 tests fail
## some flags from http://git.alpinelinux.org/cgit/aports/tree/main/perl/APKBUILD?id=19b23f225d6e4f25330e13144c7bf6c01e624656
RUN curl -SLO http://www.cpan.org/src/5.0/perl-5.26.1.tar.gz \
    && tar --strip-components=1 -xzf perl-5.26.1.tar.gz -C /usr/src/perl \
    && rm perl-5.26.1.tar.gz \
    && ./Configure -des \
        -Duse64bitall \
        -Dcccdlflags='-fPIC' \
        -Dcccdlflags='-fPIC' \
        -Dccdlflags='-rdynamic' \
        -Dlocincpth=' ' \
        -Duselargefiles \
        -Dusethreads \
        -Duseshrplib \
        -Dd_semctl_semun \
        -Dusenm \
    && make libperl.so \
    && make -j$(nproc) \
    && TEST_JOBS=$(nproc) true make test_harness \
    && make install \
    && curl -LO https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm \
    && chmod +x cpanm \
    && ./cpanm App::cpanminus \
	&& ./cpanm Carton \
    && rm -fr ./cpanm /root/.cpanm /usr/src/perl \
	&& rm -rf /var/cache/apk/*

## from tianon/perl
ENV PERL_CPANM_OPT --verbose --mirror https://cpan.metacpan.org --mirror-only
RUN cpanm Digest::SHA Module::Signature && rm -rf ~/.cpanm
ENV PERL_CPANM_OPT $PERL_CPANM_OPT --verify

WORKDIR /
