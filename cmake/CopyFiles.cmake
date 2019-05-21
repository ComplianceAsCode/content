file(GLOB CSOURCE ${SOURCE})
FOREACH(file_to_copy ${CSOURCE})
        execute_process(COMMAND "${CMAKE_COMMAND}" -E copy ${file_to_copy} "${DEST}")
ENDFOREACH(file_to_copy)
