Creando VMs con ``qemu-system-x86_64``
======================================

.. contents:: Table of Contents  

``qemu-system-<architecture>``, por ejemplo ``/usr/local/bin/qemu-system-x86_64``, sirve para correr un sistema de esa arquitectura en la máquina host.

Podemos usar ``qemu-system-x86_64`` para correr una máquina virtual y con el parámetro ``-enable-kvm`` podemos habilitar el soporte de KVM full virtualization. 

Ejemplos de sintáxis
--------------------

.. code-block:: bash

    $ sudo qemu-system-x86_64 [-enable-kvm] -name [cirrOS-X] -hda [cirros-0.4.0-x86_64-disk.img] -smp [1] -m [64] -netdev tap,id=[mynet0],ifname=[tap0] -device [e1000|virtio-net-pci],netdev=[mynet0],mac=[52:55:00:d1:55:01] 

Ejemplo:

.. code-block:: bash

    sudo qemu-system-x86_64 -enable-kvm -name vm1 -hda cirros-0.4.0-x86_64-disk.img &

Referencias
-----------

- `Using bare qemu-kvm vs libvirt virt-install virt-manager`_
- `Difference between qemu-kvm qemu-system-x86_64 qemu-x86_64`_

.. _Using bare qemu-kvm vs libvirt virt-install virt-manager: https://www.stratoscale.com/blog/compute/using-bare-qemu-kvm-vs-libvirt-virt-install-virt-manager/
.. _Difference between qemu-kvm qemu-system-x86_64 qemu-x86_64: https://serverfault.com/questions/767212/difference-between-qemu-kvm-qemu-system-x86-64-qemu-x86-64