function [node,p,bool_split_free,Adj]=find_pair(v,Adj0)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%

verbose = false;
n       = length(Adj0);

if v>n
    error('Node v not in V.')
end

%Test which word:
Adj      = Adj0;
Adj(:,v) = [];
Adj(v,:) = [];

if is_split_free_brute(Adj,verbose)
   
    p    = {{[]}};
    node = {v};
    bool_split_free = true;
    return
    
else
    
    Adj      = Local_Complement(Adj0,v);
    Adj(:,v) = [];
    Adj(v,:) = [];
    
    if is_split_free_brute(Adj,verbose)
        
        p          = {{v}};
        node       = {v};
        bool_split_free = true;
        return
        
    else
        
        Adj = Adj0;
        Nv  = Get_Neighborhood(Adj,v);
        w   = Nv(1);
        Adj = Local_Complement(Adj,v);
        Adj = Local_Complement(Adj,w);
        Adj = Local_Complement(Adj,v);
        Adj(:,v)=[];
        Adj(v,:)=[];    
        
        if is_split_free_brute(Adj,verbose)
            
            p          = {{v,w,v}};
            node       = {v};
            bool_split_free = true;
            return
            
        else
           
            p          = {{[]}};
            node       = {[]};
            bool_split_free = false;
            Adj        = Adj0;
            
            
            
        end
        
    end
    
end


end
