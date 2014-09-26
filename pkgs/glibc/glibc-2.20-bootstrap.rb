name 'glibc'
version '2.20'
type 'development'
extra_version 'bootstrap_amd64'
source_sha256 '4930b2886309112c00a279483eaef2f0f8e1b1b62010e0239c16b22af7c346d4'
source_url 'http://mirror.tochlab.net/pub/gnu/libc/glibc-2.20.tar.xz'
buildDirectory 'build'
bootstrap 1

build do
    #preBuild " export TEST=\"hello\"
    #    export
    #    "
#
#
#
#
#
#
#--prefix=/usr
#--libdir=/usr/lib32
#--mandir=/usr/share/man
#--infodir=/usr/share/info
#--libexecdir=/usr/lib32/misc/glibc
#--with-bugurl=http://bugs.gentoo.org/
#--with-pkgversion=Gentoo 2.19-r1 p3
#--enable-obsolete-rpc
#--disable-systemtap
#
    configPhase "../configure --prefix=#{out} --with-headers=/usr/include --build=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu --enable-kernel=2.6.32 --disable-profile libc_cv_forced_unwind=yes libc_cv_ctors_header=yes libc_cv_c_cleanup=yes"
    buildPhase "make"
    installPhase "make install"
end
