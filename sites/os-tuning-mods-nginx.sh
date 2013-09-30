echo 'fs.file-max=65535' >> /etc/sysctl.conf
echo 'net.ipv4.ip_local_port_range = 1024 65000' >> /etc/sysctl.conf
sysctl -p
echo '* soft nofile 65536' >> /etc/security/limits.conf
echo '* hard nofile 65536' >> /etc/security/limits.conf
echo 'session required pam_limits.so' >> /etc/pam.d/login
ulimit -n 65536
ulimit -n -H
echo 1 > /proc/sys/net/ipv4/tcp_tw_reuse
echo '10240' > /proc/sys/net/core/somaxconn
