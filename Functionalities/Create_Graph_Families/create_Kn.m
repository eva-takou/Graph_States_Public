function out=create_Kn(n,formatOption)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Create a complete graph of order n.
%Input: n: # of qubits
%       formatOption: 'Edgelist' or 'Adjacency' to control the output.
%Output: The edgelist or adjacency of the graph.



cnt=0;
for jj=1:n
    
    for kk=1:n
        
    
        if kk>jj
           
            cnt=cnt+1;
            Edgelist{cnt}=[jj,kk];
            
            
        end
        
        
    end
end

switch formatOption
    
    case 'EdgeList'
        
        out = Edgelist;
        
        
    case 'Adjacency'


        out = edgelist_to_Adj(Edgelist,n);
        
        
        
end



end