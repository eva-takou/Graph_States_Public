function Tab=Clifford_Gate(Tab,qubit,Oper)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to apply Clifford gates on a stabilizer.
%Input:  Tableau, 
%        qubit: # index of qubit(s) (if 2 qubit gate, the 1st needs to be the control.)
%        Oper: str of the name of the operation.
%Output: The updated Tableau.

n = (size(Tab,1)-1)/2;

switch Oper
    
    case 'H'
   
        Tab=Had_Gate(Tab,qubit,n);
        
    case 'P'
        
        Tab=Phase_Gate(Tab,qubit,n);
        
    case 'X'
        
        Tab=Pauli_Gate(Tab,qubit,n,'X');
        
    case 'Y'
        
        Tab=Pauli_Gate(Tab,qubit,n,'Y');
        
    case 'Z'
        
        Tab=Pauli_Gate(Tab,qubit,n,'Z');
        
    case 'CNOT'
        
        Tab=CNOT_Gate(Tab,qubit,n); %1st qubit in qubit array is control, 
        
    case 'CZ' %(1\otimes H)CNOT(1\otimes H)=CZ
        
        %Decompose in terms of CNOT and Hadamards on target qubit.
        
        Tab = Had_Gate(Tab,qubit(2),n);
        Tab = CNOT_Gate(Tab,qubit,n);
        Tab = Had_Gate(Tab,qubit(2),n);
        
end
    
end