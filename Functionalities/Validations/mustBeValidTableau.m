function mustBeValidTableau(Tableau)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
[n,~] = size(Tableau);
n     = (n-1)/2;
D     = Tableau(1:n,1:2*n);
S     = Tableau(n+1:2*n,1:2*n);

%Check that each one is a valid Abelian group, doesnt include identity, is
%binary.

mustBeStabGroup(D) 
mustBeStabGroup(S) 

PZ2 = [sparse(n,n) speye(n) ;...
       speye(n)  sparse(n,n)];
   
for ii=1:n
    
    if all(all(mod(D(ii,:)*PZ2*S(ii,:).',2)==sparse(n,n)))

              
        ME=MException('mustBeStabGroup:inputError',...
                   'Detected destabilizer that doesnt anti-commute with respective stabilizer.');
        
        throw(ME)
    end
    
    
    for jj=1:n
   
        if jj~=ii
            
           
           if any(mod(D(ii,:)*PZ2*S(jj,:).',2)~=sparse(n,n))
              
               ME=MException('mustBeStabGroup:inputError',...
                   'Detected destabilizer (j) that doesnt commute with other(s) stabilizer (\neq j).');
               
               throw(ME)
               
               
           end
            
            
            
        end
        
        
    end
    
    
    
end








end