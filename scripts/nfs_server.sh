# NFS

set -e

apt update >/dev/null 2>&1

mkdir -v /data
chown nobody:nogroup /data/
chmod 777 /data/
apt install -y nfs-kernel-server
echo "/data   192.168.60.0/24(rw,sync,no_subtree_check)" > /etc/exports

exportfs -a

service nfs-kernel-server restart

exit 0