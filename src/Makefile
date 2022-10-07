# Makefile for Koopmans utils
#include ../make.inc

# Make sure we have a make.inc from QE
ifneq (,$(wildcard $(QE_ROOT)/make.inc))
    -include $(QE_ROOT)/make.inc
endif


# location of needed modules and included files (if any)
MODFLAGS= $(BASEMOD_FLAGS) \
          $(MOD_FLAG)$(QE_ROOT)/PW/src \
          $(MOD_FLAG)$(QE_ROOT)/Modules/ \
          $(MOD_FLAG)$(QE_ROOT)/dft-d3/


PWOBJS = $(QE_ROOT)/PW/src/libpw.a $(QE_ROOT)/KS_Solvers/libks_solvers.a $(QE_ROOT)/dft-d3/libdftd3qe.a $(QE_ROOT)/PP/src/libpp.a
QEMODS = $(BASEMODS)

WAN2KCP_OBJS = modified_wannier.o read_wannier.o fft_supercell.o scell_wfc.o plot_wan2kcp.o \
               cp_files.o wannier2kcp.o

MODULES = $(PWOBJS) $(QEMODS)

all: checkmake pwlib pplib wann2kcp.x

checkmake:
	- test -f $(QE_ROOT)/make.inc || (echo 'Could not find $(QE_ROOT)/make.inc. Please configure your Quantum ESPRESSO installation first.'; exit 1)

pwlib:
	cd $(QE_ROOT)/ ; $(MAKE) pwlibs || exit 1

pplib:
	cd $(QE_ROOT)/ ; $(MAKE) pp || exit 1

wann2kcp.x: wann2kcp.o $(WAN2KCP_OBJS) $(MODULES) $(LIBOBJS)
	$(LD) $(LDFLAGS) -o $@ \
		wann2kcp.o $(WAN2KCP_OBJS) $(MODULES) $(LIBOBJS) $(QELIBS)
	- ( cd ../bin ; ln -fs ../src/$@ . )

clean:
	- /bin/rm -f *.x *.o *~ *_tmp.f90 *.d *.mod *.i *.L *genmod*

include make.depend
