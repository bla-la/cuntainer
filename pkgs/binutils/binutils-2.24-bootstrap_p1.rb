name 'binutils'
version '2.24'
type 'development'
extra_version 'bootstrap_amd64_p1'
source_sha256 '4930b2886309112c00a279483eaef2f0f8e1b1b62010e0239c16b22af7c346d4'
source_url 'http://mirror.tochlab.net/pub/gnu/binutils/binutils-2.24.tar.gz'
bootstrap 1

build do
    #preBuild " export TEST=\"hello\"
    #    export
    #    "

    configPhase "./configure --prefix=#{tool_dir} --target=x86_64-linux-gnu --with-lib-path=/tools/lib --disable-nls --disable-werror"
    buildPhase "make -j4"
    installPhase "make DESTDIR=#{out} install"
end
