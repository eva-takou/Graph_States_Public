function dim_nu_G = bineighborhood_space(Adj)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to get the dimension of the bineighborhood space of a simple graph.
%Input:  Adj: Adjacency matrix.
%Output: dim_nu_G: Dimension of the bineighborhood space.

[CB,~,~] = cycle_basis(Adj); %Get the basis for the cycle space
[MEB,~]  = complement_edgelist_space(Adj); %Get the basis for the complement edgeset space


M = [CB;MEB];
M = Gauss_elim_GF2(M);

indx=[];

for jj=1:size(M,1)
    
    if all(M(jj,:)==0)
        indx=[indx,jj];
        
    end
    
end

M(indx,:)=[];

dim_nu_G = size(M,1);



end