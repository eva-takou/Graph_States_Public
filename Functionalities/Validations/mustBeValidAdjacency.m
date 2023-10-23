function mustBeValidAdjacency(A)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
mustBeSimple(A)


if ~issymmetric(A)

ME=MException('mustBeValidAdjacency:inputError','Detected non-symmetric Adjacency matrix.');
    
throw(ME)

end


if size(A,1)~=size(A,2)
    
ME=MException('mustBeValidAdjacency:inputError','Adjacency matrix is not square.');
    
throw(ME)
    
end

end