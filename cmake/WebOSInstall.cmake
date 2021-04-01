cmake_minimum_required (VERSION 3.0)

# Making target for componet
function(target_webos_install TARGET)
    set(ares_arguments "")
    get_target_property(package_path ${TARGET} WEBOS_PACKAGE_PATH)
    get_target_property(package_target ${TARGET} WEBOS_PACKAGE_TARGET)
    get_target_property(appinfo_id ${TARGET} WEBOS_APPINFO_ID)

    if (WEBOS_INSTALL_DEVICES_LIST)
        execute_process(COMMAND bash -c "ares-setup-device -F | json -a name" OUTPUT_VARIABLE ares_devices_output)
        string(REPLACE "\n" ";" ares_devices_list ${ares_devices_output})
        # separate_arguments(ares_devices_list)
        foreach(ares_device_name ${ares_devices_list})
            set(ares_arguments "-d" ${ares_device_name})
            
            add_custom_target(webos-install-${TARGET}.${ares_device_name}
                COMMAND ares-install ${ares_arguments} ${package_path}
                DEPENDS ${package_target}
            )

            add_custom_target(webos-launch-${TARGET}.${ares_device_name}
                COMMAND ares-launch ${appinfo_id} ${ares_arguments} 
                DEPENDS webos-install-${TARGET}.${ares_device_name}
            )
        endforeach()
    else()
        if (WEBOS_INSTALL_DEVICE)
            set(ares_arguments "-d" ${WEBOS_INSTALL_DEVICE})
        endif()

        add_custom_target(webos-install-${TARGET}
            COMMAND ares-install ${ares_arguments} ${package_path}
            DEPENDS ${package_target}
        )

        add_custom_target(webos-launch-${TARGET}
            COMMAND ares-launch ${appinfo_id} ${ares_arguments} 
            DEPENDS webos-install-${TARGET}
        )
    endif()
endfunction()