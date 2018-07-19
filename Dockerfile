#FROM brightshine/centos4-64:latest
FROM fatherlinux/centos4-base:latest
MAINTAINER Daniel Hsieh <brightshine.hsieh@gmail.com>

# Make sure the package repository is up to date.
RUN sed -ri -e 's/^mirrorlist/#mirrorlist/g' -e 's/#baseurl=http:\/\/mirror\.centos\.org\/centos\/\$releasever/baseurl=http:\/\/vault\.centos\.org\/4\.9/g' /etc/yum.repos.d/CentOS-Base.repo
RUN yum remove -y freetype gd ghostscript gnupg httpd httpd-manual httpd-suexec iptables net-snmp-libs nss_ldap numactl openldap pango php php-ldap php-pear samba samba-client samba-common sendmail xorg-x11-Mesa-libGL xorg-x11-font-utils xorg-x11-libs xorg-x11-xauth xorg-x11-xfs libvorbis libpng cups foomatic krb5-workstation

RUN yum update -y glibc libgcc libstdc++ centos-release coreutils && yum install -y gcc4-c++.x86_64 zlib-devel.x86_64
RUN unlink /usr/bin/cc && ln -s /usr/bin/gcc4 /usr/bin/cc && rm -f /usr/bin/c++ && ln -s /usr/bin/g++4 /usr/bin/c++
COPY ipmi.h ipmi_msgdefs.h /usr/include/linux/
#base image done

ENV NRPOC 12

ENV MAKE_VERSION 4.2
RUN cd /tmp; \
    wget -q -c http://ftp.gnu.org/gnu/make/make-$MAKE_VERSION.tar.gz; \
    tar -zxf make-$MAKE_VERSION.tar.gz; \
    cd make-$MAKE_VERSION; \ 
    ./configure; \
    make -j ${NRPOC}; \ 
    make install;

RUN yum remove -y make && ln -s /usr/local/bin/make /usr/bin/make

ENV NCURSES_VERSION 6.1
RUN cd /tmp; \
    wget -q -c ftp://ftp.gnu.org/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz; \
    tar -zxf ncurses-${NCURSES_VERSION}.tar.gz; \ 
    cd ncurses-${NCURSES_VERSION}; \ 
    ./configure; \
    make -j ${NRPOC}; \
    make install;

ENV CMAKE_VERSION 3.6.3
RUN cd /tmp; \
    wget -q -c --no-check-certificate https://cmake.org/files/v3.6/cmake-${CMAKE_VERSION}.tar.gz; \
    tar -zxf cmake-${CMAKE_VERSION}.tar.gz; \
    cd cmake-${CMAKE_VERSION}; \
    export LD_LIBRARY_PATH=/usr/local/lib64; \
    ./bootstrap --parallel=${NRPOC}; \
    make -j ${NRPOC} cmake ccmake cpack ctest install/strip;

ENV GCC_VERSION 4.8.5
RUN cd /tmp; \
    wget -q -c ftp://ftp.yzu.edu.tw/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.bz2; \
    tar -jxf gcc-${GCC_VERSION}.tar.bz2; \
    cd gcc-${GCC_VERSION}; \
    contrib/download_prerequisites; \
    mkdir BUILD; \ 
    cd BUILD; \
    ../configure --build=x86_64-linux-gnu --enable-checking=release --enable-languages=c,c++ --disable-multilib --disable-libsantizer --disable-libcilkrts; \
    make -j ${NRPOC}; \
    make install-strip;

RUN rm -f /usr/bin/cc /usr/bin/c++ && ln -s /usr/local/bin/gcc /usr/bin/cc && ln -s /usr/local/bin/c++ /usr/bin/c++ 
RUN rm -rf /tmp/ncurses-6.0 /tmp/*.tar.gz /tmp/*.tar.bz && yum clean all && cd /tmp && find ./ -type f | xargs rm -rf && rm -rf /tmp/gcc-${GCC_VERSION}/*

RUN cp -f /usr/share/zoneinfo/Asia/Taipei /etc/localtime

