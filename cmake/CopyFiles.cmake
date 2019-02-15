file(GLOB CFILES ${FILES})
FOREACH(file_to_copy ${CFILES})
        execute_process(COMMAND "${CMAKE_COMMAND}" -E copy ${file_to_copy} "${PATH}")
ENDFOREACH(file_to_copy)
