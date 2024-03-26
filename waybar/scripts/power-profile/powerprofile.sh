#!/usr/bin/env bash

# CMDs
power_profile=`asusctl profile -p`

# Options
balanced='Active profile is Balanced'
performance='Active profile is Performance'
quiet='Active profile is Quiet'

case ${power_profile} in
            $performance)
                        echo "Performance 󱑴 " # 100
                        ;;
            $balanced)
                        echo "Balanced 󱑳 " # 70
                        ;;
            $quiet)
                        echo "Quiet 󱑲 " # 40
                        ;;
esac
