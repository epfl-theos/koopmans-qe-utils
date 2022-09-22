koopmans-qe-utils
=================

Fortran utilities required for performing Koopmans calculations with `koopmans-kcp <https://github.com/epfl-theos/koopmans-kcp>`_, built on top of `Quantum ESPRESSO <https://www.quantum-espresso.org/>`_.

Specifically, these utilities are:

| ``merge_evc.x`` - a program for merging wavefunction files
| ``wann2kcp.x`` - a program for converting ``Wannier90`` files into a format readable by ``kcp.x``
| ``epsilon.x`` - a modified version of ``Quantum ESPRESSO``'s ``epsilon.x``

Installation
------------

First, ensure you have a local installation of ``Quantum ESPRESSO`` on your machine. See https://gitlab.com/QEF/q-e for how to do this.

Having installed ``Quantum ESPRESSO``, ``koopmans-qe-utils`` can then be installed with ``cmake``:

.. code-block:: bash

    mkdir build
    cd build
    cmake .. -DQE_ROOT=/path/to/q-e/
    make
    make install

or with ``make``:

.. code-block:: bash

    ./configure
    make QE_ROOT=/path/to/q-e/
    make install

Both ``cmake`` and ``./configure`` take the same arguments as they do for ``Quantum ESPRESSO``.

*N.B.* Use the same method (``cmake`` or ``make``) that you used to compile ``Quantum ESPRESSO``.

Contact
-------
Written and maintained by Edward Linscott, Riccardo De Gennaro, and Nicola Colonna (2020-)

For help and feedback email edward.linscott@gmail.com or post on our `Google group <https://groups.google.com/g/koopmans-users>`_
