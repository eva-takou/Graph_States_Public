function Adj=edgelist_to_Adj(EdgeList,n)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to convert an Edgelist to the adjacency matrix.
%
%Input: EdgeList: A cell array with the edges of the graph
%       n: # of graph nodes
%Output: Adj: The adjacency matrix of the graph

Adj = sparse(n,n);

for jj=1:length(EdgeList)
    
   this_edge=EdgeList{jj} ;
   
   Adj = Adj + sparse(this_edge(1),this_edge(2),1,n,n);
   Adj = Adj + sparse(this_edge(2),this_edge(1),1,n,n);
   
    
end


end