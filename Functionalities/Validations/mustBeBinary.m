function mustBeBinary(A)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%

if ~isbinary(A)
    
     ME=MException('mustBeBinary:inputError','Input must be binary.');
    
     throw(ME)
    
end



end