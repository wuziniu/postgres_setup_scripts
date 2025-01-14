#!/usr/bin/env bash

## installs postgres, and sets up environment variables appropriately

echo "export PG_DATA_DIR=/pgfs/pg_data_dir" >> ~/.bashrc_exports
echo "export PGPORT=5432" >> ~/.bashrc_exports
echo "export PG_BUILD_DIR=/pgfs/build" >> ~/.bashrc_exports
source ~/.bashrc_exports
# also, set these for the current run

# clone postgres, and checkout appropriate branch
cd /pgfs/
wget https://ftp.postgresql.org/pub/source/v12.5/postgresql-12.5.tar.gz
tar xzvf postgresql-12.5.tar.gz
cd postgresql-12.5

sudo apt-get --assume-yes install libreadline-dev zlib1g-dev flex bison-devel \
  zlib-devel openssl-devel wget
sudo apt-get --assume-yes install build-essential libreadline-dev zlib1g-dev \
flex bison libxml2-dev libxslt-dev libssl-dev

./configure --enable-cassert --enable-debug --prefix $PG_BUILD_DIR CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer"

# now we can compile postgres (just need to do this first time we're linking
# with aqo)
cd /pgfs/postgresql-12.5
make -j4 -s
make install -j4 -s

#echo "export PG_BUILD_DIR=/pgfs/build" >> ~/.bashrc_exports
echo "alias startpg=\"$PG_BUILD_DIR/bin/postgres -D $PG_DATA_DIR -p $PGPORT\"" >> ~/.bashrc_exports
echo "export PATH=$PG_BUILD_DIR/bin:$PATH" >> ~/.bashrc_exports
export PATH=$PG_BUILD_DIR/bin:$PATH
$PG_BUILD_DIR/bin/initdb -D $PG_DATA_DIR

cp ~/postgres_setup_scripts/postgresql.conf $PG_DATA_DIR/
source ~/.bashrc_exports

pg_ctl -D $PG_DATA_DIR -l logfile start
echo "started postgres"


# setup pg_hint_plan
cd ~/
git clone https://github.com/ossc-db/pg_hint_plan.git -b REL12_1_3_7
cd pg_hint_plan
make
make install
echo "pg_hint set up"
