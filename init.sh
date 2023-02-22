./disk_setup.sh
echo "disk setup done"
sleep 3
./bootstrap.sh
echo "bootstrap done"
sleep 3
./pg_setup.sh
echo "postgres setup done"
sleep 1
source ~/.bashrc_exports
