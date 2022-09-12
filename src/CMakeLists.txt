set(src_qe_utils
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

qe_add_library(qe_utils ${src_qe_utils})

target_link_libraries(
    qe_utils
    PRIVATE libqe_pp)

###########################################################
# merge_evc.x
###########################################################
set(src_merge_evc_x merge_evc.f90)
qe_add_executable(qe_merge_evc_exe ${src_merge_evc_x})
set_target_properties(qe_merge_evc_exe PROPERTIES OUTPUT_NAME merge_evc.x)
target_link_libraries(qe_merge_evc_exe PRIVATE libqe_pp)
