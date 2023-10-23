function [Tab,Circuit]=fix_phases(Tab,np,ne,Circuit)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to put the phases of stabilizers to +1.
%Input: Tab: Tableau
%       np: # of photons
%       ne: # of emitters
%       Circuit: The circuit so far
%Output: Tab: The updated tableau
%        Circuit: The updated circuit

n = np+ne;

for ii=1:n
    
    phase = Tab(ii+n,end);
    
    if phase~=0
        
        Tab     = Clifford_Gate(Tab,ii,'X');
        Circuit = store_gate_oper(ii,'X',Circuit); 
    end
    
end

end