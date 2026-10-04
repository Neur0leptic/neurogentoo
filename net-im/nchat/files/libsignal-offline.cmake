# The exact-version Portage dependency supplies the ABI-matched static archive.
if(NOT EXISTS "${NEUROGENTOO_LIBSIGNAL_FFI}")
  message(FATAL_ERROR "The declared libsignal-ffi dependency is missing")
endif()
file(MAKE_DIRECTORY "${LIBSIGNAL_FFI_DIR}")
configure_file("${NEUROGENTOO_LIBSIGNAL_FFI}" "${LIBSIGNAL_FFI_FILE}" COPYONLY)
