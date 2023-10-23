function Tab_Aug = AugmentTableau(Tab,ne)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Inputs: Tab (in RREF)
%        ne  (# of emitters needed to generate the graph)
%        The # of emitters is determined by the height fun.
%Output: The augmented tableau where we initialize emitters in |0>.

[~,np] = size(Tab);
np     = (np-1)/2;
n      = np+ne;

%Destabs/Stabs augmented in total space

Dx     = [Tab(1:np,1:np)           , sparse(np,ne)]; 
Dz     = [Tab(1:np,np+1:2*np)      , sparse(np,ne)];
Sx     = [Tab(np+1:2*np,1:np)      , sparse(np,ne)];
Sz     = [Tab(np+1:2*np,np+1:2*np) , sparse(np,ne)]; %all np x n size

ph_D   = [Tab(1:np,2*np+1)           ; sparse(ne,1)]; % n x 1 size
ph_S   = [Tab(np+1:2*np,2*np+1)      ; sparse(ne,1)]; % n x 1 size

%initialize the emitters in |0>

Sx_em = sparse(ne,n);                    %ne x n in size
Sz_em = [sparse(ne,np) , speye(ne)];     %ne x n in size
Dx_em = [sparse(ne,np) , speye(ne) ];
Dz_em = sparse(ne,n);

Dx = [Dx;Dx_em];
Dz = [Dz;Dz_em];
D  = [Dx,Dz];

Sx = [Sx;Sx_em];
Sz = [Sz;Sz_em];
S  = [Sx,Sz];

Tab_Aug = [D;S];       %2nx2n
ph      = [ph_D;ph_S]; %2nx1

Tab_Aug=[Tab_Aug,ph];
Tab_Aug=[Tab_Aug; sparse(1,2*n+1)];


end
