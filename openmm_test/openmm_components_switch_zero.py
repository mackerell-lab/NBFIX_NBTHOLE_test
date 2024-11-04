from openmm.app import *
from openmm import *
from openmm.unit import *
from sys import stdout
from simtk.unit import *
#import parmed as pmd

#for dis in [str(round(x, 1)).rstrip('.0') if x % 1 != 0 else str(int(x)) for x in list(float(i) / 10 for i in range(38, 200))]:
distance= [ '2.8']
for dis in distance:

    psf = CharmmPsfFile('sod_cla_drude_zero.psf')
    pdb = PDBFile('../coords/sod_cla_'+dis+'_min.pdb')
    
    params = CharmmParameterSet('../drude_toppar_nbfix_nbthole_test/toppar_drude_water_nacl.str')
    psf.setBox(200.00*angstrom,200.00*angstrom,200.00*angstrom)
    
    #rst = loadState('out.rst')

         
    system = psf.createSystem(params,
                              nonbondedMethod = PME,
                              nonbondedCutoff = 1.2*nanometers,
                              switchDistance  = 1.0*nanometers,
                              constraints = HBonds,
                              ewaldErrorTolerance=0.0001)
    for force in system.getForces():
        if isinstance(force, NonbondedForce): force.setUseDispersionCorrection(True)
        if isinstance(force, CustomNonbondedForce) and force.getNumTabulatedFunctions() == 2:
            force.setUseLongRangeCorrection(True)
    
    
    integrator = DrudeLangevinIntegrator(298.0*kelvin, 5.0/picosecond, 1.0*kelvin, 20.0/picosecond, 0.001*picoseconds)
    integrator.setMaxDrudeDistance(0.02)
    
    simulation = Simulation(psf.topology, system, integrator)
    simulation.context.setPositions(pdb.positions)
    simulation.context.computeVirtualSites()
    mycontext = simulation.context
    
    mystate= simulation.context.getState(getPositions=True,enforcePeriodicBox=True,getEnergy=True)
    positions= mystate.getPositions()
    potentialE= mystate.getPotentialEnergy()/ kilocalories_per_mole
    
    with open("Output_ene_comp_zero.txt", "w") as f:
        # Print to the file
        f.write(f"{dis} {potentialE}\n\n")
        
        E = []
        g = [1, 2, 4, 8, 16, 32, 64, 128, 256]
        etype = ['BOND', 'ANGL', 'DIHE', 'UREY', 'IMPR', 'CMAP', 'NONB', 'DRUD', 'OTH1']
        e = 0
        for i in range(len(g)):
            energy = simulation.context.getState(getEnergy=True, groups=g[i]).getPotentialEnergy().value_in_unit(kilocalories_per_mole)
            f.write(f"{etype[i]} {energy}\n")
            e += energy
            E.append((etype[i], energy))
        
        f.write(f"TOTE {e}\n")
        E.append(("TOTE", e))
        f.write('\n')
        
        f.write(f"BOND+DRUD {E[0][1] + E[7][1]:.5f}\n")
        f.write(f"ANGL+UREY {E[1][1] + E[3][1]:.5f}\n")
        f.write(f"DIHE+CMAP {E[2][1] + E[5][1]:.5f}\n")
        f.write(f"IMPR {E[4][1]:.5f}\n")
        f.write(f"ELEC+VDW {E[6][1]:.5f}\n")
        f.write(f"TOTE {E[9][1]:.5f}\n")
   
    print("I generated the file Output_ene_comp_zero.txt")



    #simulation.step(1)
    
