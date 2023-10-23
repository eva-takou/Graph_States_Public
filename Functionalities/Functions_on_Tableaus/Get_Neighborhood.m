function neighbors = Get_Neighborhood(Adj,node)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to get the neighborhood of a node.
%Input: Adj: Adjacency matrix
%       node: The node to evaluate its neighborhood
%Output: The neighbors of the node.

neighbors = find(Adj(:,node));


end