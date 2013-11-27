#!/bin/bash

rm -r /etc/lamamos/rex
mkdir /etc/lamamos/rex
rm /etc/lamamos/lamamos.conf

cp lamamos/lamamos.conf /etc/lamamos/lamamos.conf
cp -r lamamos/rex /etc/lamamos/

echo "done"
