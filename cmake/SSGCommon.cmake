set(SSG_SHARED "${CMAKE_SOURCE_DIR}/shared")
set(SSG_SHARED_REFS "${SSG_SHARED}/references")
set(SSG_SHARED_TRANSFORMS "${SSG_SHARED}/transforms")
set(SSG_SHARED_UTILS "${SSG_SHARED}/utils")
set(SSG_VENDOR "ssgproject")

set(OSCAP_OVAL_511_SUPPORT 0)

if(OSCAP_OVAL_511_SUPPORT EQUAL 0)
    set(OSCAP_OVAL_VERSION "oval_5.11")
else()
    set(OSCAP_OVAL_VERSION "oval_5.10")
endif()

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

macro(ssg_build_remediations PRODUCT)
    file(GLOB BASH_REMEDIATION_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/templates/output/bash/*")
    file(GLOB SHARED_BASH_REMEDIATION_DEPS "${SSG_SHARED}/templates/output/bash/*")
    set(BUILD_REMEDIATIONS_DIR "${CMAKE_CURRENT_BINARY_DIR}/remediations")

    # TODO: The environment variable is not very portable
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/bash-remediations.xml
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/generate-from-templates.py --oval_version ${OSCAP_OVAL_VERSION} --input ${CMAKE_CURRENT_SOURCE_DIR}/templates --output ${BUILD_REMEDIATIONS_DIR} --language bash build
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/generate-from-templates.py --oval_version ${OSCAP_OVAL_VERSION} --input ${SSG_SHARED}/templates --output ${BUILD_REMEDIATIONS_DIR}/shared/ --language bash build
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/combine-remediations.py ${PRODUCT} bash ${BUILD_REMEDIATIONS_DIR}/shared/bash ${SSG_SHARED}/templates/static/bash ${BUILD_REMEDIATIONS_DIR}/bash ${CMAKE_CURRENT_SOURCE_DIR}/templates/static/bash ${CMAKE_CURRENT_BINARY_DIR}/bash-remediations.xml
        DEPENDS ${BASH_REMEDIATION_DEPS} ${SHARED_BASH_REMEDIATION_DEPS}
        DEPENDS ${SSG_SHARED_UTILS}/combine-remediations.py
        COMMENT "[${PRODUCT}] generating bash-remediations.xml"
    )

    file(GLOB ANSIBLE_REMEDIATION_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/templates/output/ansible/*")
    file(GLOB SHARED_ANSIBLE_REMEDIATION_DEPS "${SSG_SHARED}/templates/output/ansible/*")

    # TODO: The environment variable is not very portable
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/ansible-remediations.xml
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/generate-from-templates.py --oval_version ${OSCAP_OVAL_VERSION} --input ${CMAKE_CURRENT_SOURCE_DIR}/templates --output ${BUILD_REMEDIATIONS_DIR} --language ansible build
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/generate-from-templates.py --oval_version ${OSCAP_OVAL_VERSION} --input ${SSG_SHARED}/templates --output ${BUILD_REMEDIATIONS_DIR}/shared/ --language ansible build
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/combine-remediations.py ${PRODUCT} ansible ${BUILD_REMEDIATIONS_DIR}/shared/ansible ${SSG_SHARED}/templates/static/ansible ${BUILD_REMEDIATIONS_DIR}/ansible ${CMAKE_CURRENT_SOURCE_DIR}/templates/static/ansible ${CMAKE_CURRENT_BINARY_DIR}/ansible-remediations.xml
        DEPENDS ${ANSIBLE_REMEDIATION_DEPS} ${SHARED_ANSIBLE_REMEDIATION_DEPS}
        DEPENDS ${SSG_SHARED_UTILS}/combine-remediations.py
        COMMENT "[${PRODUCT}] generating ansible-remediations.xml"
    )

    file(GLOB PUPPET_REMEDIATION_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/templates/output/puppet/*")
    file(GLOB SHARED_PUPPET_REMEDIATION_DEPS "${SSG_SHARED}/templates/output/puppet/*")

    # TODO: The environment variable is not very portable
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/puppet-remediations.xml
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/generate-from-templates.py --oval_version ${OSCAP_OVAL_VERSION} --input ${CMAKE_CURRENT_SOURCE_DIR}/templates --output ${BUILD_REMEDIATIONS_DIR} --language puppet build
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/generate-from-templates.py --oval_version ${OSCAP_OVAL_VERSION} --input ${SSG_SHARED}/templates --output ${BUILD_REMEDIATIONS_DIR}/shared/ --language puppet build
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/combine-remediations.py ${PRODUCT} puppet ${BUILD_REMEDIATIONS_DIR}/shared/puppet ${SSG_SHARED}/templates/static/puppet ${BUILD_REMEDIATIONS_DIR}/puppet ${CMAKE_CURRENT_SOURCE_DIR}/templates/static/puppet ${CMAKE_CURRENT_BINARY_DIR}/puppet-remediations.xml
        DEPENDS ${PUPPET_REMEDIATION_DEPS} ${SHARED_PUPPET_REMEDIATION_DEPS}
        DEPENDS ${SSG_SHARED_UTILS}/combine-remediations.py
        COMMENT "[${PRODUCT}] generating puppet-remediations.xml"
    )

    file(GLOB ANACONDA_REMEDIATION_DEPS "${CMAKE_CURRENT_SOURCE_DIR}/templates/output/anaconda/*")
    file(GLOB SHARED_ANACONDA_REMEDIATION_DEPS "${SSG_SHARED}/templates/output/anaconda/*")

    # TODO: The environment variable is not very portable
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/anaconda-remediations.xml
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/generate-from-templates.py --oval_version ${OSCAP_OVAL_VERSION} --input ${CMAKE_CURRENT_SOURCE_DIR}/templates --output ${BUILD_REMEDIATIONS_DIR} --language anaconda build
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/generate-from-templates.py --oval_version ${OSCAP_OVAL_VERSION} --input ${SSG_SHARED}/templates --output ${BUILD_REMEDIATIONS_DIR}/shared/ --language anaconda build
        COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/combine-remediations.py ${PRODUCT} anaconda ${BUILD_REMEDIATIONS_DIR}/shared/anaconda ${SSG_SHARED}/templates/static/anaconda ${BUILD_REMEDIATIONS_DIR}/anaconda ${CMAKE_CURRENT_SOURCE_DIR}/templates/static/anaconda ${CMAKE_CURRENT_BINARY_DIR}/anaconda-remediations.xml
        DEPENDS ${ANACONDA_REMEDIATION_DEPS} ${SHARED_ANACONDA_REMEDIATION_DEPS}
        DEPENDS ${SSG_SHARED_UTILS}/combine-remediations.py
        COMMENT "[${PRODUCT}] generating anaconda-remediations.xml"
    )
endmacro()

macro(ssg_build_xccdf_with_remediations PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml ${CMAKE_CURRENT_BINARY_DIR}/remediations
        COMMAND ${XSLTPROC_EXECUTABLE} --stringparam bash_remediations ${CMAKE_CURRENT_BINARY_DIR}/bash-remediations.xml --stringparam ansible_remediations ${CMAKE_CURRENT_BINARY_DIR}/ansible-remediations.xml --stringparam puppet_remediations ${CMAKE_CURRENT_BINARY_DIR}/puppet-remediations.xml --stringparam anaconda_remediations ${CMAKE_CURRENT_BINARY_DIR}/anaconda-remediations.xml --output ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml ${SSG_SHARED_TRANSFORMS}/xccdf-addremediations.xslt ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml
        COMMAND ${XMLLINT_EXECUTABLE} --format --output ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml
        MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-ocilrefs.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/bash-remediations.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/ansible-remediations.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/puppet-remediations.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/anaconda-remediations.xml
        DEPENDS ${SSG_SHARED_TRANSFORMS}/xccdf-addremediations.xslt
        COMMENT "[${PRODUCT}] generating xccdf-unlinked.xml"
    )
endmacro()

macro(ssg_build_oval_unlinked PRODUCT)
    set(OVAL_DEPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/input/oval")
    file(GLOB OVAL_DEPS "${OVAL_DEPS_DIR}/*.xml")
    set(SHARED_OVAL_DEPS_DIR "${SSG_SHARED}/oval")
    file(GLOB SHARED_OVAL_DEPS "${SHARED_OVAL_DEPS_DIR}/*.xml")
    set(OVAL_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/oval")

    if(OSCAP_OVAL_511_SUPPORT EQUAL 0)
        set(OVAL_511_DEPS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/input/oval/${OSCAP_OVAL_VERSION}")
        file(GLOB OVAL_511_DEPS "${OVAL_511_DEPS_DIR}/*.xml")
        set(SHARED_OVAL_511_DEPS_DIR "${SSG_SHARED}/oval/${OSCAP_OVAL_VERSION}")
        file(GLOB SHARED_OVAL_511_DEPS "${SHARED_OVAL_511_DEPS_DIR}/*.xml")

        add_custom_command(
            OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml ${CMAKE_CURRENT_BINARY_DIR}/oval
            # TODO: config
            COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/generate-from-templates.py --oval_version ${OSCAP_OVAL_VERSION} --input ${CMAKE_CURRENT_SOURCE_DIR}/templates --output ${CMAKE_CURRENT_BINARY_DIR}/ --language oval build
            COMMAND RUNTIME_OVAL_VERSION=5.11 ${SSG_SHARED_UTILS}/combine-ovals.py ${CMAKE_SOURCE_DIR}/config ${PRODUCT} ${SHARED_OVAL_DEPS_DIR} ${OVAL_DEPS_DIR} ${SHARED_OVAL_511_DEPS_DIR} ${OVAL_511_DEPS_DIR} ${OVAL_BUILD_DIR} > ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
            COMMAND ${XMLLINT_EXECUTABLE} --format --output ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
            DEPENDS ${OVAL_DEPS}
            DEPENDS ${OVAL_511_DEPS}
            DEPENDS ${SHARED_OVAL_DEPS}
            DEPENDS ${SHARED_OVAL_511_DEPS}
            DEPENDS ${SSG_SHARED_UTILS}/combine-ovals.py
            VERBATIM
            COMMENT "[${PRODUCT}] generating oval-unlinked.xml (OVAL 5.11 checks enabled)"
        )
    else()
        add_custom_command(
            OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml ${CMAKE_CURRENT_BINARY_DIR}/oval
            # TODO: config
            COMMAND SHARED=${SSG_SHARED} ${SSG_SHARED_UTILS}/generate-from-templates.py --oval_version ${OSCAP_OVAL_VERSION} --input ${CMAKE_CURRENT_SOURCE_DIR}/templates --output ${CMAKE_CURRENT_BINARY_DIR}/ --language oval build
            COMMAND ${SSG_SHARED_UTILS}/combine-ovals.py ${CMAKE_SOURCE_DIR}/config ${PRODUCT} ${OVAL_DEPS_DIR} ${SHARED_OVAL_DEPS_DIR} ${OVAL_BUILD_DIR} > ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
            COMMAND ${XMLLINT_EXECUTABLE} --format --output ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
            DEPENDS ${OVAL_DEPS}
            DEPENDS ${SHARED_OVAL_DEPS}
            DEPENDS ${SSG_SHARED_UTILS}/combine-ovals.py
            VERBATIM
            COMMENT "[${PRODUCT}] generating oval-unlinked.xml (OVAL 5.11 checks disabled)"
        )
    endif()
endmacro()

macro(ssg_build_cpe_dictionary PRODUCT)
    set(SSG_CPE_DICTIONARY "${CMAKE_CURRENT_SOURCE_DIR}/input/oval/platform/${PRODUCT}-cpe-dictionary.xml")

    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml
        COMMAND ${SSG_SHARED_UTILS}/cpe-generate.py ${PRODUCT} ssg ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml ${SSG_CPE_DICTIONARY}
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
        DEPENDS ${SSG_SHARED_UTILS}/cpe-generate.py
        COMMENT "[${PRODUCT}] generating ssg-${PRODUCT}-cpe-dictionary.xml, ssg-${PRODUCT}-cpe-oval.xml"
    )
endmacro()

macro(ssg_build_link_xccdf_oval_ocil PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/xccdf-linked.xml ${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml ${CMAKE_CURRENT_BINARY_DIR}/ocil-linked.xml
        COMMAND ${SSG_SHARED_UTILS}/relabel-ids.py ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml ssg
        MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/oval-unlinked.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/ocil-unlinked.xml
        DEPENDS ${SSG_SHARED_UTILS}/relabel-ids.py
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
        COMMAND ${XSLTPROC_EXECUTABLE} --stringparam reverse_DNS org.${SSG_VENDOR}.content --output ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml /usr/share/openscap/xsl/xccdf_1.1_to_1.2.xsl ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
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

macro(ssg_build_table_refs PRODUCT)
    # TODO: Figure out how to handle profiles as not all products use the same profiles
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/table-${PRODUCT}-nistrefs.html ${CMAKE_BINARY_DIR}/table-${PRODUCT}-cisrefs.html ${CMAKE_BINARY_DIR}/table-${PRODUCT}-nistrefs-common.html ${CMAKE_BINARY_DIR}/table-${PRODUCT}-nistrefs-ospp.html
        COMMAND ${XSLTPROC_EXECUTABLE} -stringparam ref "nist" --output ${CMAKE_BINARY_DIR}/table-${PRODUCT}-nistrefs.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-byref.xslt ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-empty-groups.xml
        COMMAND ${XSLTPROC_EXECUTABLE} -stringparam ref "cis" --output ${CMAKE_BINARY_DIR}/table-${PRODUCT}-cisrefs.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-byref.xslt ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-empty-groups.xml
        COMMAND ${XSLTPROC_EXECUTABLE} -stringparam profile "common" --output ${CMAKE_BINARY_DIR}/table-${PRODUCT}-nistrefs-common.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profilenistrefs.xslt ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-empty-groups.xml
        COMMAND ${XSLTPROC_EXECUTABLE} -stringparam profile "ospp-rhel7-server" --ouput ${CMAKE_BINARY_DIR}/table-${PRODUCT}-nistrefs-ospp.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profilenistrefs.xslt ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-empty-groups.xml
        COMMAND ${XSLTPROC_EXECUTABLE} -stringparam profile "C2S" --output ${CMAKE_BINARY_DIR}/table-${PRODUCT}-cisrefs-c2s.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profilecisrefs.xslt ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-empty-groups.xml
        COMMAND ${XSLTPROC_EXECUTABLE} -stringparam ref "pcidss" --output ${CMAKE_BINARY_DIR}/table-${PRODUCT}-pcidss.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-byref.xslt ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-empty-groups.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-empty-groups.xml
    )
endmacro()

macro(ssg_build_table_idents PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/table-${PRODUCT}-cces.html
        COMMAND ${XSLTPROC_EXECUTABLE} --output ${CMAKE_BINARY_DIR}/table-${PRODUCT}-cces.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-cce.xslt ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-empty-groups.xml
        COMMENT "[${PRODUCT}] generating table-${PRODUCT}-cces.html"
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-empty-groups.xml
    )
endmacro()

macro(ssg_build_table_srgmaps PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap.html ${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap-flat.html ${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap-flat.xhtml
        COMMAND ${XSLTPROC_EXECUTABLE} -stringparam map-to-items "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-empty-groups.xml" --output ${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt ${SSG_SHARED_REFS}/disa-os-srg-v1r4.xml
        COMMAND ${XSLTPROC_EXECUTABLE} -stringparam flat "y" -stringparam map-to-items "${CMAKE_CURRENT_BINARY_DIR}/xccdf-unlinked-empty-groups.xml" --ouput ${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap-flat.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/table-srgmap.xslt ${SSG_SHARED_REFS}/disa-os-srg-v1r4.xml
        COMMAND ${XMLLINT_EXECUTABLE} --xmlout --html --output ${CMAKE_CURRENT_BINARY_DIR}/table-${PRODUCT}-srgmap-flat.xhtml ${SSG_SHARED_REFS}/table-${PRODUCT}-srgmap-flat.html
        COMMENT "[${PRODUCT}] generating table-${PRODUCT}-srgmap.html, table-${PRODUCT}-srgmap-flat.html, table-${PRODUCT}-srgmap-flat.xhtml"
    )
endmacro()

macro(ssg_build_stig_tables PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/table-${PRODUCT}-stig.html ${CMAKE_BINARY_DIR}/table-stig-${PRODUCT}-testinfo.html ${CMAKE_BINARY_DIR}/unlinked-stig-${PRODUCT}-xccdf.xml
        COMMAND ${XSLTPROC_EXECUTABLE} --output ${CMAKE_BINARY_DIR}/table-${PRODUCT}-stig.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-stig.xslt ${SSG_SHARED_REFS}/disa-stig-${PRODUCT}-v1r0.2-xccdf-manual.xml
        #COMMAND ${XSLTPROC_EXECUTABLE} -stringparam notes "${CMAKE_CURRENT_SOURCE_DIR}/input/auxiliary/transition_notes.xml" --output ${CMAKE_BINARY_DIR}/table-${PRODUCT}-stig-manual-withnotes.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-stig.xslt ${SSG_SHARED_REFS}/disa-stig-${PRODUCT}-v1r0.2-xccdf-manual.xml
        # TODO: Need to handle multiple/different profiles for different products
        COMMAND ${XSLTPROC_EXECUTABLE} -stringparam profile "stig-${PRODUCT}-server" -stringparam testinfo "y" --output ${CMAKE_BINARY_DIR}/table-stig-${PRODUCT}-testinfo.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-profileccirefs.xslt
        COMMAND ${XSLTPROC_EXECUTABLE} -stringparam overlay "${CMAKE_CURRENT_SOURCE_DIR}/input/auxiliary/stig_overlay.xml" --output ${CMAKE_BINARY_DIR}/unlinked-stig-${PRODUCT}-xccdf.xml ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf-apply-overlay-stig.xslt
        COMMAND ${XSLTPROC_EXECUTABLE} --output ${CMAKE_BINARY_DIR}/table-${PRODUCT}-stig.html ${CMAKE_CURRENT_SOURCE_DIR}/transforms/xccdf2table-stig.xslt ${CMAKE_CURRENT_SOURCE_DIR}/unlinked-stig-${PRODUCT}-xccdf.xml
        COMMENT "[${PRODUCT}] generating table-${PRODUCT}-stig.html, table-stig-${PRODUCT}-testinfo.html, unlinked-stig-${PRODUCT}-xccdf.xml"
    )
endmacro()

macro(ssg_build_oval_final PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml
        MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/oval-linked.xml
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

macro(ssg_build_add_pci_dss_to_sds PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml
        COMMAND ${SSG_SHARED_TRANS}/pcidss/transform_benchmark_to_pcidss.py ${SSG_SHARED_TRANS}/pcidss/PCI_DSS.json ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml
        COMMAND ${OSCAP_EXECUTABLE} ds sds-add ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-pcidss-xccdf-1.2.xml ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        COMMENT "[${PRODUCT}] adding ssg-${PRODUCT}-pcidss-xccdf-1.2.xml to ssg-${PRODUCT}-ds.xml"
    )
endmacro()

macro(ssg_build_cpe_ocil_sds PRODUCT)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        COMMAND ${SED_EXECUTABLE} -i 's/schematron-version="[0-9].[0-9]"/schematron-version="1.2"/' ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        COMMAND ${OSCAP_EXECUTABLE} ds sds-add ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        COMMAND ${SSG_SHARED_UTILS}/sds-move-ocil-to-checks.py ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        COMMENT "[${PRODUCT}] adding ssg-${PRODUCT}-cpe-dictionary.xml to ssg-${PRODUCT}-ds.xml"
    )
endmacro()

macro(ssg_build_html_guides PRODUCT)
    FILE(GLOB SSG_PROD_GUIDES ${CMAKE_BINARY_DIR}/*.html)

    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-guide-index.html ${SSG_PROD_GUIDES}
        COMMAND ${SSG_SHARED_UTILS}/build-all-guides.py --input ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml --output ${CMAKE_BINARY_DIR}/ build
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
    ssg_build_remediations(${PRODUCT})
    ssg_build_xccdf_with_remediations(${PRODUCT})
    ssg_build_oval_unlinked(${PRODUCT})
    ssg_build_cpe_dictionary(${PRODUCT})
    ssg_build_link_xccdf_oval_ocil(${PRODUCT})
    ssg_build_xccdf_final(${PRODUCT})
    ssg_build_oval_final(${PRODUCT})
    ssg_build_ocil_final(${PRODUCT})
    ssg_build_sds(${PRODUCT})
    ssg_build_add_pci_dss_to_sds(${PRODUCT})
    ssg_build_cpe_ocil_sds(${PRODUCT})
    ssg_build_html_guides(${PRODUCT})

    add_custom_target(
        ${PRODUCT} ALL
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml
        DEPENDS ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-guide-index.html
    )
    add_custom_target(
        ${PRODUCT}-validate
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf.xml
        #DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-xccdf-1.2.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-oval.xml
        #DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ocil.xml
        DEPENDS ${CMAKE_BINARY_DIR}/validation-ssg-${PRODUCT}-cpe-dictionary.xml
        DEPENDS ${CMAKE_BINARY_DIR}/validation-ssg-${PRODUCT}-cpe-oval.xml
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/validation-ssg-${PRODUCT}-ds.xml
        COMMENT "[${PRODUCT}] validating outputs"
    )
    add_dependencies(validate ${PRODUCT}-validate)

    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-xccdf.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-oval.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ocil.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-ds.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-dictionary.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-cpe-oval.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")

    # This is a common cmake trick, we need the globbing to happen at build time
    # and not configure time.
    install(
       CODE "
           file(GLOB GUIDE_FILES ${CMAKE_BINARY_DIR}/ssg-${PRODUCT}-guide-*.html) \n
           file(INSTALL DESTINATION ${CMAKE_INSTALL_PREFIX}/${SSG_GUIDE_INSTALL_DIR}
           TYPE FILE FILES \${GUIDE_FILES}
       )"
    )
endmacro()

macro(ssg_build_derivative_product ORIGINAL SHORTNAME DERIVATIVE)
    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml
        COMMAND ${SSG_SHARED_UTILS}/enable-derivatives.py --enable-${SHORTNAME} -i ${CMAKE_BINARY_DIR}/ssg-${ORIGINAL}-xccdf.xml -o ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml
        DEPENDS ${ORIGINAL}
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
        DEPENDS ${ORIGINAL}
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

    install(FILES "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-xccdf.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")
    install(FILES "${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-ds.xml"
        DESTINATION "${SSG_CONTENT_INSTALL_DIR}")

    # This is a common cmake trick, we need the globbing to happen at build time
    # and not configure time.
    install(
       CODE "
       file(GLOB GUIDE_FILES ${CMAKE_BINARY_DIR}/ssg-${DERIVATIVE}-guide-*.html) \n
           file(INSTALL DESTINATION ${CMAKE_INSTALL_PREFIX}/${SSG_GUIDE_INSTALL_DIR}
           TYPE FILE FILES \${GUIDE_FILES}
       )"
    )
endmacro()
