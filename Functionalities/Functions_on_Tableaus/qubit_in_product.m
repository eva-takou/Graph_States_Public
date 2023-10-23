function [cond_product, state_flag]= qubit_in_product(Tab,n,qubit)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to check if a qubit from the tableau is in product state.
%Input: Tab: Tableau
%       n: # of qubits
%       qubit: The qubit index to inspect if it is in product state
%Output: cond_product: true or false
%        state_flag: if cond_product is true, it outputs the state of the
%        qubit.


StabsX = Tab(n+1:2*n,qubit); 
StabsZ = Tab(n+1:2*n,qubit+n);

qubit_X = find(  StabsX & ~StabsZ, 1);
qubit_Y = find(  StabsX &  StabsZ, 1);
qubit_Z = find( ~StabsX &  StabsZ, 1);


if isempty(qubit_X) && isempty(qubit_Y) %if X and Y parts are empty then the qubit is in Z

    cond_product = true;
    state_flag   = 'Z'; 

elseif isempty(qubit_X) && isempty(qubit_Z)
    
    cond_product = true;
    state_flag   = 'Y'; 
    
elseif isempty(qubit_Y) && isempty(qubit_Z)
    
    cond_product = true;
    state_flag   = 'X'; 
    
else
    
    cond_product = false;
    state_flag   = ''; 
    
end


end