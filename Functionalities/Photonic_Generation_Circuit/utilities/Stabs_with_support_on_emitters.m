function row_indx_Stabs = Stabs_with_support_on_emitters(Tab,np,ne)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Find stabilizers that have support only on the emitters.
%This script is used for the time-reversed measurements.
%Inputs:      Tableau, 
%        # of photons, 
%        # of emitters.
%Output: the row indices of stabilizers.

n     = np+ne;    
Stabs = Tab(n+1:2*n,1:2*n);
cnt   = 0;
            
for ii=n:-1:1  

    Sx_p = Stabs(ii,1:np);
    Sz_p = Stabs(ii,n+1:n+np);

    if isempty(find(Sx_p, 1)) && isempty(find(Sz_p, 1))  %check for identity on all photons

        cnt                 = cnt+1;    
        row_indx_Stabs(cnt) = ii;

    end

end

if cnt==0
    row_indx_Stabs=[];
end



end