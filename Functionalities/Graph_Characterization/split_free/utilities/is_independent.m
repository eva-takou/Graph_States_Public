function bool=is_independent(B,Adj)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------


for jj=1:length(B)
    
    x  = B(jj);
    
    for kk=1:length(B)
        
        y  = B(kk);
        
        if Adj(x,y)==1 
            
           
            bool=false; %should not have connections between any x and y \in B.
            return
            
        end
        
        
        
        
    end
    
    
    
end


bool=true;








end