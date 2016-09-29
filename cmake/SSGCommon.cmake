set(SSG_SHARED "${CMAKE_SOURCE_DIR}/shared")
set(SSG_SHARED_TRANSFORMS "${SSG_SHARED}/transforms")
set(SSG_SHARED_UTILS "${SSG_SHARED}/utils")

macro(ssg_build_guide_xml PRODUCT)
    if(OSCAP_SVG_SUPPORT EQUAL 0)
        add_custom_command(
            OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/guide.xml
            COMMAND ${XSLTPROC_EXECUTABLE} --output ${CMAKE_CURRENT_BINARY_DIR}/guide.xml ${SSG_SHARED_TRANSFORMS}/includelogo.xslt ${SSG_SHARED}/xccdf/shared_guide.xml
            MAIN_DEPENDENCY ${SSG_SHARED}/xccdf/shared_guide.xml
            DEPENDS ${SSG_SHARED_TRANSFORMS}/includelogo.xslt
            COMMENT "[${PRODUCT}] generating guide.xml (SVG logo enabled)"
        )
    else()
        add_custom_command(
            OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/guide.xml
            COMMAND ${CMAKE_COMMAND} -E copy ${SSG_SHARED}/xccdf/shared_guide.xml ${CMAKE_CURRENT_BINARY_DIR}/guide.xml
            MAIN_DEPENDENCY ${SSG_SHARED}/xccdf/shared_guide.xml
            COMMENT "[${PRODUCT}] generating guide.xml (SVG logo disabled)"
        )
    endif()
endmacro()

macro(ssg_build_shorthand_xml PRODUCT)
    file(GLOB AUXILIARY_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/input/auxiliary/*.xml")
    file(GLOB PROFILE_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/input/profiles/*.xml")
    file(GLOB XCCDF_RULE_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/input/xccdf/**/*.xml")

    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml
        COMMAND ${XSLTPROC_EXECUTABLE} --stringparam SHARED_RP ${SSG_SHARED} --output ${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml ${CMAKE_CURRENT_SOURCE_DIR}/input/guide.xslt ${CMAKE_CURRENT_BINARY_DIR}/guide.xml
        COMMAND ${XMLLINT_EXECUTABLE} --format --output ${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml ${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml
        MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/guide.xml
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/input/guide.xslt ${AUXILIARY_DEPS} ${PROFILE_DEPS} ${XCCDF_RULE_DEPS}
        COMMENT "[${PRODUCT}] generating shorthand.xml"
    )
endmacro()

macro(ssg_build_xccdf_unlinked PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml
        COMMAND ${XSLTPROC_EXECUTABLE} --stringparam ssg_version ${SSG_VERSION} --output ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml ${CMAKE_CURRENT_SOURCE_DIR}/transforms/shorthand2xccdf.xslt ${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml
        COMMAND ${OSCAP_EXECUTABLE} xccdf resolve -o ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml
        MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/shorthand.xml
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/transforms/shorthand2xccdf.xslt
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/transforms/constants.xslt
        DEPENDS ${SSG_SHARED_TRANSFORMS}/shared_constants.xslt
        COMMENT "[${PRODUCT}] generating xccdf-unlinked-resolved.xml"
    )
endmacro()

macro(ssg_build_ocil_unlinked PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml
        COMMAND ${XSLTPROC_EXECUTABLE} --output ${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml ${SSG_SHARED_TRANSFORMS}/xccdf-create-ocil.xslt ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml
        COMMAND ${XMLLINT_EXECUTABLE} --format --output ${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml ${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml
        MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml
        DEPENDS ${SSG_SHARED_TRANSFORMS}/xccdf-create-ocil.xslt
        COMMENT "[${PRODUCT}] generating ocil-unlinked.xml"
    )
endmacro()

macro(ssg_build_xccdf_ocilrefs PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml
        COMMAND ${XSLTPROC_EXECUTABLE} --stringparam product ${PRODUCT} --output ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml ${SSG_SHARED_TRANSFORMS}/xccdf-ocilcheck2ref.xslt ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml
        MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-resolved.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml
        DEPENDS ${SSG_SHARED_TRANSFORMS}/xccdf-ocilcheck2ref.xslt
        COMMENT "[${PRODUCT}] generating xccdf-unlinked-ocilrefs.xml"
    )
endmacro()

macro(ssg_build_bash_remediations PRODUCT)
    file(GLOB BASH_REMEDIATION_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/templates/output/bash/*")
    file(GLOB SHARED_BASH_REMEDIATION_DEPS "${SSG_SHARED}/templates/output/bash/*")

    # TODO: The environment variable is not very portable
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/bash-remediations.xml
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_TRANSFORMS}/combineremediations.py ${PRODUCT} bash ${SSG_SHARED}/templates/output/bash ${CMAKE_CURRENT_SOURCE_DIR}/templates/output/bash ${CMAKE_CURRENT_BINARY_DIR}/bash-remediations.xml
        DEPENDS ${BASH_REMEDIATION_DEPS} ${SHARED_BASH_REMEDIATION_DEPS}
        DEPENDS ${SSG_SHARED_TRANSFORMS}/combineremediations.py
        COMMENT "[${PRODUCT}] generating bash-remediations.xml"
    )
endmacro()

macro(ssg_build_ansible_remediations PRODUCT)
    file(GLOB BASH_REMEDIATION_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/templates/output/ansible/*")
    file(GLOB SHARED_BASH_REMEDIATION_DEPS "${SSG_SHARED}/templates/output/ansible/*")

    # TODO: The environment variable is not very portable
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/ansible-remediations.xml
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_TRANSFORMS}/combineremediations.py ${PRODUCT} ansible ${SSG_SHARED}/templates/output/ansible ${CMAKE_CURRENT_SOURCE_DIR}/templates/output/ansible ${CMAKE_CURRENT_BINARY_DIR}/ansible-remediations.xml
        DEPENDS ${BASH_REMEDIATION_DEPS} ${SHARED_BASH_REMEDIATION_DEPS}
        DEPENDS ${SSG_SHARED_TRANSFORMS}/combineremediations.py
        COMMENT "[${PRODUCT}] generating ansible-remediations.xml"
    )
endmacro()

macro(ssg_build_xccdf_with_remediations PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml
        COMMAND ${XSLTPROC_EXECUTABLE} --stringparam bash_remediations ${CMAKE_CURRENT_BINARY_DIR}/bash-remediations.xml --stringparam ansible_remediations ${CMAKE_CURRENT_BINARY_DIR}/ansible-remediations.xml --output ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml ${SSG_SHARED_TRANSFORMS}/xccdf-addremediations.xslt ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml
        COMMAND ${XMLLINT_EXECUTABLE} --format --output ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml
        MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/bash-remediations.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/ansible-remediations.xml
        DEPENDS ${SSG_SHARED_TRANSFORMS}/xccdf-addremediations.xslt
        COMMENT "[${PRODUCT}] generating xccdf-unlinked.xml"
    )
endmacro()

macro(ssg_build_oval_unlinked PRODUCT)
    set(OVAL_DEPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/input/oval")
    file(GLOB OVAL_DEPS "${OVAL_DEPS_DIR}/*.xml")
    set(SHARED_OVAL_DEPS_DIR "${SSG_SHARED}/oval")
    file(GLOB SHARED_OVAL_DEPS "${SHARED_OVAL_DEPS_DIR}/*.xml")

    if(OSCAP_OVAL_511_SUPPORT EQUAL 0)
        set(OVAL_511_DEPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/input/oval/oval_5.11")
        file(GLOB OVAL_511_DEPS "${OVAL_511_DEPS_DIR}/*.xml")
        set(SHARED_OVAL_511_DEPS_DIR "${SSG_SHARED}/oval/oval_5.11")
        file(GLOB SHARED_OVAL_511_DEPS "${SHARED_OVAL_511_DEPS_DIR}/*.xml")

        add_custom_command(
            OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
            # TODO: config
            COMMAND RUNTIME_OVAL_VERSION=5.11 ${SSG_SHARED_TRANSFORMS}/combineovals.py ${CMAKE_SOURCE_DIR}/config ${PRODUCT} ${OVAL_DEPS_DIR} ${OVAL_511_DEPS_DIR} ${SHARED_OVAL_DEPS_DIR} ${SHARED_OVAL_511_DEPS_DIR} > ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
            COMMAND ${XMLLINT_EXECUTABLE} --format --output ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
            DEPENDS ${OVAL_DEPS}
            DEPENDS ${OVAL_511_DEPS}
            DEPENDS ${SHARED_OVAL_DEPS}
            DEPENDS ${SHARED_OVAL_511_DEPS}
            DEPENDS ${SSG_SHARED_TRANSFORMS}/combineovals.py
            VERBATIM
            COMMENT "[${PRODUCT}] generating oval-unlinked.xml (OVAL 5.11 checks enabled)"
        )
    else()
        add_custom_command(
            OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
            # TODO: config
            COMMAND ${SSG_SHARED_TRANSFORMS}/combineovals.py ${CMAKE_SOURCE_DIR}/config ${PRODUCT} ${OVAL_DEPS_DIR} ${SHARED_OVAL_DEPS_DIR} > ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
            COMMAND ${XMLLINT_EXECUTABLE} --format --output ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
            DEPENDS ${OVAL_DEPS}
            DEPENDS ${SHARED_OVAL_DEPS}
            DEPENDS ${SSG_SHARED_TRANSFORMS}/combineovals.py
            VERBATIM
            COMMENT "[${PRODUCT}] generating oval-unlinked.xml (OVAL 5.11 checks disabled)"
        )
    endif()
endmacro()

macro(ssg_build_link_xccdf_oval_ocil PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml ${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml ${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml
        COMMAND ${SSG_SHARED_TRANSFORMS}/relabelids.py ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml ssg
        MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml
        DEPENDS ${SSG_SHARED_TRANSFORMS}/relabelids.py
        COMMENT "[${PRODUCT}] linking IDs, generating xccdf-linked.xml, oval-linked.xml, ocil-linked.xml"
    )
endmacro()

macro(ssg_build_xccdf_final PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
        # Remove auxiliary Groups which are only for use in tables, and not guide output.
        COMMAND ${XSLTPROC_EXECUTABLE} --output ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf-removeaux.xslt ${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml
        COMMAND ${SED_EXECUTABLE} -i 's/oval-linked.xml/ssg-${PRODUCT}-oval.xml/g' ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
        COMMAND ${SED_EXECUTABLE} -i 's/ocil-linked.xml/ssg-${PRODUCT}-ocil.xml/g' ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
        COMMAND ${SSG_SHARED_UTILS}/unselect-empty-xccdf-groups.py --input ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml --output ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
        COMMAND ${OSCAP_EXECUTABLE} xccdf resolve -o ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
        MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf-removeaux.xslt
        DEPENDS ${SSG_SHARED_UTILS}/unselect-empty-xccdf-groups.py
        COMMENT "[${PRODUCT}] generating ssg-${PRODUCT}-xccdf.xml"
    )
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf.xml
        COMMAND ${OSCAP_EXECUTABLE} xccdf validate ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
        COMMAND ${SSG_SHARED_UTILS}/verify-references.py --rules-with-invalid-checks --ovaldefs-unused ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
        COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
        COMMENT "[${PRODUCT}] validating ssg-${PRODUCT}-xccdf.xml"
    )

    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml
        COMMAND ${XSLTPROC_EXECUTABLE} --stringparam reverse_DNS org.ssgproject.content --output ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml /usr/share/openscap/xsl/xccdf_1.1_to_1.2.xsl ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
        MAIN_DEPENDENCY ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
        COMMENT "[${PRODUCT}] generating ssg-${PRODUCT}-xccdf-1.2.xml"
    )
    #add_custom_command(
    #    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf-1.2.xml
    #    COMMAND ${OSCAP_EXECUTABLE} xccdf-1.2 validate ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml
    #    COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf-1.2.xml
    #    DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml
    #    COMMENT "[${PRODUCT}] validating ssg-${PRODUCT}-xccdf-1.2.xml"
    #)
endmacro()

macro(ssg_build_oval_final PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml
        # Expand 'test_attestation' URLs in OVAL document to valid SSG Contributors wiki link (fixes RHBZ#1155809 for OVAL)
        COMMAND ${XSLTPROC_EXECUTABLE} --output ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml ${CMAKE_CURRENT_SOURCE_DIR}/transforms/oval-fix-test-attestation-urls.xslt ${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml
        MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/transforms/oval-fix-test-attestation-urls.xslt
        COMMENT "[${PRODUCT}] generating ssg-${PRODUCT}-oval.xml"
    )
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-oval.xml
        COMMAND ${OSCAP_EXECUTABLE} oval validate --schematron ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml
        COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-oval.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml
        COMMENT "[${PRODUCT}] validating ssg-${PRODUCT}-oval.xml"
    )
endmacro()

macro(ssg_build_ocil_final PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml
        MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml
        COMMENT "[${PRODUCT}] generating ssg-${PRODUCT}-ocil.xml"
    )
    #add_custom_command(
    #    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ocil.xml
    #    COMMAND ${OSCAP_EXECUTABLE} ocil validate ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml
    #    COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ocil.xml
    #    DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml
    #    COMMENT "[${PRODUCT}] validating ssg-${PRODUCT}-ocil.xml"
    #)
endmacro()

macro(ssg_build_sds PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        COMMAND ${OSCAP_EXECUTABLE} ds sds-compose ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        MAIN_DEPENDENCY ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml
        COMMENT "[${PRODUCT}] generating ssg-${PRODUCT}-ds.xml"
    )
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ds.xml
        COMMAND ${OSCAP_EXECUTABLE} ds sds-validate ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ds.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        COMMENT "[${PRODUCT}] validating ssg-${PRODUCT}-ds.xml"
    )
endmacro()

macro(ssg_build_html_guides PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-guide-index.html
        COMMAND ${SSG_SHARED_UTILS}/build-all-guides.py --input ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        MAIN_DEPENDENCY ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        COMMENT "[${PRODUCT}] generating HTML guides for all profiles in ssg-${PRODUCT}-ds.xml"
    )
endmacro()

macro(ssg_build_product PRODUCT)
    ssg_build_guide_xml(${PRODUCT})
    ssg_build_shorthand_xml(${PRODUCT})
    ssg_build_xccdf_unlinked(${PRODUCT})
    ssg_build_ocil_unlinked(${PRODUCT})
    ssg_build_xccdf_ocilrefs(${PRODUCT})
    ssg_build_bash_remediations(${PRODUCT})
    ssg_build_ansible_remediations(${PRODUCT})
    ssg_build_xccdf_with_remediations(${PRODUCT})
    ssg_build_oval_unlinked(${PRODUCT})
    ssg_build_link_xccdf_oval_ocil(${PRODUCT})
    ssg_build_xccdf_final(${PRODUCT})
    ssg_build_oval_final(${PRODUCT})
    ssg_build_ocil_final(${PRODUCT})
    ssg_build_sds(${PRODUCT})
    ssg_build_html_guides(${PRODUCT})

    add_custom_target(
        ${PRODUCT} ALL
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-guide-index.html
    )
    add_custom_target(
        ${PRODUCT}-validate
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf.xml
        #DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-oval.xml
        #DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ocil.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ds.xml
        COMMENT "[${PRODUCT}] validating outputs"
    )
    add_dependencies(validate ${PRODUCT}-validate)
endmacro()

macro(ssg_build_derivative_product ORIGINAL SHORTNAME DERIVATIVE)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml
        COMMAND ${SSG_SHARED_UTILS}/enable-derivatives.py --enable-${SHORTNAME} -i ${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-xccdf.xml -o ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml
        MAIN_DEPENDENCY ${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-xccdf.xml
        DEPENDS ${SSG_SHARED_UTILS}/enable-derivatives.py
        COMMENT "[${DERIVATIVE}] generating ssg-${DERIVATIVE}-xccdf.xml"
    )
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-xccdf.xml
        COMMAND ${OSCAP_EXECUTABLE} xccdf validate ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml
        COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-xccdf.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml
        COMMENT "[${DERIVATIVE}] validating ssg-${DERIVATIVE}-xccdf.xml"
    )

    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml
        COMMAND ${SSG_SHARED_UTILS}/enable-derivatives.py --enable-${SHORTNAME} -i ${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds.xml -o ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml
        MAIN_DEPENDENCY ${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-ds.xml
        DEPENDS ${SSG_SHARED_UTILS}/enable-derivatives.py
        COMMENT "[${DERIVATIVE}] generating ssg-${DERIVATIVE}-ds.xml"
    )
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-ds.xml
        COMMAND ${OSCAP_EXECUTABLE} ds sds-validate ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml
        COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-ds.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml
        COMMENT "[${DERIVATIVE}] validating ssg-${DERIVATIVE}-ds.xml"
    )

    ssg_build_html_guides(${DERIVATIVE})

    add_custom_target(
        ${DERIVATIVE} ALL
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml
        # We use the original product's OVAL
        #DEPENDS ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-oval.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-guide-index.html
    )
    add_custom_target(
        ${DERIVATIVE}-validate
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-xccdf.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${DERIVATIVE}-ds.xml
        COMMENT "[${DERIVATIVE}] validating outputs"
    )
    add_dependencies(validate ${DERIVATIVE}-validate)
endmacro()
