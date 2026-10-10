#!/bin/bash

# Get ALL active VPN IPs on utun interfaces (Ignoring Tailscale 100.x)
ALL_VPN_IPS=$(ifconfig 2>/dev/null | awk '/^[a-z]/ {iface=$1} /inet / {if (iface ~ /^utun/ && $2 !~ /^100\./) print $2}')

if [ -n "$ALL_VPN_IPS" ]; then
    # Spy on the OpenVPN process to see what config file it is running
    if ps aux | grep -iE '[o]penvpn.*(htb|hackthebox|academy|starting_point|release_arena)' >/dev/null; then
        # HTB always uses 10.10.x.x
        HTB_IP=$(echo "$ALL_VPN_IPS" | grep '^10\.10\.' | head -n 1)
        [ -n "$HTB_IP" ] && echo "HTB - $HTB_IP" || echo "HTB - $(echo "$ALL_VPN_IPS" | head -n 1)"
        
    elif ps aux | grep -iE '[o]penvpn.*(thm|tryhackme)' >/dev/null; then
        # THM uses 10.10, 10.9, 10.8, 10.13, etc. Filter out Proton's common 10.2
        THM_IP=$(echo "$ALL_VPN_IPS" | grep -v '^10\.2\.' | head -n 1)
        [ -n "$THM_IP" ] && echo "THM - $THM_IP" || echo "THM - $(echo "$ALL_VPN_IPS" | head -n 1)"
        
    elif ps aux | grep -iE '[o]penvpn.*(oscp|offsec|pg_|proving|play|practice)' >/dev/null; then
        # OffSec uses 192.168.x.x or 10.11.x.x. Filter out Proton's 10.2
        OFF_IP=$(echo "$ALL_VPN_IPS" | grep -v '^10\.2\.' | head -n 1)
        [ -n "$OFF_IP" ] && echo "OffSec - $OFF_IP" || echo "OffSec - $(echo "$ALL_VPN_IPS" | head -n 1)"
        
    else
        # Fallback if no recognizable OpenVPN profile is running (e.g. just ProtonVPN)
        echo "VPN - $(echo "$ALL_VPN_IPS" | head -n 1)"
    fi
else
    echo "VPN - Disconnected"
fi
