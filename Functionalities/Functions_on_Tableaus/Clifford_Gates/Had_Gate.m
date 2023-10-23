function newTab=Had_Gate(Tab,qubit,n)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

%Implementation of the Hadamard gate on the tableau.
%Inputs: Tab: The Tableau
%        qubit: an array of 2 qubits (first one is control)
%        n: the # of qubits represented by the Tableau.
%Output: The updated Tableau.
newTab = Tab;
newTab(1:2*n,end) = mod(newTab(1:2*n,qubit).*newTab(1:2*n,qubit+n)+...
                        newTab(1:2*n,end),2);
                    
newTab(:,[qubit,qubit+n]) =newTab(:,[qubit+n,qubit]);



end