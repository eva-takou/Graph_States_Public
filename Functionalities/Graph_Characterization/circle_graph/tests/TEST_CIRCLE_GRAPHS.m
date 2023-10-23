%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

%%
clc;
clear;
close all;


verbose = false;
n       = 4;
iterMax = 400;



%%
close all
clc


tiledlayout flow
%profile on
for iter=1:iterMax

    disp(['iter=',num2str(iter),' out of ',num2str(iterMax)])

    Adj=create_random_graph(n);

    [bool,m]=is_circleG(Adj,verbose);


    if bool

        nexttile
        plot(graph(Adj),'NodeColor','k','linewidth',1)
        

        
    end

end
%profile viewer

set(gcf,'color','w')
















