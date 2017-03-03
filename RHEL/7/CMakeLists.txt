set(PRODUCT "rhel7")
set(DISA_SRG_VERSION "v1r4")
set(DISA_STIG_VERSION "v1r0.2")

ssg_build_product(${PRODUCT})

ssg_build_html_table_by_ref(${PRODUCT} "nist")
ssg_build_html_table_by_ref(${PRODUCT} "cis")
ssg_build_html_table_by_ref(${PRODUCT} "cui")
ssg_build_html_table_by_ref(${PRODUCT} "pcidss")

ssg_build_html_nistrefs_table(${PRODUCT} "common")
ssg_build_html_nistrefs_table(${PRODUCT} "ospp-${PRODUCT}-server")
ssg_build_html_nistrefs_table(${PRODUCT} "C2S")

ssg_build_html_cce_table(${PRODUCT})

ssg_build_html_srgmap_tables(${PRODUCT} ${DISA_SRG_VERSION})

ssg_build_html_stig_tables(${PRODUCT} "stig-${PRODUCT}-server-upstream" ${DISA_STIG_VERSION})

if (SSG_CENTOS_DERIVATIVES_ENABLED)
    ssg_build_derivative_product(${PRODUCT} "centos" "centos7")
endif()
if (SSG_SCIENTIFIC_LINUX_DERIVATIVES_ENABLED)
    ssg_build_derivative_product(${PRODUCT} "sl" "sl7")
endif()
