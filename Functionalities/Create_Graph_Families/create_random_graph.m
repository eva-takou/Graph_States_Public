function Adj=create_random_graph(n)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Create a random graph of order n.
%Input: n: # of qubits
%       formatOption: 'Edgelist' or 'Adjacency' to control the output.
%Output: The adjacency of the graph.


Adj = round(rand(n));
Adj = triu(Adj) + triu(Adj,1)';
Adj = Adj - diag(diag(Adj));

Adj = sparse(Adj);

%check that it is a connected graph with dfs:

if ~isconnected(Adj,n,'Adjacency')
    
    %call again
    Adj=create_random_graph(n);
else
    return
    
end






end