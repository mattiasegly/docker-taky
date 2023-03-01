#!/bin/bash

if [ $TAKY_MODE = dps ]; then
echo "TAKY_MODE=dps, starting..."
taky_dps -c /taky/taky.conf -l debug

elif [ $TAKY_MODE = cot ]; then
echo "TAKY_MODE=cot, starting..."
taky -c /taky/taky.conf -d -l debug

else
echo "TAKY_MODE not correctly set, starting as TAKY_MODE=cot..."
taky -c /taky/taky.conf -d -l debug
fi
