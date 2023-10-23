function h=height_function(Tab_RREF,n)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to calculate the entanglement entropy, given a
%particular ordering of the nodes. To reshuffle nodes we make use
%of permutation matrices.
%The height function is given by:
%h=@(x) n-x - number_of_gm| left index of Pauli of gm is in node_indx>x 
%
%Input: Tab_RREF: The tableau in RREF form
%       n: total # of qubits (photons+emitters)
%Output: h: the height function

Stabs  = Tab_RREF(n+1:2*n,1:2*n);

h=zeros(1,n+1);

for ii=1:(n-1)

   x=(ii); %current node

   cnt=0;

   for ll=1:n %loop through stabs

       Lindex_X = find( Stabs(ll,1:n) & ~Stabs(ll,1+n:2*n),1,'first');
       Lindex_Y = find( Stabs(ll,1:n) &  Stabs(ll,1+n:2*n),1,'first');
       Lindex_Z = find(~Stabs(ll,1:n) &  Stabs(ll,1+n:2*n),1,'first');

       if isempty(Lindex_X)
          Lindex_X=nan;
       elseif isempty(Lindex_Y)
           Lindex_Y=nan;
       elseif isempty(Lindex_Z)
           Lindex_Z=nan;
       end

       first_non_trivial_oper = min([Lindex_X,Lindex_Y,Lindex_Z]);

       if first_non_trivial_oper>(x)
          cnt=cnt+1; 

       end

   end

   h(ii+1)=h(ii+1)+n-(x)-cnt;


end









end