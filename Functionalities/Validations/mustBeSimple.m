function mustBeSimple(A)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%

if any(diag(A))
    
     ME=MException('mustBeSimple:inputError','Detected self loop in adjacency matrix.');
    
     throw(ME)
    
end



end