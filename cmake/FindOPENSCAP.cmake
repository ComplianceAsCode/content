set(OPENSCAP_POSSIBLE_ROOT_DIRS
    "${OPENSCAP_ROOT_DIR}"
    "$ENV{OPENSCAP_ROOT_DIR}"
    "$ENV{ProgramFiles}"
    "/usr/local/share"
    "/usr/share/"
    "/usr/local"
    "/usr"
    "/usr/bin"
    "/usr/sbin"
    "/opt"
    "/opt/local"
)

foreach(NAME ${OPENSCAP_POSSIBLE_ROOT_DIRS})
    FIND_FILE(OSCAP_XCCDF_XSL_1_2 NAMES xccdf_1.1_to_1.2.xsl
        PATHS "${NAME}"
        PATH_SUFFIXES "share/openscap/xsl/"
    )
endforeach()

foreach(NAME ${OPENSCAP_POSSIBLE_ROOT_DIRS})
    FIND_PROGRAM(OSCAP_EXECUTABLE NAMES oscap
        PATHS "${NAME}"
        PATH_SUFFIXES "bin/"
    )
endforeach()

if (NOT EXISTS "${OSCAP_XCCDF_XSL_1_2}")
    MESSAGE(SEND_ERROR
            "ERROR: The OPENSCAP XSL XCCDF file was not found. Please specify the OPENSCAP ROOT DIR with the OPENSCAP_ROOT_DIR environment variable.")
endif()

if (NOT EXISTS "${OSCAP_EXECUTABLE}")
    MESSAGE(SEND_ERROR
            "ERROR: The OPENSCAP executable was not found. Please specify the OPENSCAP ROOT DIR with the OPENSCAP_ROOT_DIR environment variable.")
endif()
