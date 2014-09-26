name 'busybox'
version '1.22.1'
type 'utils'
extra_version 'bootstrap_amd64'
source_sha256 '2d3997f588401ea095a0b27227b1d50cdfdd416236f6567b564549d3b46ea2a2'
source_url 'http://busybox.net/downloads/busybox-1.22.1.tar.bz2'
buildDirectory 'build'
bootstrap 1

build do
    configPhase
"../configure --prefix=#{out} --with-headers=/usr/include --build=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu --enable-kernel=2.6.32 --disable-profile libc_cv_forced_unwind=yes libc_cv_ctors_header=yes libc_cv_c_cleanup=yes"
    buildPhase "make"
    installPhase "make install"
end
