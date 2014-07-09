#!/bin/bash

# Script to build NSS and NSPR for a target architecture.  Requires that
# we also build on our host and use some of the resulting binaries.

set -o errtrace
trap 'echo Fatal error: script $0 aborting at line $LINENO, command \"$BASH_COMMAND\" returned $?; exit 1' ERR

readonly LOCAL_PATH=$(dirname $0)

# Check to make sure we have everything we need for both builds.
if [ -z "${TARGET_CC}" -o -z "${TARGET_CFLAGS}" -o \
  -z "${TARGET_AR}" -o -z "${TARGET_OUT}" -o \
  -z "${TARGET_ARCH}" -o -z "${HOST_OUT}" -o -z "${NSS_SRC_TAR_GZ}" -o \
  -z "${NSS_TOP_DIR}" -o -z "${CURDIR}" ]; then
  echo "$0: Missing environment variables needed for build"
  exit 1
fi

echo '################## NSS ENVIRONMENT ##########################'
echo export TARGET_CC=${TARGET_CC}
echo export TARGET_CFLAGS=${TARGET_CFLAGS}
echo export TARGET_AR=${TARGET_AR}
echo export TARGET_OUT=${TARGET_OUT}
echo export TARGET_ARCH=${TARGET_ARCH}
echo export HOST_OUT=${HOST_OUT}
echo export NSS_SRC_TAR_GZ=${NSS_SRC_TAR_GZ}
echo export NSS_TOP_DIR=${NSS_TOP_DIR}
echo export CURDIR=${CURDIR}
echo '################## END NSS ENVIRONMENT #######################'

# Derive the NSS flags from the target cflags with exceptions
# noted below:
#
# 1) -Ox: we only support optimized target builds
#    (see BUILD_OPT, enable/disable switches below).
# 2) -fpic won't work, upgrade to -fPIC.
# 3) NSS has some questionable string literal comparisons, we
#    need to disable error=address or it won't compile.
# 4) Remove ANDROID defines, includes, DEBUG settings, etc.
#    (NSS configure script should figure out the right values).
readonly NSS_CFLAGS=$(echo ${TARGET_CFLAGS} | sed \
  -e 's/ -O[s0123] / /g' \
  -e 's/ -fpic / -fPIC /g' \
  -e 's/ -Werror=address / /g' \
  -e 's/ -DANDROID / /g' \
  -e 's/ -D__ANDROID__ / /g' \
  -e 's/ -DNDEBUG / /g' \
  -e 's/ -UDEBUG / /g' \
  -e 's/ -include .*\/AndroidConfig-glibc.h / /g' \
  -e 's/ -I system\/.*\/arch-arm / /g' \
  -e 's/ -I system\/.*\/linux-arm\/ / /g' \
  -e 's/ -I system\/.*\/glibc_bridge\/include / /g')

# This still leaves us with lots of important flags which we will use
# to insure compatiblity with the other binaries we will link with
# (e.g. arm v.s. thumb, fixes for unwinding stacks, extra warning checks, etc).
test \! -z "${NSS_CFLAGS}"

# These are relative paths (from the android root).
readonly HOST_OUT_INTERMEDIATES=${HOST_OUT}/obj
readonly TARGET_OUT_INTERMEDIATES=${TARGET_OUT}/obj

# This needs to be an absolute path.
readonly TOP=${CURDIR}

# Top of our toolchain root.  We need this to build
# and will be installing our headers & libs there.
readonly SYSROOT=${TOP}/${TARGET_OUT}/build_sysroot

# Sub directory from which we build NSS.
readonly NSS_DIR=${NSS_TOP_DIR}/nss

# Setup any global NSS build parameters (for both host
# and target).

# Enable support for Elliptic curve cryptography (ECC).
# Some of the chrome unit tests use EC keys and will
# fail without this.
readonly NSS_ENABLE_ECC=1
export NSS_ENABLE_ECC

# First, build everything for the host.  While only a few binaries
# are needed now, others might be useful later.
#
# Notes:
#
# We need nsinstall (for the target build).
# We need certutil (to create a system nssdb).
# We *may* need shlibsign (if we ever want to support FIPS 140).
# We need libraries associated with the above (certutil, shlibsign).

# Note: We make two copies of the source (for host and target)
# as the build process leaves build intermediates all over the
# place.  It is simpler and cleaner to just keep two copies.
# Also by copying and building the sources in our intermediate
# directory, we keep from poluting our source tree.

# Untar host sources
rm -rf ${HOST_OUT_INTERMEDIATES}/${NSS_TOP_DIR}
mkdir -p ${HOST_OUT_INTERMEDIATES}
gunzip -dc ${NSS_SRC_TAR_GZ} | tar xfC - ${HOST_OUT_INTERMEDIATES}

# Do complete host build (assumes 64-bit)
pushd ${HOST_OUT_INTERMEDIATES}/${NSS_DIR}
make CC=gcc USE_64=1 nss_build_all
popd

# Locate host commands.
readonly NSINSTALL=$(find \
  ${TOP}/${HOST_OUT_INTERMEDIATES}/${NSS_TOP_DIR}/nss/coreconf/nsinstall/ \
  -name nsinstall -type f | head -1)
readonly CERTUTIL=$(find \
  ${TOP}/${HOST_OUT_INTERMEDIATES}/${NSS_TOP_DIR}/nss/ \
  -name certutil -type f | head -1)
if [ \! -x "${NSINSTALL}" -o \! -x "${CERTUTIL}" ]; then
  echo "$0: host commands not found"
  exit 1
fi

# Now we are ready to build for the target, setup some variables
# we will need.
readonly TOOLCHAIN_PATH=$(dirname ${TARGET_CC})
readonly CC=$(basename ${TARGET_CC})
readonly AR=$(basename ${TARGET_AR})

export PATH=${PATH}:${TOP}/${TOOLCHAIN_PATH}
readonly TARGET=$(echo $CC | sed 's/-gcc$//')

# Untar target sources
rm -rf ${TARGET_OUT_INTERMEDIATES}/${NSS_TOP_DIR}
mkdir -p ${TARGET_OUT_INTERMEDIATES}
gunzip -dc ${NSS_SRC_TAR_GZ} | tar xfC - ${TARGET_OUT_INTERMEDIATES}

# Apply target patches, if any.
readonly PATCH_SRC=${LOCAL_PATH}/patches

# We need to build the target in steps, and each of the build
# components require differnt hacks to get them to cross compile
# with our toolchain / environment.

pushd ${TARGET_OUT_INTERMEDIATES}/${NSS_DIR}

# We can't sign right now, at least until libs are stripped.
# Since we don't use FIPS 140, just disable signing entirely.
readonly SHLIBSIGN=cmd/shlibsign/sign.sh
mv ${SHLIBSIGN} ${SHLIBSIGN}-old
cp ${TOP}/${LOCAL_PATH}/dummy-sign.sh ${SHLIBSIGN}
chmod 755 ${SHLIBSIGN}

# Build NSPR.
make BUILD_OPT=1 \
  NSPR_CONFIGURE_OPTS="--target=${TARGET} --disable-debug --enable-optimize" \
  CC=${CC} DSO_CFLAGS="${NSS_CFLAGS}" CPU_TAG=_${TARGET_ARCH} \
  NSINSTALL=${NSINSTALL} build_nspr

# Note: we don't define NSS_USE_SYSTEM_SQLITE, see comments in our gyp
# files.  It would be nice if we could do this.

# Build NSS (depends on our system zlib).
XCFLAGS=""
DSO_LDOPTS="-shared"
XCFLAGS+=" -I${TOP}/external/zlib --sysroot=${SYSROOT}"
DSO_LDOPTS+=" --sysroot=${SYSROOT}"
make BUILD_OPT=1 CPU_TAG=_${TARGET_ARCH} OS_TEST=${TARGET_ARCH} CC=${CC} \
  DSO_CFLAGS="${NSS_CFLAGS}" AR="${AR} cr \$@" NSINSTALL=${NSINSTALL} \
  XCFLAGS="${XCFLAGS}" DSO_LDOPTS="${DSO_LDOPTS}" all

popd

# Now install the target headers and libs into our toolchain
# so we can build content_shell.  Also install libs for our
# run-time.

# Install headers for NSPR + NSS.
mkdir -p ${SYSROOT}/usr/include/nspr
cp -rpL ${TARGET_OUT_INTERMEDIATES}/${NSS_TOP_DIR}/dist/Linux*/include/* \
  ${SYSROOT}/usr/include/nspr

mkdir -p ${SYSROOT}/usr/include/nss
cp -rpL ${TARGET_OUT_INTERMEDIATES}/${NSS_TOP_DIR}/dist/public/nss/* \
  ${SYSROOT}/usr/include/nss

# As we will building content_shell with use_system_ssl=0,
# we will be linking against chrome's libssl.  As we are
# not supplying libssl3.so (NSS), make sure we don't supply
# conflicting headers.  Remove them to be safe.
for i in ssl.h sslt.h sslerr.h sslproto.h preenc.h; do
  rm ${SYSROOT}/usr/include/nss/${i}
done

# Install libraries.
for i in libnss3.so libnssutil3.so libsmime3.so libplds4.so libplc4.so \
libnspr4.so libnssckbi.so libsqlite3.so libsoftokn3.so libfreebl3.so; do
  cp -pL ${TARGET_OUT_INTERMEDIATES}/${NSS_TOP_DIR}/dist/Linux*/lib/$i \
    ${SYSROOT}/usr/lib
  cp -pL ${TARGET_OUT_INTERMEDIATES}/${NSS_TOP_DIR}/dist/Linux*/lib/$i \
    ${TARGET_OUT}/symbols/system/lib
  # Note: this will get stripped during the build.
  cp -pL ${TARGET_OUT_INTERMEDIATES}/${NSS_TOP_DIR}/dist/Linux*/lib/$i \
    ${TARGET_OUT}/system/lib
done

# Create a system-level certificate database to augment the root
# certs stored in libnssckbi.so.  This system DB will by loaded
# by nss_util.cc at NSS initialization time.
#
# Note: For Eureka devices, this replaces the per-user cert DB
# usually loaded by NSS.

# We use this read-only system-level database to add certs not
# delivered as part of NSS's root cert library as well as to
# potentially modify trust settings (e.g. disable certs no
# longer trusted).

# Note: there is a symlink from /etc to /system/etc.
readonly NSSDB=${TARGET_OUT}/system/etc/pki/nssdb
rm -rf ${NSSDB}
mkdir -p ${NSSDB}

# Note: We use an insecure password as we will not be storing
# or encrypting private keys in this system db.  The
# password should not be needed (or used) by content_shell
# as it will simply be retrieving certificates.
readonly PWDFILE=${LOCAL_PATH}/insecure-certdb-password.txt

# Use the new sql sharable nssdb format
readonly SYSDB="sql:${NSSDB}"

HOST_LIBRARY_PATH=$(echo ${HOST_OUT_INTERMEDIATES}/${NSS_TOP_DIR}/dist/Linux*/lib)

# Create the empty DB
LD_LIBRARY_PATH=${HOST_LIBRARY_PATH} \
  ${CERTUTIL} -N -d ${SYSDB} -f ${PWDFILE}

# Add any needed certs
# Modify trust for any certs (if needed).

# Example only:
#
#LD_LIBRARY_PATH=${HOST_LIBRARY_PATH} \
#  ${CERTUTIL} -A -d ${SYSDB} -f ${PWDFILE} -t T,, -n "evilco.com" \
#  -i "vendor/eureka/ssl-certs/usr/share/ca-certificates/evilco.crt"

exit 0
