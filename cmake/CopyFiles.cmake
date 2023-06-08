# This script is used to overcome copy limitations of cmake 2.8.12
file(GLOB CSOURCE ${SOURCE})
foreach(file_to_copy ${CSOURCE})
    execute_process(COMMAND "${CMAKE_COMMAND}" -E copy ${file_to_copy} "${DEST}")
endforeach()
