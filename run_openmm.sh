#!/bin/bash

#conda activate ommsimu

rm Result_OPENMM.txt

original1="!SODD    CLAD   -0.04762  5.09000 ! test"
new_COMB="!SODD    CLAD   -0.04762  5.09000 ! test"
new_NBFIX="SODD    CLAD   -0.04762  5.09000 ! test"
new_NBTHOLE="!SODD    CLAD   -0.04762  5.09000 ! test"
new_NBFIX_NBTHOLE="SODD    CLAD   -0.04762  5.09000 ! test"

original2="!SODD    CLAD   1.00000 ! test"
new2_COMB="!SODD    CLAD   1.00000 ! test"
new2_NBFIX="!SODD    CLAD   1.00000 ! test"
new2_NBTHOLE="SODD    CLAD   1.00000 ! test"
new2_NBFIX_NBTHOLE="SODD    CLAD   1.00000 ! test"

for FF in COMB NBFIX NBTHOLE NBFIX_NBTHOLE
do


cp  ./drude_toppar_nbfix_nbthole_test/toppar_drude_water_nacl_cp.str  ./drude_toppar_nbfix_nbthole_test/toppar_drude_water_nacl.str


case $FF in
     COMB)
	new_value1="$new_COMB"
	new_value2="$new2_COMB"
	b_vdw=2.152
	b_ele=-123.072
	;;
     NBFIX)
	new_value1="$new_NBFIX"
	new_value2="$new2_NBFIX"
	b_vdw=58.582
	b_ele=-123.072
	;;
     NBTHOLE)
	new_value1="$new_NBTHOLE"
	new_value2="$new2_NBTHOLE"
	b_vdw=2.152
	b_ele=-106.773
	;;
     NBFIX_NBTHOLE)
	new_value1="$new_NBFIX_NBTHOLE"
	new_value2="$new2_NBFIX_NBTHOLE"
	b_vdw=58.582
	b_ele=-106.773
	;;
        esac
# Use the determined replacement variables in sed
sed -i "s|$original1|$new_value1|g" ./drude_toppar_nbfix_nbthole_test/toppar_drude_water_nacl.str
sed -i "s|$original2|$new_value2|g" ./drude_toppar_nbfix_nbthole_test/toppar_drude_water_nacl.str


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

echo "Running ${method} ${FF} ..."

diff1=$(echo "scale=5; if ($val2 > $b_vdw) $val2 - $b_vdw else $b_vdw - $val2" | bc)
diff2=$(echo "scale=5; if ($ele_val > $b_ele) $ele_val - $b_ele else $b_ele - $ele_val" | bc)

if (( $(echo "$diff1 < 0.1" | bc -l) )); then
    result1="pass"
else
    result1="!!!!non-pass"
fi


if (( $(echo "$diff2 < 0.1" | bc -l) )); then
    result2="pass"
else
    result2="!!!!non-pass"
fi



echo "Printing Energy Components for Na-Cl system $method" >  ./output_OPENMM_${method}_$FF.out
echo "Distance (A),  Total Energy (kcal/mol)"   >> ./output_OPENMM_${method}_$FF.out
awk 'NR>=0 && NR<=8' Output_ene_comp.txt        >> ./output_OPENMM_${method}_$FF.out
echo "VDW  $val2   $result1"                    >> ./output_OPENMM_${method}_$FF.out
echo "ELE  $ele_val   $result2"                 >> ./output_OPENMM_${method}_$FF.out
awk 'NR>=10 && NR<=12' Output_ene_comp.txt      >> ./output_OPENMM_${method}_$FF.out


echo ">> ${method} ${FF} " >> ../Result_OPENMM.txt
awk 'NR==11,NR==12' ./output_OPENMM_${method}_${FF}.out >> ../Result_OPENMM.txt
echo " "  >> ../Result_OPENMM.txt

cd ../

done
done
