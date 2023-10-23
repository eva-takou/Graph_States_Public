function CNOT_cnt=emitter_CNOTs(Circuit,ne,np)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to count the number of CNOTs acting on emitter qubits only.
%Inputs: Circuit: The circuit that generates the photonic graph state
%        ne: # of emitters
%        np: # of photons
%Output: The CNOT count.

Circuit        = Circuit.Gate;
L              = length(Circuit.name);
emitter_qubits = np+1:(np+ne);
CNOT_cnt       = 0;

for ll=1:L

    if strcmpi(Circuit.name{ll},'CNOT')

        if length(intersect(Circuit.qubit{ll},emitter_qubits))==2
            CNOT_cnt=CNOT_cnt+1;
        end


    end

end


end