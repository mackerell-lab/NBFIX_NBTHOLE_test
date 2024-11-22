#!/bin/bash

#conda activate ommsimu

rm Result_CHARMM.txt

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


CHARMMEXC1=c44b2-serial
CHARMMEXC2=charmm-c48a2-serial
CHARMMEXC3=charmm-c48b2-serial-ljpme
CHARMMEXC4=charmm-c48b2-serial-ljpme-avx
CHARMMEXC5=charmm-c48b2-serial-ljpme-avx2
CHARMMEXC6=charmm-c50a1-serial-ljpme
CHARMMEXC7=charmm-c49b1-serial-ljpme-no_expand

for CHARMM in  $CHARMMEXC1  $CHARMMEXC2 $CHARMMEXC3 $CHARMMEXC4 $CHARMMEXC5 $CHARMMEXC6 $CHARMMEXC7
do

echo "###################################" >> Result_CHARMM.txt
echo "# CHARMM Version ${CHARMM}"  >> Result_CHARMM.txt
echo "###################################" >> Result_CHARMM.txt
echo "  "                >> Result_CHARMM.txt
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
	;;																	        esac
# Use the determined replacement variables in sed
sed -i "s|$original1|$new_value1|g" ./drude_toppar_nbfix_nbthole_test/toppar_drude_water_nacl.str
sed -i "s|$original2|$new_value2|g" ./drude_toppar_nbfix_nbthole_test/toppar_drude_water_nacl.str

for method in  ljpme ljpme_bycb ljpme_bycu ljpme_bygr switch switch_bycb  switch_bycu switch_bygr  #ljpme_bycc switch_bycc
do

cd charmm_test
rm output_charmm_${method}.out

/opt/mackerell/apps/charmm/serial/$CHARMM -i ener_${method}.inp -o ener_${method}.out
#/opt/mackerell/apps/charmm/serial/c44b2-serial -i ener_${method}.inp -o ener_${method}_${FF}.out


mv  ./output_charmm_${method}.out   ./output_charmm_${CHARMM}_${method}_${FF}.out
mv  ./ener_${method}.out            ./ener_${method}_${CHARMM}_${method}_${FF}.out

echo "              "
echo "Running ${CHARMM} ${method} ${FF} ..."

if [  -s ./output_charmm_${CHARMM}_${method}_${FF}.out ]; then

val2=$(awk 'NR==11 {print $2}' ./output_charmm_${CHARMM}_${method}_${FF}.out)
ele_val=$(awk 'NR==12 {print $2}' ./output_charmm_${CHARMM}_${method}_${FF}.out)

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
fi

#echo "  "  >> ../Result_CHARMM.txt
echo ">> ${method} ${FF} " >> ../Result_CHARMM.txt
awk -v val1="$result1" -v val2="$result2" '
NR==11 {print $0, val1}
NR==12 {print $0, val2}
' ./output_charmm_${CHARMM}_${method}_${FF}.out >> ../Result_CHARMM.txt

echo " "  >> ../Result_CHARMM.txt
#echo "See other details in output_charmm_${method}_${FF}.out"
cd ../
done

done
done
