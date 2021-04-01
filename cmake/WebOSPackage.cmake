cmake_minimum_required (VERSION 3.0)

find_program(JO_PROGRAM jo)
if (NOT JO_PROGRAM)
    message(FATAL_ERROR "jo is not installed. See https://github.com/jpmens/jo")
endif()

find_program(ARES_PROGRAM ares-package)
if (NOT ARES_PROGRAM)
    message(FATAL_ERROR "Unable to find `ares-package`. Please make sure webOS SDK is installed, "
                        "and `ares-package` is in your PATH.\n"
                        "See https://www.webosose.org/docs/tools/sdk/sdk-download/")
endif()

if (NOT DEFINED ENV{ARCH})
    message(FATAL_ERROR "$ARCH is not set.")
endif()

# Making target for componet
function(target_webos_package TARGET)
    get_target_property(bin_path ${TARGET} RUNTIME_OUTPUT_DIRECTORY)
    if (NOT bin_path)
        set(bin_path ${CMAKE_CURRENT_BINARY_DIR}/${TARGET})
    endif()

    get_target_property(appinfo_id ${TARGET} WEBOS_APPINFO_ID)
    get_target_property(appinfo_version ${TARGET} WEBOS_APPINFO_VERSION)
    get_target_property(appinfo_vendor ${TARGET} WEBOS_APPINFO_VENDOR)
    get_target_property(appinfo_title ${TARGET} WEBOS_APPINFO_TITLE)
    get_target_property(appinfo_icon ${TARGET} WEBOS_APPINFO_ICON)
    get_target_property(appinfo_extra ${TARGET} WEBOS_APPINFO_EXTRA)
    if (NOT appinfo_extra)
        set(appinfo_extra "")
    endif()

    get_target_property(package_assets ${TARGET} WEBOS_PACKAGE_ASSETS)
    if (NOT package_assets)
        set(package_assets "")
    endif()

    foreach(asset IN LISTS ${package_assets})
        if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${asset})
            message(FATAL_ERROR "Can't find " ${asset})
        endif()
    endforeach()

    get_filename_component(appinfo_icon_basename ${appinfo_icon} NAME)

    set(package_dir pkg_$ENV{ARCH})
    set(package_ipk_name ${appinfo_id}_${appinfo_version}_$ENV{ARCH}.ipk)

    target_compile_definitions(${TARGET} PUBLIC WEBOS_APPID="${appinfo_id}")

    # Build package target for component
    set(package_target_name ${TARGET}.ipk)

    set_target_properties(${TARGET} PROPERTIES 
        WEBOS_PACKAGE_FILENAME ${package_ipk_name}
        WEBOS_PACKAGE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${package_ipk_name}
        WEBOS_PACKAGE_TARGET ${package_target_name}
    )

    add_custom_target(${package_target_name}
        # FIXME: jo on Debian 10 doesn't support -N option. Find something else?
        COMMAND rm -rf pkg_$ENV{ARCH} ${package_ipk_name}
        COMMAND mkdir pkg_$ENV{ARCH}
        # Copy binary
        COMMAND cp ${bin_path} ${package_dir}/
        # Copy appinfo.json
        COMMAND jo id=${appinfo_id} version=${appinfo_version} vendor=${appinfo_vendor}
            type=native main=${TARGET} title=${appinfo_title} icon=${appinfo_icon_basename} 
            ${appinfo_extra} > ${package_dir}/appinfo.json
        # Copy icon
        COMMAND cp ${appinfo_icon} ${package_dir}/
        # Copy extra files
        COMMAND test -n "${package_assets}" && cd ${CMAKE_CURRENT_SOURCE_DIR} && cp -r ${package_assets} ${CMAKE_CURRENT_BINARY_DIR}/${package_dir}/ || true
        # Build IPK
        COMMAND ares-package ${package_dir}
        DEPENDS ${TARGET}
        BYPRODUCTS ${package_dir} ${CMAKE_CURRENT_BINARY_DIR}/${package_ipk_name}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        VERBATIM
        SOURCES ${appinfo_icon}
    )
endfunction()