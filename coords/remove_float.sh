#!/bin/bash

cation="sod"
anion="cla"
for i in {1..10}
do
mv ${cation}_${anion}_${i}.0.crd ${cation}_${anion}_${i}.crd 
done
