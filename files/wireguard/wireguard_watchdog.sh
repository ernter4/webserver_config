#!/bin/bash
while true; do
    if ! ping -c 1 192.168.0.1 >/dev/null 2>&1; then
        systemctl restart wg-quick@wg0
    fi
    sleep 5
done