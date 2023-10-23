%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%%
clc;
clear
verbose=true;

n=5;
iterMax=100;


for iter=1:iterMax
    
    disp('--------------')

    A=create_random_graph(n);


    if ~is_split_free_brute(A,verbose)

        LC_node = randi(n);
        is_split_free_brute(Local_Complement(A,LC_node),verbose);

    end




end