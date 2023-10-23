function [emitters_in_X,emitters_in_Y,emitters_in_Z]=emitters_Pauli_in_row(Tab,Stabrow,np,ne)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Get the emitters Pauli for a particular stabilizer row.
%Inputs: Tab: Tableau
%        Stabrow: The stabilizer row to get the emitters
%        np: # of photons
%        ne: # of emitters
%Output: the indices of emitters in X, in Y and in Z, counting from np+1:n.

n    = np+ne;
Stab = Tab(n+1:2*n,1:2*n);

emitters_in_X  = find( Stab(Stabrow,np+1:n) & ~Stab(Stabrow,np+1+n:2*n))+np;
emitters_in_Y  = find( Stab(Stabrow,np+1:n) &  Stab(Stabrow,np+1+n:2*n))+np;
emitters_in_Z  = find(~Stab(Stabrow,np+1:n) &  Stab(Stabrow,np+1+n:2*n))+np;

end