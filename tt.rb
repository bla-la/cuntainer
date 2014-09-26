
def  configArgs
out="/opt"
  "--prefix=#{out} --with-newlib --without-headers
  --with-local-prefix=/tools --with-native-system-header-dir=/tools/include
  --disable-nls --disable-shared --disable-multilib --disable-decimal-float
  --disable-threads --disable-libatomic --disable-libgomp --disable-libitm
  --disable-libquadmath --disable-libsanitizer
  --disable-libssp --disable-libvtv --disable-libcilkrts
  --disable-libstdc++-v3 --enable-languages=c,c++".gsub /[\s\t]*\n/, ' '
end



puts "hh: #{configArgs}"
