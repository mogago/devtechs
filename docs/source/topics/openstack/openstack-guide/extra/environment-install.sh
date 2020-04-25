
# Verificar que el servicio de firewall esté desactivado
# systemctl status firewalld
# sudo firewall-cmd --state

# Environment Networking:
# https://docs.openstack.org/install-guide/environment-networking-controller.html
# https://docs.openstack.org/install-guide/environment-networking-compute.html
# https://docs.openstack.org/install-guide/environment-networking-storage-cinder.html

# ===========================
# Network Time Protocol (NTP)
# ===========================
# https://docs.openstack.org/install-guide/environment-ntp.html

# (CONTROLLER)
# https://docs.openstack.org/install-guide/environment-ntp-controller.html

# Verificar que el servicio de firewall esté desactivado
# systemctl status firewalld

# Instalar el programa chrony:
sudo -i
yum install -y chrony

# Editar el archivo de configuración de chrony:
cat << EOF >> /etc/chrony.conf
allow 10.1.1.0/24
EOF

# Reiniciar el servicio de NTP:
systemctl restart chronyd.service

# ===============================================

# (COMPUTE, BLOCK)
# https://docs.openstack.org/install-guide/environment-ntp-other.html

# Instalar el programa chrony:
sudo -i
yum install -y chrony

# Configurar el nodo controller como servidor NTP:
cat << EOF >> /etc/chrony.conf
server controller iburst
EOF

# Comentar las líneas con los otros servidores NTP:
sed -i 's/server 0.centos.pool.ntp.org iburst/#server 0.centos.pool.ntp.org iburst/g' /etc/chrony.conf
sed -i 's/server 1.centos.pool.ntp.org iburst/#server 1.centos.pool.ntp.org iburst/g' /etc/chrony.conf
sed -i 's/server 2.centos.pool.ntp.org iburst/#server 2.centos.pool.ntp.org iburst/g' /etc/chrony.conf
sed -i 's/server 3.centos.pool.ntp.org iburst/#server 3.centos.pool.ntp.org iburst/g' /etc/chrony.conf

# Reiniciar el servicio de NTP:
systemctl restart chronyd.service

# ===============================================

# (ALL)
# https://docs.openstack.org/install-guide/environment-ntp-verify.html

# Verificar que el nodo controller se sincronice con servidores externos y los demás nodos se sincronicen con el controller:
chronyc sources

# ====================
# Environment packages
# ====================
# https://docs.openstack.org/install-guide/environment-packages-rdo.html

# (ALL)

# Verificar la versión de kernel actual
uname -mrs
# Verificar los kernels instalados en el sistema (el kernel subrayado es el que está en uso)
yum list installed kernel

# Habilitar el repositorio de OpenStack Train
yum install -y centos-release-openstack-train

# Actualizar los paquetes
yum update -y

# Verificar si se ha descargado un kernel más nuevo:
yum list installed kernel

# Upgrade de los paquetes:
yum upgrade -y

# Reiniciar el sistema en caso se haya descargado un nuevo kernel:
reboot

# Verificar que estamos usando el nuevo kernel descargado:
sudo -i
uname -mrs

# Instalar el cliente de OpenStack (No existe python3-openstackclient en yum)
yum install -y python-openstackclient

# Instalar el paquete para SELinux
yum install -y openstack-selinux

# Instalar otros paquetes adicionales
yum install -y crudini vim curl

# ============
# SQL Database
# ============
# https://docs.openstack.org/install-guide/environment-sql-database-rdo.html

# (CONTROLLER)

# Instalar la base de datos SQL, en nuestro caso ``mariadb``:
yum install -y mariadb mariadb-server python2-PyMySQL

# Crear y editar el archivo de configuración de MariaDB:
cat << EOF > /etc/my.cnf.d/openstack.cnf
[mysqld]
bind-address = 10.1.1.11

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF

# Habilitar e iniciar el servicio de base de datos:
systemctl enable mariadb.service
systemctl start mariadb.service

# Asegurar el servicios de base de datos:
mysql_secure_installation

# Enter current password for root (enter for none):
# Set root password? [Y/n]
# New password: openstack
# Re-enter new password: openstack
# Remove anonymous users? [Y/n]
# Disallow root login remotely? [Y/n] n
# Remove test database and access to it? [Y/n]
# Reload privilege tables now? [Y/n]

# =======================
# Message Queue - RabitMQ
# =======================
# https://docs.openstack.org/install-guide/environment-messaging-rdo.html

# (CONTROLLER)

# Instalar el paquete de RabbitMQ:
yum -y install rabbitmq-server

# Habilitar e iniciar el servicio de cola de mensajería:
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service

# Añadir el usuario a RabbitMQ (rabbitmqctl add_user openstack RABBIT_PASS):
rabbitmqctl add_user openstack openstack

# Configurar los permisos para el usuario openstack:
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

# =========
# Memcached
# =========
# https://docs.openstack.org/install-guide/environment-memcached-rdo.html

# (CONTROLLER)

# Instalar el paquete de Memcached:
yum install -y memcached python-memcached

# Cambiar '-l 127.0.0.1' por '-l 10.1.1.11' en el archivo /etc/sysconfig/memcached
sed -i 's/-l 127.0.0.1/-l 10.1.1.11/g' /etc/sysconfig/memcached

# Habilitar e iniciar el servicio Memcached
systemctl enable memcached.service
systemctl start memcached.service

# ====
# Etcd
# ====
# https://docs.openstack.org/install-guide/environment-etcd-rdo.html

# (CONTROLLER)

# Instalar el paquete de etcd:
yum install -y etcd

# Editar el archivo /etc/etcd/etcd.conf
cat << EOF >> /etc/etcd/etcd.conf
#[Member]
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://10.1.1.11:2380"
ETCD_LISTEN_CLIENT_URLS="http://10.1.1.11:2379"
ETCD_NAME="controller"
#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.1.1.11:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://10.1.1.11:2379"
ETCD_INITIAL_CLUSTER="controller=http://10.1.1.11:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF

# Habilitar e iniciar el servicio etcd
systemctl enable etcd
systemctl start etcd
