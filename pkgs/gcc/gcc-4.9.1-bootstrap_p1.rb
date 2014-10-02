name 'gcc'
version '4.9.1'
type 'development'
extra_version 'bootstrap_amd64_p1'
source_sha256 '4930b2886309112c00a279483eaef2f0f8e1b1b62010e0239c16b22af7c346d4'
source_url 'http://mirror.tochlab.net/pub/gnu/gcc/gcc-4.9.1/gcc-4.9.1.tar.bz2'
buildDirectory 'build'
requireOnBuild 'binutils/binutils-2.24-bootstrap_p1'
requireOnRun 'binutils/binutils-2.24-bootstrap_p1'
#requireOnRun 'bar'
addPath '/tool/bin/'

bootstrap 1





build do
    #preBuild " export TEST=\"hello\"
    #    export
    #    "

  def  configArgs
    "--prefix=#{tool_dir} --target=x86_64-linux-gnu
  --with-newlib --without-headers
  --with-local-prefix=/tools
  --disable-nls --disable-shared --disable-multilib --disable-decimal-float
  --disable-threads --disable-libatomic --disable-libgomp --disable-libitm
  --disable-libquadmath --disable-libsanitizer
  --disable-libssp --disable-libvtv --disable-libcilkrts
  --disable-libstdc++-v3 --enable-languages=c,c++".gsub /[\s\t]*\n/, ' '
  end

  puts configArgs
#  configPhase "bash"

  exec "scripts/tool_p1_fix.sh"
  configPhase "../configure #{configArgs}"
  buildPhase "make"
  installPhase "make DESTDIR=#{out} install"
end
