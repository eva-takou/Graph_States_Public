function [Meas_OUT,Nodes_OUT]=is_vertex_minor_brute(G,Gp)
%--------------------------------------------------------------------------
%Created by Eva Takou
%Last modified: Nov 5, 2023
%--------------------------------------------------------------------------
%
%Function to check if Gp is vertex minor of G in a brute-force way.
%
%Input: Adjacency matrix of G
%       Adjacency matrix of Gp
%
%Output: 
%        Nodes_OUT: An array of indices corresponding to the nodes that 
%                   need to be removed from G.
%        Meas_OUT: A cell array recording 'X', 'Y' or 'Z' measurement of
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

%Now form all combinations of removing nodes from the graph and measuring

V=setdiff(nodesG,nodesGp);

Vperms = perms(V);

nodesGfixed=nodesG;

Meas_Combs=combs([1,2,3],length(V)); %1->Z, 2->Y, 3->X, 3^|V(G)\V(G')| combinations

Meas_OUT={};

for k=size(Vperms,1):-1:1

    this_V = Vperms(k,:);
    
    for l=1:size(Meas_Combs,1)
       
        nodesG = nodesGfixed;
        Gtemp  = G;        
        
        this_Meas = Meas_Combs(l,:);
        
        for r=1:length(this_Meas)
            
            meas_Basis = this_Meas(r);
            v          = this_V(r);
            name_v     = find(nodesG==v);
            
            if meas_Basis==1 %Z
               
            elseif meas_Basis==2 %Y
                
                Gtemp=Local_Complement(Gtemp,name_v);
                
            elseif meas_Basis==3 %X
                
                w=Get_Neighborhood(Gtemp,name_v);
                
                if ~isempty(w)
                   w=w(1);
                   name_w=find(nodesG==w);
                   Gtemp=Local_Complement(Gtemp,name_w);
                   Gtemp=Local_Complement(Gtemp,name_v);
                   Gtemp=Local_Complement(Gtemp,name_w);
                end
                
            end
            
            Gtemp(:,name_v)=[];
            Gtemp(name_v,:)=[];
            
            nodesG(nodesG==v)=[];
            
        end
        
        %Here test the LC equivalence:
        
        [~,bool_LC]=LC_check(Gtemp,Gp);
        
        if bool_LC
           
            
            Nodes_OUT = this_V;
            
            for t=1:length(this_Meas)
               
                if this_Meas(t)==1
                   
                    Meas_OUT=[Meas_OUT,{'Z'}];
                elseif this_Meas(t)==2
                    
                    Meas_OUT=[Meas_OUT,{'Y'}];
                    
                elseif this_Meas(t)==3
                    
                    Meas_OUT=[Meas_OUT,{'X'}];
                    
                end
                
            end
            
            
            
            return
            
        end
        
        
        
    end
    
    
    
    
    
end


%if we did not return then we failed

Meas_OUT=nan;
Nodes_OUT=nan;




end