function EdgeList=Get_4_Reg_Multigraph(m)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to obtain the edgelist of the 4-regular multigraph that
%corresponds to the double occurrence word.
%
%Input:         m: The alternance word
%Output: Edgelist: The Edgelist of the 4-regular multigraph.


EdgeList = [];

for jj=1:length(m)-1

    EdgeList = [EdgeList;[m(jj),m(jj+1)]];

end

EdgeList = [EdgeList; [m(end),m(1)]];



figure(1)
clf;
G = graph(EdgeList(:,1),EdgeList(:,2));

h=plot(G,'layout',layout);

h.LineWidth  = 1;
h.MarkerSize = 8;
h.NodeColor  = 'k';
h.NodeFontSize = 14;



end