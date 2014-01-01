find_package(FLEX)
flex_target(zmmix_tg zmmix_tg.l ${CMAKE_CURRENT_BINARY_DIR}/zmmix_tg.c)
add_executable(zmmix_tg
    ${FLEX_zmmix_tg_OUTPUTS}
)
set_source_files_properties(${FLEX_zmmix_tg_OUTPUTS} PROPERTIES COMPILE_FLAGS
    "-Wno-unused-function -Wno-unused-label"
)
target_link_libraries(zmmix_tg fl)
