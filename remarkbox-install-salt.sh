HOSTNAME=`mdata-get hostname`
MASTER=`mdata-get master`

hostname $HOSTNAME
echo "$HOSTNAME" > /etc/hostname

wget -O install_salt.sh https://bootstrap.saltstack.com
sudo sh install_salt.sh

echo "$HOSTNAME" > /etc/salt/minion_id
echo "master: $MASTER" > /etc/salt/minion.d/custom.conf

service salt-minion restart
