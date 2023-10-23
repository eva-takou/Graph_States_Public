function Circuit = store_gate_oper(qubit,operation,Circuit)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to store the gates of the circuit generation in a list.
%Input: qubit: the qubit(s) onto which the operation is acted
%       operation: an char of the operation e.g. 'CNOT','H','P' etc
%       Circuit: the remaining circuit so far (could be empty)
%Output: the updated circuit

if isempty(Circuit)
    L=0;
else
    L = length(Circuit.Gate.qubit);
end

Circuit.Gate.qubit{L+1} = qubit;
Circuit.Gate.name{L+1}  = operation;


end