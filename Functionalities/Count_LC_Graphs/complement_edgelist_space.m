function [MEB,store_nu_xy]=complement_edgelist_space(Adj)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to output the basis for the power set of the complement edgelist space in
%binary rep. Each vector is a row of the output matrix EB.
%Input:  Adj: The adjacency matrix of input graph G.
%Output: MEB: The basis of the edgelist of \bar{G} for the graph G.
%        store_nu_xy: The symmetric difference for each xy edge.


n             = length(Adj);
AdjB          = complement_graph(Adj);


if all(all(AdjB==sparse(n,n))) 
   
    MEB = zeros(1,n);
    store_nu_xy = [];
    return
    
end

MEB=[];
cnt=0;
%For every edge xy pair in \bar{G}, find the intersection:
for v=1:n
    
    for w=v+1:n

        if  AdjB(v,w)==1
            
        
            nu_xy = neighborhood_xy(Adj,v,w)';
            
            if ~isempty(nu_xy)
            
                cnt              = cnt+1;
                store_nu_xy{cnt} = nu_xy;
                
            end

            %map to binary:
            
            if isempty(nu_xy)
                
                
                vP = zeros(1,n);
            else
                vP        = zeros(1,n);
                vP(nu_xy) = 1;
                
            end
            
            MEB   = [MEB;vP];        

        end
        
    end
    
end

%Find a basis by standard Gauss Elim:
MEB   = Gauss_elim_GF2(MEB);

%Remove 0 rows:
MEB(~any(MEB,2),:)=[];



end