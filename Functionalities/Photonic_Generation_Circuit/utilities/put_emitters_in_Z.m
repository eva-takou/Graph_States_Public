function [Tab,Circuit]=put_emitters_in_Z(Tab,Circuit,emitters_in_X,emitters_in_Y)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Script to put the emitters in Z.
%Inputs: Tab: Tableau
%        Circuit: The circuit so far
%        emitters_in_X/Y/Z: the index of emitters in X,Y,Z counting from
%        np+1:n
%Output: Tab: The updated Tableau
%        Circuit: The updated circuit

for jj=1:length(emitters_in_X)

    Tab     = Clifford_Gate(Tab,emitters_in_X(jj),'H');
    Circuit = store_gate_oper(emitters_in_X(jj),'H',Circuit);   

end

for jj=1:length(emitters_in_Y)

    Tab  = Clifford_Gate(Tab,emitters_in_Y(jj),'P');
    Tab  = Clifford_Gate(Tab,emitters_in_Y(jj),'H');
    
    Circuit = store_gate_oper(emitters_in_Y(jj),'P',Circuit);   
    Circuit = store_gate_oper(emitters_in_Y(jj),'H',Circuit);   

end    



end