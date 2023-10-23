function out = create_symmetric_tree_graph(bj,gen,formatOption)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Create a symmetric tree graph.
%Input : bj, the branching parameters per generation (parent node), it is 
%        an array of 
%        gen: number of generations (counts after the 1st parent node)
%        formatOption: 'Edgelist' or 'Adjacency' to control the output.
%Output: The edgelist or adjacency of the graph

%e.g. if bj=2 and gen=2
%             1
%            / \
%           2   3
%          / \ / \
%         4  5 6  7


%e.g. if bj=[2,3] and gen=2
%              1
%            /   \
%           2     3
%          /|\   /|\
%         4 5 6 7 8 9


nodes = 1;
edges = 0;
for this_gen = 1:gen
   
    nodes = nodes + bj(this_gen)^this_gen; %total # of nodes in the tree
    edges = edges + bj(this_gen)*this_gen;
end


EdgeList  = cell(1,edges);

parents   = 1;

previous_nodes = 1;
cnt=0;
for this_gen = 1 : gen
   
    num_of_children = bj(this_gen);
    children        = bj(this_gen)^this_gen;
    children        = previous_nodes+1:previous_nodes+children;
    previous_nodes  = children(end);
    
    for ll=1:length(parents)
        
        for kk=1:num_of_children
            cnt=cnt+1;
            EdgeList{cnt}=[parents(ll),children(kk+(ll-1)*bj(this_gen))];
            %[EdgeList,[parents(ll),children(kk+(ll-1)*bj(this_gen))]];
        end
        
    end
    
    parents=children;
    
end


switch formatOption
    
    case 'Edgelist'
        
        return
        
    case 'Adjacency'
        n = max([EdgeList{:}]);
        out=edgelist_to_Adj(EdgeList,n);
        
end






end