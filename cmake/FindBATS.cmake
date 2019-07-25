set(BATS_POSSIBLE_ROOT_DIRS
   "/usr"
   "/usr/bin"
   "/usr/sbin"
   "/usr/local"
   "/usr/share"
   "/usr/local/share"
)

foreach(NAME ${BATS_POSSIBLE_ROOT_DIRS})
    FIND_PROGRAM(BATS_EXECUTABLE NAMES bats
        PATHS "${NAME}"
    )
endforeach()
