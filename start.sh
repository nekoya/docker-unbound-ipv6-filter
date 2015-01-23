#!/bin/bash
service bind9 start
service unbound start

trap 'service unbound stop; service bind9 stop; exit 0' TERM

while true; do
    sleep 1
done
