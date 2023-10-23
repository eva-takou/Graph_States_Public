function connected_cond=isconnected(in,n,Option)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%Check if the graph is connected.
%Input: in: the graph either as adjacency or graph
%       n: the order of the graph
%       Option: 'Adjacency' or 'Graph' structure.
%Output: true or false


switch Option
    
    
    case 'Adjacency'

        G=graph(in);
        
    case 'Graph'
        
        G=in;
end



for jj=1:n
    
    v = dfsearch(G,jj);
    
    if length(v)==n
        
        connected_cond = true;
       
        return
    end
    
end

connected_cond = false;



end