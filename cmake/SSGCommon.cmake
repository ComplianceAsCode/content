set(SSG_SHARED "${CMAKE_SOURCE_DIR}/shared")
set(SSG_SHARED_TRANSFORMS "${SSG_SHARED}/transforms")
set(SSG_SHARED_UTILS "${SSG_SHARED}/utils")

macro(ssg_xsltproc INPUT XSLT OUTPUT)
    add_custom_command(
        OUTPUT ${OUTPUT}
        COMMAND ${XSLTPROC_EXECUTABLE} --output ${OUTPUT} ${XSLT} ${INPUT}
        MAIN_DEPENDENCY ${INPUT}
        DEPENDS ${XSLT}
    )
endmacro()

macro(ssg_build_guide_xml PRODUCT)
    if(OSCAP_SVG_SUPPORT EQUAL 0)
        ssg_xsltproc(
            ${CMAKE_CURRENT_SOURCE_DIR}/input/guide.xml
            ${SSG_SHARED_TRANSFORMS}/includelogo.xslt
            ${CMAKE_CURRENT_BINARY_DIR}/guide.xml
        )
    else()
        add_custom_command(
            OUTPUT ${OUTPUT}
            COMMAND ${CMAKE_COMMAND} -E copy ${INPUT} ${OUTPUT}
            MAIN_DEPENDENCY ${INPUT}
        )
    endif()
endmacro()
