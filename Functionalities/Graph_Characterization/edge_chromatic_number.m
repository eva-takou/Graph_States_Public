function chi_e=edge_chromatic_number(Adj,show_graph)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%Script to find the edge chromatic number of a graph by first constructing
%its line graph representation.
%Input: Adj: Adjacency matrix
%       show_graph: true or false to display the graph with colored nodes.
%Output: chi_G: the chromatic number

Adj_LG = construct_line_graph(Adj);

n      = length(Adj_LG);
nodes  = 1:n;
colors = zeros(1,n);

while any(colors==0)
    
   %Step 1:
   
    v             = highest_deg_of_saturation(Adj_LG,colors);
   %Step 2:
    Nv            = Get_Neighborhood(Adj_LG,v);
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
       Nv                 = Get_Neighborhood(Adj_LG,v);
       neighboring_colors = colors(Nv);
       
       available_colors = setxor(colors,neighboring_colors);
       
       if ~isempty(available_colors)
           colors(v) = available_colors(1);
           
       end
       
       
   end
   
    
    
end


chi_e = length(unique(colors));

%the colors now correspond to edges of the input graph:
cnt=0;
for jj=1:length(Adj)
    
    for kk=jj+1:length(Adj)
   
        
        if Adj(jj,kk)==1
        
        
            cnt=cnt+1;
        
            edges{cnt} = [jj,kk];
            
        end
        
        
    end
    
end


if show_graph
    
    G=graph(Adj);
    
    h=plot(G,'linewidth',2,'EdgeColor','k','MarkerSize',8);
    h.NodeFontSize=16;
    hsv_colors = hsv(chi_e);
    
    
    for jj=1:max(colors)
        
       edge_indices = find(colors==jj);
       
       for ll=1:length(edge_indices)
           
           highlight(h,edges{edge_indices(ll)},'EdgeColor',hsv_colors(jj,:))
           
       end
        
        
        
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

