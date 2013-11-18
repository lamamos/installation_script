#!/bin/bash

rm -r lamamos
mkdir lamamos

cp /etc/lamamos/lamamos.conf lamamos/
cp -r /etc/lamamos/rex lamamos/

echo "done"
