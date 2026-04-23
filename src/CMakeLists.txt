include_directories(${QE_INCLUDE_DIRS})

set(src_qe_koopmans_utils
    cp_files.f90
    fft_supercell.f90
    modified_wannier.f90
    plot_wan2kcp.f90
    read_wannier.f90
    scell_wfc.f90
    wannier2kcp.f90)

# Use qe_add_library (not plain add_library) so that QE's global compile
# definitions (-D__MPI, -D__HDF5, -D__DFTI, …) reach the preprocessor when
# compiling the files below. Without this, `#if defined(__MPI)` blocks in
# e.g. scell_wfc.f90 get stripped out and the library silently takes the
# serial code path even inside a parallel build.
qe_add_library(qe_koopmans_utils ${src_qe_koopmans_utils})
# target_link_libraries(qe_koopmans_utils INTERFACE ${QE_LIBRARIES})

###########################################################
# merge_evc.x
###########################################################
set(src_merge_evc_x merge_evc.f90)
qe_add_executable(qe_merge_evc_exe ${src_merge_evc_x})
set_target_properties(qe_merge_evc_exe PROPERTIES OUTPUT_NAME merge_evc.x)
target_link_libraries(qe_merge_evc_exe)

###########################################################
# wann2kcp.x
###########################################################

set(src_wann2kcp_x wann2kcp.f90)
qe_add_executable(qe_wann2kcp_exe ${src_wann2kcp_x})
set_target_properties(qe_wann2kcp_exe PROPERTIES OUTPUT_NAME wann2kcp.x)
target_link_libraries(qe_wann2kcp_exe PRIVATE qe_koopmans_utils ${QE_LIBRARIES} qe_lapack qe_mpi_fortran qe_openmp_fortran qe_hdf5_fortran qe_ext_fft)

###########################################################
# epsilon.x
###########################################################
set(src_epsilon_x epsilon.f90)
qe_add_executable(qe_epsilon_exe ${src_epsilon_x})
set_target_properties(qe_epsilon_exe PROPERTIES OUTPUT_NAME epsilon.x)
target_link_libraries(qe_epsilon_exe PRIVATE qe_koopmans_utils ${QE_LIBRARIES} qe_lapack qe_mpi_fortran qe_openmp_fortran qe_hdf5_fortran qe_ext_fft)

qe_install_targets(qe_merge_evc_exe qe_wann2kcp_exe qe_epsilon_exe)
