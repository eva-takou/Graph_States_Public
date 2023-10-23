function [emitter_qubit,other_emitters,Tab,Circuit,min_Stabrow]=minimize_emitter_length(Tab,Circuit,n,np,ne)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to choose a stabilizer row which has solely support on emitters
%and pick the row with minimal weight on the emitter qubits.
%Input: Tab: Tableau
%       Circuit: The circuit that we have so far
%       n: total # of qubits
%       np: # of photons
%       ne: # of emitters
%Output: emitter_qubit: qubit to be used
%        other_emitters: the remaining emitters in the particular
%        stabilizer row [all have been put in Z]
%        Tab: The updated tableau after putting the emitters in Z
%        Circuit: the updated circuit
%        n: total # of qubits
%        np: # of photons
%        ne: # of emitters

Stabs          = Tab(n+1:2*n,1:2*n);
row_indx_Stabs = Stabs_with_support_on_emitters(Tab,np,ne);
LS             = length(row_indx_Stabs);

emm_in_X       = cell(1,LS);
emm_in_Y       = cell(1,LS);
emm_in_Z       = cell(1,LS);
emitter_length = zeros(1,LS);

for ll=1:LS

   row         = row_indx_Stabs(ll);
   SX_emitters = Stabs(row,np+1:n);
   SZ_emitters = Stabs(row,(np+1)+n:2*n);

   emm_in_X{ll}       = find( SX_emitters  & ~SZ_emitters);
   emm_in_Y{ll}       = find( SX_emitters  &  SZ_emitters);
   emm_in_Z{ll}       = find(~SX_emitters  &  SZ_emitters);
   emitter_length(ll) = length(emm_in_X{ll})+length(emm_in_Y{ll})+length(emm_in_Z{ll});

end

%--------------------------------------------------------------------------
%1st choice here: there might be more than 1 rows with minimal length
%--------------------------------------------------------------------------

[~,lmin]=min(emitter_length); %Choose a stab that has smallest stabilizer weight - will need smaller number of CNOTs to disentangle 1 emitter.
min_Stabrow = row_indx_Stabs(lmin);

SX_emitters = Stabs(row_indx_Stabs(lmin),np+1:n);
SZ_emitters = Stabs(row_indx_Stabs(lmin),np+1+n:2*n);

emm_in_X    = find( SX_emitters & ~SZ_emitters );
emm_in_Y    = find( SX_emitters &  SZ_emitters );

for jj=1:length(emm_in_X)

  Tab     = Clifford_Gate(Tab,emm_in_X(jj)+np,'H');
  Circuit = store_gate_oper(emm_in_X(jj)+np,'H',Circuit); 

end

for jj=1:length(emm_in_Y)

   Tab = Clifford_Gate(Tab,emm_in_Y(jj)+np,'P'); 
   Tab = Clifford_Gate(Tab,emm_in_Y(jj)+np,'H'); 
   
   Circuit = store_gate_oper(emm_in_Y(jj)+np,'P',Circuit); 
   Circuit = store_gate_oper(emm_in_Y(jj)+np,'H',Circuit); 
   
end

%Now all emitters in this row of stabs are in Z
SX_emitters = Tab(row_indx_Stabs(lmin)+n,(np+1):n);
SZ_emitters = Tab(row_indx_Stabs(lmin)+n,(np+1)+n:2*n);
emm_in_Z    = find(SZ_emitters & ~SX_emitters);

%--------------------------------------------------------------------------
%2nd choice here: which qubit to pick as the one that will absorb next
%--------------------------------------------------------------------------
emitter_qubit  = emm_in_Z(1); %Will be used for photon absorption next
other_emitters = emm_in_Z(2:end);

emitter_qubit  = emitter_qubit+np;
other_emitters = other_emitters+np;


end
