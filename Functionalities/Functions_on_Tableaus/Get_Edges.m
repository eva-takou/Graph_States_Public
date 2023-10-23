function Edges = Get_Edges(Tab)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Get the set of all edges of the graph based on the Tableau.
%Input: Tab: Tableau.
%Output: The edgeset in cell array.

Gamma=Get_Adjacency(Tab);   

[n,~]=size(Gamma);
cnt=0;
   for ii=1:n

       for jj=ii+1:n

        if ii~=jj && Gamma(ii,jj)==1 %first condition redundant but ok
            cnt=cnt+1;
            Edges{cnt}=[ii,jj];

        end


       end


   end



end
