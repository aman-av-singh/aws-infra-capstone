#!/bin/bash
sleep 60
for i in 1 2 3 4 5; do
  timeout 120 yes > /dev/null
  sleep 120
done &
