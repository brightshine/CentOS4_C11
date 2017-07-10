#FROM brightshine/centos4-64:latest
FROM fatherlinux/centos4-base:latest
MAINTAINER Daniel Hsieh <brightshine.hsieh@gmail.com>

# Make sure the package repository is up to date.
RUN sed -ri -e 's/^mirrorlist/#mirrorlist/g' -e 's/#baseurl=http:\/\/mirror\.centos\.org\/centos\/\$releasever/baseurl=http:\/\/vault\.centos\.org\/4\.9/g' /etc/yum.repos.d/CentOS-Base.repo
RUN yum remove -y freetype gd ghostscript gnupg httpd httpd-manual httpd-suexec iptables net-snmp-libs nss_ldap numactl openldap pango php php-ldap php-pear samba samba-client samba-common sendmail xorg-x11-Mesa-libGL xorg-x11-font-utils xorg-x11-libs xorg-x11-xauth xorg-x11-xfs libvorbis libpng cups foomatic

RUN yum update -y && yum install -y gcc4-c++.x86_64
RUN unlink /usr/bin/cc && ln -s /usr/bin/gcc4 /usr/bin/cc && rm -f /usr/bin/c++ && ln -s /usr/bin/g++4 /usr/bin/c++
COPY ipmi.h ipmi_msgdefs.h /usr/include/linux/

RUN cd /tmp && wget -c ftp://ftp.gnu.org/gnu/ncurses/ncurses-6.0.tar.gz && tar -zxf ncurses-6.0.tar.gz && cd ncurses-6.0 && ./configure && make -j20 && make install
RUN cd /tmp && wget -c --no-check-certificate https://cmake.org/files/v3.6/cmake-3.6.3.tar.gz && tar -zxf cmake-3.6.3.tar.gz && cd cmake-3.6.3 && export LD_LIBRARY_PATH=/usr/local/lib64 && ./bootstrap --parallel=20 && make -j20 cmake ccmake cpack ctest install/strip

RUN cd /tmp && wget -c ftp://ftp.yzu.edu.tw/gnu/gcc/gcc-4.8.5/gcc-4.8.5.tar.bz2 && tar -jxf gcc-4.8.5.tar.bz2 && cd gcc-4.8.5 && contrib/download_prerequisites && mkdir BUILD && cd BUILD && ../configure --enable-checking=release --enable-languages=c,c++ --disable-multilib --disable-libsantizer --disable-libcilkrts && make -j20 && make install

RUN rm -f /usr/bin/cc /usr/bin/c++ && ln -s /usr/local/bin/gcc /usr/bin/cc && ln -s /usr/local/bin/c++ /usr/bin/c++ 
RUN rm -rf /tmp/ncurses-6.0 /tmp/*.tar.gz /tmp/*.tar.bz && yum clean all && cd /tmp && find ./ -type f | xargs rm -rf

