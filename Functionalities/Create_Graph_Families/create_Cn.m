function out=create_Cn(n,formatOption)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Create a circle graph of order n. 
%Input: n: The number of nodes
%       formatOption: 'Edgelist' or 'Adjacency' to control the output.


cnt=0;
for jj=1:n
    
    for kk=jj+1:n %edges between v_{i-1}-v_{i} and v_{i}-v_{i+1}
        
        if abs(kk-jj)==1
        
            cnt=cnt+1;
            Edgelist{cnt}=[jj,kk];
            
        end
        
    end
end

Edgelist{end+1} = [1,n];


switch formatOption
    
    case 'EdgeList'
        
        out = Edgelist;
        
        
    case 'Adjacency'


        out = edgelist_to_Adj(Edgelist,n);
        
        
        
end



end