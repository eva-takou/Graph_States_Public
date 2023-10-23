function out=create_Pn(n,formatOption)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Create a path graph of order n.
%Input: n: # of qubits
%       formatOption: 'Edgelist' or 'Adjacency' to control the output.
%Output: The edgelist or adjacency of the graph.

cnt=0;
for jj=1:n
    
    for kk=jj+1:n %only egdes between v_{i+1}v_{i}
        
    
        if kk-jj==1
            cnt=cnt+1;
            EdgeList{cnt}=[jj,kk];
        else
            break
        end
        
    end
end

switch formatOption
    
    case 'EdgeList'
        
        out = EdgeList;
        
        
    case 'Adjacency'


        out = edgelist_to_Adj(EdgeList,n);
        
        
        
end



end