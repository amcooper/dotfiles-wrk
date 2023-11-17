#!/bin/bash

notify-send "Systemd unit failure: $1" "The systemd unit $1 has failed"
