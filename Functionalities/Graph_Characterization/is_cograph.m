function [bool,paths]=is_cograph(Adj,visualizeOption)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%A cograph is a P4-free graph.
%Check if the graph is co-graph.
%Output: bool: true or false
%        paths: if the graph is not co-graph it highlights the P4.

close all;


MinPathLength=3;
MaxPathLength=3;

G=graph(Adj);
n=length(Adj);

paths = [];
bool  = true; %cograph i.e., does not contain P4.

for s=1:n

    for t=1:n
    
        if s~=t
            
            [paths,edgepaths]=allpaths(G,s,t,'MinPathLength',MinPathLength,'MaxPathLength',MaxPathLength);
            
            if ~isempty(paths)
               
                bool = false; %contains P4.
                
                if visualizeOption
                
                    p = plot(G);
                    
                    %highlight the path:
                    highlight(p,'Edges',edgepaths{1},'EdgeColor','r','LineWidth',1.5,'NodeColor','r','MarkerSize',6)
                    
                end
                
                return
               
                
            end
            
        end
    end

end
 


end