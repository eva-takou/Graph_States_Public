function Adj=Local_Complement(Adj,node)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to apply LC about a specified node.
%Input: Adj: The adjacency matrix
%       node: The node about which to apply the local complementation.
%Output: The updated adjacency matrix.


neighbors = find(Adj(:,node));
L         = length(neighbors);

if L==1    %Only one neighbor--same graph
   return 
end


for jj=1:L

    n1=neighbors(jj);

    for kk=jj+1:L

        n2         = neighbors(kk);
        
        Adj(n1,n2) = mod(Adj(n1,n2)+1,2);
        Adj(n2,n1) = mod(Adj(n2,n1)+1,2);

    end

end
  




end