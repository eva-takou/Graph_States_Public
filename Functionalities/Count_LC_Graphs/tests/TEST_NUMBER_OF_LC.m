%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%

clc
clear
close all

n                   = 6;
iterMax             = 100;

for iter=1:iterMax

    Adj0        = create_random_graph(n);
    l           = count_l_Bouchet(Adj0);
    Adj_LC      = Map_Out_Orbit(Adj0,'bruteforce');
    
    if l~=length(Adj_LC)

        error('Something is wrong in the code.')

    end


end
