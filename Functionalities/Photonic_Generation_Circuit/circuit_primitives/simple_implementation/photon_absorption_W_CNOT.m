function [Tab,Circuit,graphs]=photon_absorption_W_CNOT(Tab,np,ne,photon,Circuit,graphs,Store_Graphs)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to perform photon absorption. There was no available emitter, so we 
%need to apply emitter gates first.
%Inputs: Tab: Tableau
%        np: # of photons
%        ne: # of emitters
%        photon: # index of photon to be absorbed
%        Circuit: the circuit we have so far
%        graphs: the graph evolution as we evolve the circuit.
%        Output_Many: Option to output only 1 tableau or inspect all
%        choices.
%Output: Tab: The updated tableau
%        Circuitt: The updated circuit
%        graphs: The updated graphs
%
%To do the photon absorption we search for a stabilizer which starts with
%L(Sa)=index of photon to be absorbed. If for this kind of stabilizer there
%is only 1 non-trivial pauli on emitter sites, then the photon can be
%asborbed. Otherwise we need emitter gates. This script is used when there
%is no emitter available and we need to apply emitter gates first.
%
%We do a greedy implementation of making only 1 choice for which emitter to
%use. We choose minimal weight for the operator for which L(Sa)=index of
%photon.
%
%Methods from Ref: Bikun Li et al, npj Quantum Information 8, 11, (2022)

disp(['Emitters are entangled. Need gates before photon absorption of photon #',num2str(photon)])

n                 = np+ne;
[cond_product, ~] = qubit_in_product(Tab,n,photon);

if cond_product
    
    disp('Photon has already been absorbed.')
    return
    
end

%Get stabs whose left index starts from a Pauli on the photon to be absorbed
[potential_rows,photon_flag_Gate] = detect_Stabs_start_from_photon(Tab,photon,n);

[row_id,indx] = detect_Stab_rows_of_minimal_weight(Tab,potential_rows,np,n);

[emitters_in_X,emitters_in_Y,emitters_in_Z]=emitters_Pauli_in_row(Tab,row_id,np,ne);

%-------- Bring all emitters in Z for the particular row: -----------------
[Tab,Circuit]=put_emitters_in_Z(Tab,Circuit,emitters_in_X,emitters_in_Y);


possible_emitters = [emitters_in_X,emitters_in_Y,emitters_in_Z];
%----- Choose the 1st emitter (do not inspect emitter choice) -------------

emitter        = possible_emitters(1);
other_emitters = possible_emitters(2:end);

[Tab,Circuit,graphs]=free_emitter_for_PA(Tab,Circuit,graphs,Store_Graphs,emitter,other_emitters);

emitter_flag_Gate='Z';

[Tab,Circuit,graphs]=PA_subroutine(Tab,Circuit,graphs,photon,emitter,emitter_flag_Gate,photon_flag_Gate{indx},Store_Graphs);

end


function [Stab_row_indx,indx] = detect_Stab_rows_of_minimal_weight(Tab,potential_rows,np,n)

ne               = n-np;
Lp               = length(potential_rows);
weight           = zeros(1,Lp);
emitters_per_row = cell(1,Lp);

for ll=1:Lp

    row = potential_rows(ll);
    
    [emitters_in_X,emitters_in_Y,emitters_in_Z]=emitters_Pauli_in_row(Tab,row,np,ne);
    weight(ll)           = length(emitters_in_X)+length(emitters_in_Y)+length(emitters_in_Z);
    emitters_per_row{ll} = [emitters_in_X,emitters_in_Y,emitters_in_Z];
    
end

if min(weight)==0
   error('Error in photonic absorption. Found stab with support on target photon, but no support on any emitter.') 
end

[~,indx]      = min(weight);
Stab_row_indx = potential_rows(indx);

end

