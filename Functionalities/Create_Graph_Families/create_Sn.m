function out=create_Sn(n,formatOption)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Create a star graph of order n. 
%Input: n: The number of nodes
%       formatOption: 'Edgelist' or 'Adjacency' to control the output.

cnt=0;

central_node = 1; 

other_nodes = setxor(1:n,central_node);

for kk=1:n-1
           
    this_node     = other_nodes(kk);
    cnt           = cnt+1;
    Edgelist{cnt} = [central_node,this_node];
        
end



switch formatOption
    
    case 'EdgeList'
        
        out = Edgelist;
        
        
    case 'Adjacency'


        out = edgelist_to_Adj(Edgelist,n);
        
        
        
end



end