#!/bin/bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

run solaar -w hide
run nm-applet
run caffeine-indicator
run mate-volume-control-status-icon
run numlockx on
run parcellite
run /home/berus/.fehbg
run gammastep-indicator
run /usr/libexec/polkit-mate-authentication-agent-1
