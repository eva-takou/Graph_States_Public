function mustBeSparse(A)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
if ~issparse(A)
   
    ME=MException('mustBeSparse:inputError','Input must be sparse.');
    
    throw(ME)
    
end



end