function mustBeAbelian(S)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Input should be a stabilizer array of dimension n x 2*n. (SX|SZ)

[n,N] = size(S);

if N~=2*n
   error('The input array in mustBeAbelian is not n x 2n.') 
end

PZ2 = [sparse(n,n) , speye(n) ; ...
       speye(n)    , sparse(n,n) ];
   

if any(mod(S*PZ2*S.',2)~=sparse(n,n))
    
     ME=MException('mustBeAbelian:inputError','Input set is not Abelian');
    
     throw(ME)
    
end



end