function graphs = store_graph_transform(G,identifier,graphs)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to store the graphs of the circuit generation in a list.
%Input: G: the graph to store
%       identifier: if this after a TRM, a decoupling step, or photon
%       absorption
%       graphs: the remaining circuit so far (could be empty)
%Output: the updated graphs

if isempty(graphs)
    L=0;
else
    L = length(graphs.Adjacency);
    
end

graphs.Adjacency{L+1}  = G;
graphs.identifier{L+1} = identifier;
end