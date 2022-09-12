koopmans-qe-utils
=================

Fortran utilities required for performing Koopmans calculations with `koopmans-kcp <https://github.com/epfl-theos/koopmans-kcp>`_.

Specifically, these utilities are:

| ``merge_evc.x`` - a program for merging evc wavefunction files
| ``wann2kcp.x`` - a program for converting wannier90 files into a format readable by kcp.x
| ``epsilon.x`` - a modified version of Quantum ESPRESSO's epsilon.x

These utilities are dependent a local Quantum ESPRESSO installation.

Installation
------------

.. code-block:: bash

    mkdir build
    cd build
    cmake ..
    make
    make install

Contact
-------
Written and maintained by Edward Linscott, Riccardo De Gennaro, and Nicola Colonna (2020-)

For help and feedback email edward.linscott@gmail.com
