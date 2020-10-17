#!/bin/bash

cd liblog
$CC -fPIC -std=c++17 -fPIC -I../include -DLIBLOG_LOG_TAG=1006 -c log_event_list.cpp log_event_write.cpp logger_name.cpp logger_read.cpp logger_write.cpp logprint.cpp properties.cpp event_tag_map.cpp
ar rcs liblog.a *.o
#$CC -shared -o ../liblog.so *.o

cd ../base
$CC -fPIC -std=c++17 -I../include -DPAGE_SIZE=4096 -c abi_compatibility.cpp chrono_utils.cpp cmsg.cpp file.cpp liblog_symbols.cpp logging.cpp mapped_file.cpp parsebool.cpp parsenetaddress.cpp process.cpp properties.cpp stringprintf.cpp strings.cpp threads.cpp test_utils.cpp errors_unix.cpp
ar rcs libbase.a *.o
#$CC -shared -o ../libbase.so *.o

if [ "$HOSTTYPE" = arm ] || [ "$HOSTTYPE" = aarch64 ];then
  cd ../zlib
  if [ "$HOSTTYPE" = aarch64 ];then
    CFLAGS="-DARMV8_OS_LINUX -O3 -DADLER32_SIMD_NEON -DCRC32_ARMV8_CRC32 -DINFLATE_CHUNK_READ_64LE"
  elif [ "$HOSTTYPE" = arm ];then
    CFLAGS="-DARMV8_OS_LINUX -O3"
  elif [ "$HOSTTYPE" = i686 ];then
    CFLAGS="-DX86_NOT_WINDOWS -mssse3 -mpclmul -DCRC32_SIMD_SSE42_PCLMUL"
    sources="crc_folding.c fill_window_sse.c"
  elif [ "$HOSTTYPE" = x86_64 ];then
    CFLAGS="-DX86_NOT_WINDOWS -mssse3 -mpclmul -DCRC32_SIMD_SSE42_PCLMUL -DINFLATE_CHUNK_READ_64LE"
    sources="crc_folding.c fill_window_sse.c"
  fi
  $CC -fPIC -I. "$CFLAGS" -c adler32.c compress.c crc32.c deflate.c gzclose.c gzlib.c gzread.c gzwrite.c infback.c inffast.c inflate.c inftrees.c trees.c uncompr.c zutil.c adler32_simd.c cpu_features.c crc32_simd.c ${sources}
  ar rcs libz.a *.o
  #$CC -shared -o ../libz.so *.o
fi

cd ../libsparse
$CC -fPIC -std=c++17 -I../include -I../zlib -c backed_block.cpp output_file.cpp sparse.cpp sparse_crc32.cpp sparse_err.cpp sparse_read.cpp
ar rcs libsparse.a *.o
#$CC -shared -o ../libsparse.so *.o

cd ../ext4_utils
$CC -fPIC -std=c++17 -fno-strict-aliasing -I../include -I../zlib -c ext4_utils.cpp wipe.cpp ext4_sb.cpp
ar rcs libext4_utils.a *.o
#$CC -shared -o ../libext4_utils.so *.o

cd ../crypto
if [ "$HOSTTYPE" = aarch64 ];then
  sources="linux-aarch64/crypto/chacha/chacha-armv8.S linux-aarch64/crypto/fipsmodule/aesv8-armx64.S linux-aarch64/crypto/fipsmodule/armv8-mont.S linux-aarch64/crypto/fipsmodule/ghash-neon-armv8.S linux-aarch64/crypto/fipsmodule/ghashv8-armx64.S linux-aarch64/crypto/fipsmodule/sha1-armv8.S linux-aarch64/crypto/fipsmodule/sha256-armv8.S linux-aarch64/crypto/fipsmodule/sha512-armv8.S linux-aarch64/crypto/fipsmodule/vpaes-armv8.S linux-aarch64/crypto/test/trampoline-armv8.S"
elif [ "$HOSTTYPE" = arm ];then
  sources="linux-arm/crypto/chacha/chacha-armv4.S linux-arm/crypto/fipsmodule/aesv8-armx32.S linux-arm/crypto/fipsmodule/armv4-mont.S linux-arm/crypto/fipsmodule/bsaes-armv7.S linux-arm/crypto/fipsmodule/ghash-armv4.S linux-arm/crypto/fipsmodule/ghashv8-armx32.S linux-arm/crypto/fipsmodule/sha1-armv4-large.S linux-arm/crypto/fipsmodule/sha256-armv4.S linux-arm/crypto/fipsmodule/sha512-armv4.S linux-arm/crypto/fipsmodule/vpaes-armv7.S linux-arm/crypto/test/trampoline-armv4.S src/crypto/curve25519/asm/x25519-asm-arm.S src/crypto/poly1305/poly1305_arm_asm.S"
elif [ "$HOSTTYPE" = i686 ];then
  sources="linux-x86/crypto/chacha/chacha-x86.S linux-x86/crypto/fipsmodule/aesni-x86.S linux-x86/crypto/fipsmodule/bn-586.S linux-x86/crypto/fipsmodule/co-586.S linux-x86/crypto/fipsmodule/ghash-ssse3-x86.S linux-x86/crypto/fipsmodule/ghash-x86.S linux-x86/crypto/fipsmodule/md5-586.S linux-x86/crypto/fipsmodule/sha1-586.S linux-x86/crypto/fipsmodule/sha256-586.S linux-x86/crypto/fipsmodule/sha512-586.S linux-x86/crypto/fipsmodule/vpaes-x86.S linux-x86/crypto/fipsmodule/x86-mont.S linux-x86/crypto/test/trampoline-x86.S"
elif [ "$HOSTTYPE" = x86_64 ];then
  sources="linux-x86_64/crypto/chacha/chacha-x86_64.S linux-x86_64/crypto/cipher_extra/aes128gcmsiv-x86_64.S linux-x86_64/crypto/cipher_extra/chacha20_poly1305_x86_64.S linux-x86_64/crypto/fipsmodule/aesni-gcm-x86_64.S linux-x86_64/crypto/fipsmodule/aesni-x86_64.S linux-x86_64/crypto/fipsmodule/ghash-ssse3-x86_64.S linux-x86_64/crypto/fipsmodule/ghash-x86_64.S linux-x86_64/crypto/fipsmodule/md5-x86_64.S linux-x86_64/crypto/fipsmodule/p256-x86_64-asm.S linux-x86_64/crypto/fipsmodule/p256_beeu-x86_64-asm.S linux-x86_64/crypto/fipsmodule/rdrand-x86_64.S linux-x86_64/crypto/fipsmodule/rsaz-avx2.S linux-x86_64/crypto/fipsmodule/sha1-x86_64.S linux-x86_64/crypto/fipsmodule/sha256-x86_64.S linux-x86_64/crypto/fipsmodule/sha512-x86_64.S linux-x86_64/crypto/fipsmodule/vpaes-x86_64.S linux-x86_64/crypto/fipsmodule/x86_64-mont.S linux-x86_64/crypto/fipsmodule/x86_64-mont5.S linux-x86_64/crypto/test/trampoline-x86_64.S src/crypto/hrss/asm/poly_rq_mul.S"
fi

$CC -fPIC -I. -I../include -c err_data.c\
  src/crypto/asn1/a_bitstr.c\
  src/crypto/asn1/a_bool.c\
  src/crypto/asn1/a_d2i_fp.c\
  src/crypto/asn1/a_dup.c\
  src/crypto/asn1/a_enum.c\
  src/crypto/asn1/a_gentm.c\
  src/crypto/asn1/a_i2d_fp.c\
  src/crypto/asn1/a_int.c\
  src/crypto/asn1/a_mbstr.c\
  src/crypto/asn1/a_object.c\
  src/crypto/asn1/a_octet.c\
  src/crypto/asn1/a_print.c\
  src/crypto/asn1/a_strnid.c\
  src/crypto/asn1/a_time.c\
  src/crypto/asn1/a_type.c\
  src/crypto/asn1/a_utctm.c\
  src/crypto/asn1/a_utf8.c\
  src/crypto/asn1/asn1_lib.c\
  src/crypto/asn1/asn1_par.c\
  src/crypto/asn1/asn_pack.c\
  src/crypto/asn1/f_enum.c\
  src/crypto/asn1/f_int.c\
  src/crypto/asn1/f_string.c\
  src/crypto/asn1/tasn_dec.c\
  src/crypto/asn1/tasn_enc.c\
  src/crypto/asn1/tasn_fre.c\
  src/crypto/asn1/tasn_new.c\
  src/crypto/asn1/tasn_typ.c\
  src/crypto/asn1/tasn_utl.c\
  src/crypto/asn1/time_support.c\
  src/crypto/base64/base64.c\
  src/crypto/bio/bio.c\
  src/crypto/bio/bio_mem.c\
  src/crypto/bio/connect.c\
  src/crypto/bio/fd.c\
  src/crypto/bio/file.c\
  src/crypto/bio/hexdump.c\
  src/crypto/bio/pair.c\
  src/crypto/bio/printf.c\
  src/crypto/bio/socket.c\
  src/crypto/bio/socket_helper.c\
  src/crypto/bn_extra/bn_asn1.c\
  src/crypto/bn_extra/convert.c\
  src/crypto/buf/buf.c\
  src/crypto/bytestring/asn1_compat.c\
  src/crypto/bytestring/ber.c\
  src/crypto/bytestring/cbb.c\
  src/crypto/bytestring/cbs.c\
  src/crypto/bytestring/unicode.c\
  src/crypto/chacha/chacha.c\
  src/crypto/cipher_extra/cipher_extra.c\
  src/crypto/cipher_extra/derive_key.c\
  src/crypto/cipher_extra/e_aesccm.c\
  src/crypto/cipher_extra/e_aesctrhmac.c\
  src/crypto/cipher_extra/e_aesgcmsiv.c\
  src/crypto/cipher_extra/e_chacha20poly1305.c\
  src/crypto/cipher_extra/e_null.c\
  src/crypto/cipher_extra/e_rc2.c\
  src/crypto/cipher_extra/e_rc4.c\
  src/crypto/cipher_extra/e_tls.c\
  src/crypto/cipher_extra/tls_cbc.c\
  src/crypto/cmac/cmac.c\
  src/crypto/conf/conf.c\
  src/crypto/cpu-aarch64-fuchsia.c\
  src/crypto/cpu-aarch64-linux.c\
  src/crypto/cpu-arm-linux.c\
  src/crypto/cpu-arm.c\
  src/crypto/cpu-intel.c\
  src/crypto/cpu-ppc64le.c\
  src/crypto/crypto.c\
  src/crypto/curve25519/spake25519.c\
  src/crypto/dh/check.c\
  src/crypto/dh/dh.c\
  src/crypto/dh/dh_asn1.c\
  src/crypto/dh/params.c\
  src/crypto/digest_extra/digest_extra.c\
  src/crypto/dsa/dsa.c\
  src/crypto/dsa/dsa_asn1.c\
  src/crypto/ec_extra/ec_asn1.c\
  src/crypto/ec_extra/ec_derive.c\
  src/crypto/ecdh_extra/ecdh_extra.c\
  src/crypto/ecdsa_extra/ecdsa_asn1.c\
  src/crypto/engine/engine.c\
  src/crypto/err/err.c\
  src/crypto/evp/digestsign.c\
  src/crypto/evp/evp.c\
  src/crypto/evp/evp_asn1.c\
  src/crypto/evp/evp_ctx.c\
  src/crypto/evp/p_dsa_asn1.c\
  src/crypto/evp/p_ec.c\
  src/crypto/evp/p_ec_asn1.c\
  src/crypto/evp/p_ed25519.c\
  src/crypto/evp/p_ed25519_asn1.c\
  src/crypto/evp/p_rsa.c\
  src/crypto/evp/p_rsa_asn1.c\
  src/crypto/evp/p_x25519.c\
  src/crypto/evp/p_x25519_asn1.c\
  src/crypto/evp/pbkdf.c\
  src/crypto/evp/print.c\
  src/crypto/evp/scrypt.c\
  src/crypto/evp/sign.c\
  src/crypto/ex_data.c\
  src/crypto/fipsmodule/bcm.c\
  src/crypto/fipsmodule/fips_shared_support.c\
  src/crypto/fipsmodule/is_fips.c\
  src/crypto/hkdf/hkdf.c\
  src/crypto/hrss/hrss.c\
  src/crypto/lhash/lhash.c\
  src/crypto/mem.c\
  src/crypto/obj/obj.c\
  src/crypto/obj/obj_xref.c\
  src/crypto/pem/pem_all.c\
  src/crypto/pem/pem_info.c\
  src/crypto/pem/pem_lib.c\
  src/crypto/pem/pem_oth.c\
  src/crypto/pem/pem_pk8.c\
  src/crypto/pem/pem_pkey.c\
  src/crypto/pem/pem_x509.c\
  src/crypto/pem/pem_xaux.c\
  src/crypto/pkcs7/pkcs7.c\
  src/crypto/pkcs7/pkcs7_x509.c\
  src/crypto/pkcs8/p5_pbev2.c\
  src/crypto/pkcs8/pkcs8.c\
  src/crypto/pkcs8/pkcs8_x509.c\
  src/crypto/poly1305/poly1305.c\
  src/crypto/poly1305/poly1305_arm.c\
  src/crypto/poly1305/poly1305_vec.c\
  src/crypto/pool/pool.c\
  src/crypto/rand_extra/deterministic.c\
  src/crypto/rand_extra/forkunsafe.c\
  src/crypto/rand_extra/fuchsia.c\
  src/crypto/rand_extra/rand_extra.c\
  src/crypto/rand_extra/windows.c\
  src/crypto/rc4/rc4.c\
  src/crypto/refcount_c11.c\
  src/crypto/refcount_lock.c\
  src/crypto/rsa_extra/rsa_asn1.c\
  src/crypto/rsa_extra/rsa_print.c\
  src/crypto/siphash/siphash.c\
  src/crypto/stack/stack.c\
  src/crypto/thread.c\
  src/crypto/thread_none.c\
  src/crypto/thread_pthread.c\
  src/crypto/thread_win.c\
  src/crypto/x509/a_digest.c\
  src/crypto/x509/a_sign.c\
  src/crypto/x509/a_strex.c\
  src/crypto/x509/a_verify.c\
  src/crypto/x509/algorithm.c\
  src/crypto/x509/asn1_gen.c\
  src/crypto/x509/by_dir.c\
  src/crypto/x509/by_file.c\
  src/crypto/x509/i2d_pr.c\
  src/crypto/x509/rsa_pss.c\
  src/crypto/x509/t_crl.c\
  src/crypto/x509/t_req.c\
  src/crypto/x509/t_x509.c\
  src/crypto/x509/t_x509a.c\
  src/crypto/x509/x509.c\
  src/crypto/x509/x509_att.c\
  src/crypto/x509/x509_cmp.c\
  src/crypto/x509/x509_d2.c\
  src/crypto/x509/x509_def.c\
  src/crypto/x509/x509_ext.c\
  src/crypto/x509/x509_lu.c\
  src/crypto/x509/x509_obj.c\
  src/crypto/x509/x509_r2x.c\
  src/crypto/x509/x509_req.c\
  src/crypto/x509/x509_set.c\
  src/crypto/x509/x509_trs.c\
  src/crypto/x509/x509_txt.c\
  src/crypto/x509/x509_v3.c\
  src/crypto/x509/x509_vfy.c\
  src/crypto/x509/x509_vpm.c\
  src/crypto/x509/x509cset.c\
  src/crypto/x509/x509name.c\
  src/crypto/x509/x509rset.c\
  src/crypto/x509/x509spki.c\
  src/crypto/x509/x_algor.c\
  src/crypto/x509/x_all.c\
  src/crypto/x509/x_attrib.c\
  src/crypto/x509/x_crl.c\
  src/crypto/x509/x_exten.c\
  src/crypto/x509/x_info.c\
  src/crypto/x509/x_name.c\
  src/crypto/x509/x_pkey.c\
  src/crypto/x509/x_pubkey.c\
  src/crypto/x509/x_req.c\
  src/crypto/x509/x_sig.c\
  src/crypto/x509/x_spki.c\
  src/crypto/x509/x_val.c\
  src/crypto/x509/x_x509.c\
  src/crypto/x509/x_x509a.c\
  src/crypto/x509v3/pcy_cache.c\
  src/crypto/x509v3/pcy_data.c\
  src/crypto/x509v3/pcy_lib.c\
  src/crypto/x509v3/pcy_map.c\
  src/crypto/x509v3/pcy_node.c\
  src/crypto/x509v3/pcy_tree.c\
  src/crypto/x509v3/v3_akey.c\
  src/crypto/x509v3/v3_akeya.c\
  src/crypto/x509v3/v3_alt.c\
  src/crypto/x509v3/v3_bcons.c\
  src/crypto/x509v3/v3_bitst.c\
  src/crypto/x509v3/v3_conf.c\
  src/crypto/x509v3/v3_cpols.c\
  src/crypto/x509v3/v3_crld.c\
  src/crypto/x509v3/v3_enum.c\
  src/crypto/x509v3/v3_extku.c\
  src/crypto/x509v3/v3_genn.c\
  src/crypto/x509v3/v3_ia5.c\
  src/crypto/x509v3/v3_info.c\
  src/crypto/x509v3/v3_int.c\
  src/crypto/x509v3/v3_lib.c\
  src/crypto/x509v3/v3_ncons.c\
  src/crypto/x509v3/v3_ocsp.c\
  src/crypto/x509v3/v3_pci.c\
  src/crypto/x509v3/v3_pcia.c\
  src/crypto/x509v3/v3_pcons.c\
  src/crypto/x509v3/v3_pku.c\
  src/crypto/x509v3/v3_pmaps.c\
  src/crypto/x509v3/v3_prn.c\
  src/crypto/x509v3/v3_purp.c\
  src/crypto/x509v3/v3_skey.c\
  src/crypto/x509v3/v3_sxnet.c\
  src/crypto/x509v3/v3_utl.c\
  src/third_party/fiat/curve25519.c\
  ${sources}
ar rcs libcrypto.a *.o
#$CC -shared -o ../libcrypto.so *.o

cd ../libcrypto_utils
$CC -fPIC -I../include -c android_pubkey.c
ar rcs libcrypto_utils.a *.o
#$CC -shared -o ../libcrypto_utils.so *.o

cd ../liblp
$CC -fPIC -std=c++17 -D_FILE_OFFSET_BITS=64 -I../include -c builder.cpp images.cpp partition_opener.cpp property_fetcher.cpp reader.cpp utility.cpp writer.cpp
ar rcs liblp.a *.o
#$CC -shared -o ../liblp.so *.o

cd ../partition_tools
if [ "$HOSTTYPE" = i686 ] || [ "$HOSTTYPE" = x86_64 ];then
  $CC++ -static -std=c++17 -I../include -o ../lpunpack lpunpack.cc ../liblp/liblp.a ../libsparse/libsparse.a -lz ../base/libbase.a ../liblog/liblog.a ../crypto/libcrypto.a ../libcrypto_utils/libcrypto_utils.a ../ext4_utils/libext4_utils.a -lpthread

  $CC++ -static -std=c++17 -I../include -o ../lpmake lpmake.cc ../liblp/liblp.a ../libsparse/libsparse.a -lz ../base/libbase.a ../liblog/liblog.a ../crypto/libcrypto.a ../libcrypto_utils/libcrypto_utils.a ../ext4_utils/libext4_utils.a -lpthread
else
  $CC++ -static -std=c++17 -I../include -o ../lpunpack lpunpack.cc ../liblp/liblp.a ../libsparse/libsparse.a ../zlib/libz.a ../base/libbase.a ../liblog/liblog.a ../crypto/libcrypto.a ../libcrypto_utils/libcrypto_utils.a ../ext4_utils/libext4_utils.a -lpthread

  $CC++ -static -std=c++17 -I../include -o ../lpmake lpmake.cc ../liblp/liblp.a ../libsparse/libsparse.a ../zlib/libz.a ../base/libbase.a ../liblog/liblog.a ../crypto/libcrypto.a ../libcrypto_utils/libcrypto_utils.a ../ext4_utils/libext4_utils.a -lpthread
fi
