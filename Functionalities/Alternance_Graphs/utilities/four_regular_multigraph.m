function [out,G] = four_regular_multigraph(m,formatOption,layout)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to plot the 4 regular graph obtained from a double occurence word
%
%


switch formatOption
    
    case 'EdgeList'
        
        EdgeList = [];
        
        for jj=1:length(m)-1
    
            EdgeList = [EdgeList;[m(jj),m(jj+1)]];
        
        end
        
        EdgeList = [EdgeList; [m(end),m(1)]];
        
        out = EdgeList;
        
    case 'Adjacency'
        
        n              = max(m);
        Adj_multigraph = sparse(n,n); %probably not very efficient to construct a sparse one but ok.
        
        %put in j,k and k,j entry the # of edges between j and k

        for jj=1:length(m)-1
            
           v1 = m(jj);
           v2 = m(jj+1);
           
           Adj_multigraph = Adj_multigraph + sparse(v1,v2,1,n,n);
           Adj_multigraph = Adj_multigraph + sparse(v2,v1,1,n,n);
            
        end
        
        v1 = m(end);
        v2 = m(1);
        Adj_multigraph = Adj_multigraph + sparse(v1,v2,1,n,n);
        Adj_multigraph = Adj_multigraph + sparse(v2,v1,1,n,n);
        
        out = Adj_multigraph;
   
        G=[];
        return
        
end

figure(1)
G = graph(EdgeList(:,1),EdgeList(:,2));

h=plot(G,'layout',layout)

h.LineWidth  = 1;
h.MarkerSize = 8;
h.NodeColor  = 'k';
h.NodeFontSize = 14;










end