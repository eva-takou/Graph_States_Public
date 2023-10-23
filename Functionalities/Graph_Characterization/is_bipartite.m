function bool=is_bipartite(Adj)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%Check if the graph is bipartite.
%bool: true or false

g=graph(Adj);

events = {'edgetonew', 'edgetodiscovered', 'edgetofinished'};
T = bfsearch(g, 1, events, 'Restart', true);
partitions = false(1, numnodes(g));
is_bipart = true;
is_edgetonew = T.Event == 'edgetonew';
ed = T.Edge;

for ii=1:size(T, 1)   
    if is_edgetonew(ii)
        partitions(ed(ii, 2)) = ~partitions(ed(ii, 1));
    else
        if partitions(ed(ii, 1)) == partitions(ed(ii, 2))
            is_bipart = false;
            break;
        end
    end
end

bool=is_bipart;

end