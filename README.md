
# Na-Cl Interaction Testing for NBFIX and NBTHOLE

This folder contains scripts and resources for testing the NBFIX and NBTHOLE parameters for Na-Cl interactions.

## Contents

- **`run_charmm.sh`**: Script to run the CHARMM test.
- **`run_openmm.sh`**: Script to run the OpenMM test.
- **`bench_mark`**: File containing benchmark data for performance and accuracy comparisons.

## How to Run the Tests

To execute the tests, follow these steps:

1. Ensure all required dependencies for CHARMM and OpenMM are installed.
2. Make the scripts executable:
   ```bash
   chmod +x run_charmm.sh run_openmm.sh
   ```
3. Run the CHARMM and OpenMM tests with the following commands:

   ```bash
   ./run_charmm.sh
   ./run_openmm.sh
   ```

## Viewing Benchmark Results

The bench_mark file contains benchmark data for comparison. 

## Results

Results are written in 
- **`Result_CHARMM.txt`**: CHARMM result
- **`Result_OPENMM.txt`**: OPENMM result

Due to variations in values across different software, we have established a relatively lenient pass criterion: an energy difference of less than 0.1 kcal/mol.
If NBFIX or NBTHOLE is ineffective, the energy difference will be significantly higher.

