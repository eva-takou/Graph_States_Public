function [m,nodes_OUT,flag_Meas]=is_vertex_minor(G,Gp)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: Nov 5, 2023
%--------------------------------------------------------------------------
%
%Function to check if Gp is vertex minor of G
%
%Input: Adjacency matrix of G
%       Adjacency matrix of Gp
%
%Output: m: nan if false
%           an array with LC sequence to apply to G before removal of node
%        nodes_OUT: An array of indices corresponding to the nodes that 
%                   need to be removed from G.
%        flag_Meas: A cell array recording 'X', 'Y' or 'Z' measurement of
%                   each node.
%
%--------------------------------------------------------------------------

%G and G' should have no nodes of deg=0.

gg = graph(G);
if any(degree(gg)==0)
    
    error('G contains isolated node(s).')
    
end

nodesG=1:length(G);

%------- Remove any isolated nodes from G' --------------------------------
to_remove=[];
nodesGp = 1:length(Gp);

for jj=1:length(Gp)
    
    if all(Gp(jj,:)==0)
        
        to_remove=[to_remove,jj];
        
    end
    
end

Gp(to_remove,:)=[];
Gp(:,to_remove)=[];
nodesGp(to_remove)=[];

if any(degree(graph(Gp))==0)
   error('G` has isolated node(s).') 
end


%---- Initialize empty stacks for output-----------------------------------
m=[];
flag_Meas={};
nodes_OUT=[];

%--------------------------------------------------------------------------

[m,flag_Meas,nodes_OUT]=subroutine_is_vertex_minor(G,Gp,nodesG,nodesGp,m,flag_Meas,nodes_OUT);

if isnan(m) 
    
    nodes_OUT=nan;
    flag_Meas=nan;
    return
    
end

nodes_OUT = flip(nodes_OUT);
flag_Meas = flip(flag_Meas);


%------ Verification step based on graph operations -----------------------
Gtest=G;

for jj=1:length(flag_Meas)

    v=nodes_OUT(jj);
    M=flag_Meas{jj};
    
    if strcmpi(M,'Y')
        
        Gtest=Local_Complement(Gtest,v);
        
    elseif strcmpi(M,'X')
        
        w=Get_Neighborhood(Gtest,v);
        w=w(1);
        
        Gtest=Local_Complement(Gtest,w);
        Gtest=Local_Complement(Gtest,v);
        Gtest=Local_Complement(Gtest,w);
        
    end
    
       Gtest(v,:)=sparse(1,length(Gtest));
       Gtest(:,v)=sparse(length(Gtest),1);
    
    
end

to_remove=[];

for k=1:length(Gtest)
   
    if all(Gtest(k,:)==0)
       
        to_remove=[to_remove,k];
        
    end
    
end


Gtest(to_remove,:)=[];
Gtest(:,to_remove)=[];

if ~all(all(Gtest==Gp))
    
    [~,bool_LC]=LC_check(Gtest,Gp);
    
    if ~bool_LC %Should at least be LC equivalent
   
        error('Incorrect calculation of VM.')
    end
    
end

end


function [m,flag_Meas,nodes_OUT]=subroutine_is_vertex_minor(G,Gp,nodesG,nodesGp,m,flag_Meas,nodes_OUT)
%Subroutine for vertex minor.
%Keep removing nodes till Gp and G have the same nodes.

if length(nodesGp)>length(nodesG) %definitely not VM
    
   m              = nan;
   flag_Meas      = nan;
   return
   
end

if isnan(m) 
     
   return 
   
end



%--------- LC check -----------------------------------------------------

if length(nodesGp)==length(nodesG) && all(sort(nodesG)==sort(nodesGp))
   
    %The removal of a node could have broken G into many connected graphs.
    %Need to apply for each smaller graph the LC_check

    bins_G     = conncomp(graph(G));
    num_sub_G  = max(bins_G);  %# of connected subgraphs of G
    
    if num_sub_G>1
        
        m             = nan;
        return
        
    end
    
    [~,flag] = LC_check(G,Gp);
    
    if flag
        
        if any(isnan(m))
           
            error('m should not contain nan values') 
            
        end
        
        return
        
    else
        
        m             = nan;
        return
        
    end
    
    
    
end

%----------------- Continue removing nodes --------------------------------

if length(nodesG)>length(nodesGp)
    
    V = setdiff(nodesG,nodesGp); %need to remove nodes from G which are not in Gp
    v = V(1);                    %name of node v in big graph G (w/o removal of nodes)
    
    name_v = find(nodesG==v); %this is the index where nodesG(indx)=v. 
                              %name_v corresponds to the ordering of
                              %current G (potentially after removal of nodes)
    
                              
    %------------- Check if G\{v} is VM -----------------------------------
    
    G1           = G;
    G1(:,name_v) = [];
    G1(name_v,:) = [];
    
    %------------- Check if G*v\{v} is VM ---------------------------------
    
    G2           = G;
    G2           = Local_Complement(G2,name_v);
    G2(:,name_v) = [];
    G2(name_v,:) = [];
    
    %------------ Check if G*v*w*v\{v} is VM ------------------------------
    
    G3 = G;
    w  = Get_Neighborhood(G,name_v);
    
    if ~isempty(w)

        w      = w(1);
        name_w = find(nodesG==w);
        
        G3 = Local_Complement(G3,name_w);
        G3 = Local_Complement(G3,name_v);
        G3 = Local_Complement(G3,name_w);
        
    end
    
    G3(:,name_v)=[];
    G3(name_v,:)=[];    
    
    
    nodesG(name_v)=[]; %In any case we remove the node v.
    
    
    
    %This line will recurse many times, till we test LC equivalence
    [mz,flag_Meas,nodes_OUT]=subroutine_is_vertex_minor(G1,Gp,nodesG,nodesGp,m,flag_Meas,nodes_OUT);

    if isnan(mz)
        
        
        [my,flag_Meas,nodes_OUT]=subroutine_is_vertex_minor(G2,Gp,nodesG,nodesGp,m,flag_Meas,nodes_OUT);

        if isnan(my) 


            [mx,flag_Meas,nodes_OUT]=subroutine_is_vertex_minor(G3,Gp,nodesG,nodesGp,m,flag_Meas,nodes_OUT);

            
            if isnan(mx)

               m              = nan;
               return

            else

               flag_Meas=[flag_Meas,{'X'}];
               nodes_OUT=[nodes_OUT,v];
               m=[m,[w,v,w]]; 
               return

            end

        else


            flag_Meas=[flag_Meas,{'Y'}];
            nodes_OUT=[nodes_OUT,v];
            m=[m,v];

            return

        end
            
    else
        
        flag_Meas=[flag_Meas,{'Z'}];
        nodes_OUT=[nodes_OUT,v];
        m=[m,mz];
        return
        
    end
    
    
end






end






