set(X264_VERSION 157)

vcpkg_fail_port_install(ON_TARGET "OSX") 

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mirror/x264
    REF stable
    SHA512 139132ff145ba2d080d8e0a5368eecf5507120780d8e69b7f5b3e4c277415079e5a322405f3de1c2367a24035e1d8450fc7f67c97a36a544e111132e6c1b26c7
    HEAD_REF master
    PATCHES 
        "uwp-cflags.patch"
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --enable-strip
        --disable-lavf
        --disable-swscale
        --disable-avs
        --disable-ffms
        --disable-gpac
        --disable-lsmash
        --disable-asm
        --enable-debug
        --disable-cli
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES -lpthread -lm -ldl)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig
    ${CURRENT_PACKAGES_DIR}/debug/bin/x264.exe
    ${CURRENT_PACKAGES_DIR}/debug/include
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libx264.dll.lib ${CURRENT_PACKAGES_DIR}/lib/libx264.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libx264.dll.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libx264.lib)
else()
    # force U_STATIC_IMPLEMENTATION macro
    file(READ ${CURRENT_PACKAGES_DIR}/include/x264.h HEADER_CONTENTS)
    string(REPLACE "defined(U_STATIC_IMPLEMENTATION)" "1" HEADER_CONTENTS "${HEADER_CONTENTS}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/x264.h "${HEADER_CONTENTS}")

    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin
    )
endif()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
