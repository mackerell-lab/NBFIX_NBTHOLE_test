#!/bin/bash

#conda activate ommsimu


for method in switch ljpme
do

cd charmm_test
rm output_*.out

/opt/mackerell/apps/charmm/serial/charmm-c49b1-serial-ljpme -i ener_${method}.inp -o ener_${method}.out

echo "Generated Output_CHARMM_$method.out"
cd ../
done
