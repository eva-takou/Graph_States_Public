function theta=Lovasz_number(Adj)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%Min-max problem based on wikipedia. Method #1 for lovasz number.

n   = length(Adj);
fun = @(X) max(eig(X));
X0  = zeros(n,n);

for jj=1:length(Adj)
    
    for kk=1:length(Adj)
   
        if jj==kk
            
            X0(jj,kk)=1;
            
        elseif jj~=kk && Adj(jj,kk)==0
            
            X0(jj,kk)=1;
        end
        
        
    end
    
end


%options = optimoptions('fminimax','ConstraintTolerance',1e-9);
%number of evaluations should increase for larger size of graphs
options = optimoptions('fmincon','MaxFunctionEvaluations',1e5); %,'ConstraintTolerance',1e-9,'OptimalityTolerance',1e-9,'StepTolerance',1e-11,'MaxIterations',1e6 
                   
fconstraints = @(X) mycon(X,Adj);

X0 = rand(n);
X0 = X0*X0';


%[Xsol,fval] = fminimax(fun, X0,[],[],[],[],[],[],fconstraints,options);

[Xsol,fval] = fmincon(fun, X0,[],[],[],[],[],[],fconstraints,options);

%check that Xsol was valid:

if sum(Xsol-Xsol','all')>1e-3
   
    error('Solution matrix is not symmetric.')
    
end

for jj=1:length(Adj)
    
    for kk=1:length(Adj)
   
        
            
            if abs(Xsol(jj,jj)-1)>1e-3
                error('Diagonal entry not equal to 1.')
            elseif Adj(jj,kk)==0
                
                if abs(Xsol(jj,kk)-1)>1e-3
                error(strcat(num2str([jj,kk]),' entry is not 1.'))
                
                end
                
            end
        
        
    end
    
end


theta=fval;


end

function [c,ceq] = mycon(X,Adj) %,
%constraint x_{ij}=1 whenever i=j or if i and j vertices are not adjacent

%const = X=X'-> X-X'==0

c      = [];
temp   = X-X';

ceq    = temp(:);
cnt    = length(ceq);

for jj=1:length(Adj)
    
    for kk=1:length(Adj)
   
        if jj==kk
            
            cnt      = cnt+1;
            ceq(cnt) = X(jj,kk)-1;
            
        elseif jj~=kk && Adj(jj,kk)==0
            
            cnt      = cnt+1;
            ceq(cnt) = X(jj,kk)-1;
        end
        
        
    end
    
end

[];

end



