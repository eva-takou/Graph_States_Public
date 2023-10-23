function m=double_occurrence_arbitrary_graph(Adj)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to construct the double occurence word of an adjacency matrix.
%The adjacency matrix has to be a circle graph to have a word
%representation.
%
%Input: Adj: Adjacency matrix of the graphs
%Output:  m: the double occurence word

verbose  = false;
[bool,m] = is_circleG(Adj,verbose);

if ~bool
    warning('Could not construct a double occurrence word, since the graph is not circle.')
    m=[];
end





end