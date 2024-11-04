#!/bin/bash

#conda activate ommsimu


for method in switch ljpme
do

cd openmm_test
rm Output_ene_comp*.txt
python openmm_components_${method}.py  >/dev/null 2>error.log
python openmm_components_${method}_zero.py >/dev/null 2>error.log


# Extract the second value of the 9th line from both files
val1=$(awk 'NR==9 {print $2}' Output_ene_comp.txt)
val2=$(awk 'NR==9 {print $2}' Output_ene_comp_zero.txt)

# Perform the subtraction
ele_val=$(echo "$val1 - $val2" | bc)

# Print the subtracted result
#echo "VDW as Output_ene_comp_zero.txt ELE as $subtracted_value"

# Print lines 2 to 9 of Output_ene_comp.txt
#echo "Printing lines 2-9 of Output_ene_comp.txt:"
echo "Printing Energy Components for Na-Cl system $method" >  ../output_OPENMM_$method.out
echo "Distance (A),  Total Energy (kcal/mol)"   >> ../output_OPENMM_$method.out
awk 'NR>=0 && NR<=8' Output_ene_comp.txt        >> ../output_OPENMM_$method.out
echo "VDW  $val2"                               >> ../output_OPENMM_$method.out
echo "ELE  $ele_val"                            >> ../output_OPENMM_$method.out
awk 'NR>=10 && NR<=12' Output_ene_comp.txt      >> ../output_OPENMM_$method.out

echo "Generated output_OPENMM_$method.out"
cd ../
done
