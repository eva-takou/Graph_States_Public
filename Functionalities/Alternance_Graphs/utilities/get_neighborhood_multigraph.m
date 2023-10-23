function neighbors=get_neighborhood_multigraph(inp,v,formatOption)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------



switch formatOption
    
    case 'Adjacency'
        
        
        Adj  = inp;
        
        
        neighbors = find(Adj(:,v));
        
        
        
        
    case 'EdgeList'
        
        
        
        
        
        
end









end