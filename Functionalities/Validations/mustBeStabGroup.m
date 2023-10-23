function mustBeStabGroup(S)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Input can be Stab or Destab array.

mustBeAbelian(S)

mustBeBinary(S)

[n,~]=size(S);

for ii=1:n
    for jj=ii+1:n
        
        if all(S(ii,:)==S(jj,:))
            
           
            ME=MException('mustBeStabGroup:inputError','Detected duplicate operators.');
    
            throw(ME)            
            
        end
        
    end
    
    if nnz(S(ii,:))==0 %all 0s -> Identity
       
        ME=MException('mustBeStabGroup:inputError','Detected identity as generator.');
        throw(ME)            
        
    end
    
end







end