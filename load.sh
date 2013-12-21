#!/bin/bash
git pull

rm -r /etc/lamamos/rex
mkdir /etc/lamamos/rex
rm /etc/lamamos/lamamos.conf

cp lamamos/lamamos.conf /etc/lamamos/lamamos.conf
cp lamamos/authkey /etc/lamamos/authkey
cp -r lamamos/rex /etc/lamamos/

echo "done"
