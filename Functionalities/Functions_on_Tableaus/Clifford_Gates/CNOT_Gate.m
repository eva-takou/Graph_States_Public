function  newTab=CNOT_Gate(Tab,qubit,n)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Implementation of the CNOT gate on the tableau.
%Inputs: Tab: The Tableau
%        qubit: an array of 2 qubits (first one is control)
%        n: the # of qubits represented by the Tableau.
%Output: The updated Tableau.

if length(qubit)~=2
   
    error('Please provide 2 qubits for the CNOT gate. The first one is the control.')
    
end

control = qubit(1);
target  = qubit(2);

newTab = Tab;
XC     = newTab(1:2*n,control);
ZC     = newTab(1:2*n,control+n);
r      = newTab(1:2*n,end);

XT     = newTab(1:2*n,target);
ZT     = newTab(1:2*n,target+n);


newTab(1:2*n,end)       = mod( r + XC.*ZT.*( mod( XT+ZC+1 ,2) )   ,2);
newTab(1:2*n,target)    = mod( XT+XC  ,2);
newTab(1:2*n,control+n) = mod(ZT+ZC,2);


end