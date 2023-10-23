function chi_G=chromatic_number(Adj,show_graph)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%Greedy implementation to assign proper coloring to the nodes of the graph.
%A graph can be colored with either Delta(G)+1 or Delta(G) colors. It is
%NP-hard in general to find optimal coloring. This algorithm does not find
%the optimal coloring.
%--------------------------------------------------------------------------
%Procedure from here: https://en.wikipedia.org/wiki/DSatur
%Dsatr algorithm colours the vertices of a graph one after another,
%adding a previously unused colour when needed.
%Once a new vertex has ben coloured the algorithm determines which of the
%remaining uncoloured vertices, has the highest number of colours in its
%neighborhood, and colours this vertex next.
%So, let the deg of saturation of a vertex be the number of different
%colours being used by its neighbors.
%--------------------------------------------------------------------------
%Steps:
%1. Let v be the uncolored vertex in G with highest deg of saturation.
%   In case of ties, choose the vertex among these with the largest degree
%   in the subgraph induced by the uncolored vertices.
%2. Assign v to the lowest color label, not being used by its neighbors.
%3. If all vertices have been colored end, otherwise return to step 1.
%
%Input: Adj: Adjacency matrix
%       show_graph: true or false to display the graph with colored nodes.
%Output: chi_G: the chromatic number

n      = length(Adj);
nodes  = 1:n;
colors = zeros(1,n);

while any(colors==0)
    
   %Step 1:
   
    v             = highest_deg_of_saturation(Adj,colors);
   %Step 2:
    Nv            = Get_Neighborhood(Adj,v);
    colors_neigh  = colors(Nv);
    colors(v)     = max(colors_neigh)+1;
    
end

%Check a color that has been used only once; can we substitute that color
%with a color that we have already used?

max_color = max(colors);

for jj=max_color:-1:1
    
   color      = find(colors==jj);
   occurrence = numel(color);
   
   if occurrence==1
       
       %Test if we can refine the color
       v                  = nodes(color);
       Nv                 = Get_Neighborhood(Adj,v);
       neighboring_colors = colors(Nv);
       
       available_colors = setxor(colors,neighboring_colors);
       
       if ~isempty(available_colors)
           colors(v) = available_colors(1);
           
       end
       
       
   end
   
    
    
end


chi_G = length(unique(colors));

if show_graph
    
    G=graph(Adj);
    
    h=plot(G,'linewidth',2,'EdgeColor','k','MarkerSize',8);
    h.NodeFontSize=16;
    hsv_colors = hsv(chi_G);
    
    
    for jj=1:max(colors)
        
       nodes_color_j = nodes(colors==jj);
       
       highlight(h,nodes_color_j,'NodeColor',hsv_colors(jj,:))
        
        
        
    end
    
    
else
    return
    
    
end


end


function sat_deg=deg_of_saturation(v,Adj,all_colors)
%v needs to be uncolored as well


Nv         = Get_Neighborhood(Adj,v);
all_colors = all_colors(Nv);
sat_deg    = nnz(all_colors); %find the non-zeros, i.e. colored vertices

end


function v=highest_deg_of_saturation(Adj,all_colors)

n=length(Adj);

uncolored_vertices = find(all_colors==0);

for k=1:length(uncolored_vertices)
    
    v          = uncolored_vertices(k);
    sat_deg(k) = deg_of_saturation(v,Adj,all_colors);
    
end


max_val = max(sat_deg);
v       = uncolored_vertices(sat_deg==max_val);

if length(v)==1
    
    return
    
else %Case of ties, choose the vertex with largest degree in subgraph induced by uncoloured vertices
    
    other_nodes = setxor(1:n,uncolored_vertices);
    
    Adj(:,other_nodes)=[];
    Adj(other_nodes,:)=[];

    G    = graph(Adj);
    degs = degree(G);
    
    [~,sort_order] = sort(degs,'descend');
    v              = uncolored_vertices(sort_order);
    v              = v(1);
end
    



end
