include_directories(${QE_INCLUDE_DIRS})
set(src_qe_koopmans_utils
    cp_files.f90
    epsilon.f90
    fft_supercell.f90
    merge_evc.f90
    plot_wan2kcp.f90
    read_wannier.f90
    scell_wfc.f90
    wann2kcp.f90
    wannier2kcp.f90
    wannier.f90)

message (STATUS "${libqe_modules}")

qe_add_library(qe_koopmans_utils ${src_qe_koopmans_utils})
# target_link_libraries(qe_koopmans_utils)
#     PUBLIC
#         libqe_modules)

###########################################################
# merge_evc.x
###########################################################
set(src_merge_evc_x merge_evc.f90)
qe_add_executable(qe_merge_evc_exe ${src_merge_evc_x})
set_target_properties(qe_merge_evc_exe PROPERTIES OUTPUT_NAME merge_evc.x)
target_link_libraries(qe_merge_evc_exe PRIVATE qe_koopmans_utils)
