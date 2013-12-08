#!/bin/bash

rm -r lamamos
mkdir lamamos

cp /etc/lamamos/lamamos.conf lamamos/
cp /etc/lamamos/authkey lamamos/
cp -r /etc/lamamos/rex lamamos/

echo "done"
