function Tab=Pauli_Gate(Tab,qubit,n,Pauli)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Implementation of the Pauli X,Y, or Z gate on the tableau.
%Inputs: Tab: The Tableau
%        qubit: an array of 2 qubits (first one is control)
%        n: the # of qubits represented by the Tableau.
%        Pauli: 'X', 'Y', or 'Z'
%Output: The updated Tableau.
switch Pauli
    
    case 'X'

        for ii=1:2*n
           
            if Tab(ii,qubit+n)==1 %Y or Z
                
                Tab(ii,end) = mod(Tab(ii,end)+1,2);
                
            end
            
            
        end
        
    case 'Y'
        
        for ii=1:2*n
           
            if mod(Tab(ii,qubit)+Tab(ii,qubit+n),2)==1 %X or Z
                
                Tab(ii,end)=mod(Tab(ii,end)+1,2);
                
            end
            
            
        end        
        
    case 'Z'
        
        for ii=1:2*n
           
            if Tab(ii,qubit)==1 %X or Y
                
                Tab(ii,end) = mod(Tab(ii,end)+1,2);
            end
            
        end        
        
end
       

end