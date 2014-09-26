name 'glibc'
version '2.19'
type 'development'
extra_version 'bootstrap_amd64'
source_sha256 '2d3997f588401ea095a0b27227b1d50cdfdd416236f6567b564549d3b46ea2a2'
source_url 'http://mirror.tochlab.net/pub/gnu/libc/glibc-2.19.tar.xz'
buildDirectory 'build'
bootstrap 1



build do
    #preBuild " export TEST=\"hello\"
    #    export
    #    "
    configPhase "../configure --build=x86"
    buildPhase "make"
    installPhase "make install"
end
