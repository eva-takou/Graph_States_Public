function [Tab,Circuit,graphs]=disentangle_all_emitters(Tab,np,ne,Circuit,graphs,Store_Graphs)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to disentangle the emitters after having absorbed all the
%photons.
%Inputs: Tab: Tableau
%        np: # of photons
%        ne: # of emitters
%        Circuit: The circuit that generates the target graph state
%        Store_Graphs: true or false to store the progress on the graph
%        level (store graph after each disentanglement step)
%Output: Tab: The updated tableau
%        Circuit: The updated circuit
%        graphs: the updated graphs

for jj=1:np
   
    [cond_prod,~]=qubit_in_product(Tab,np+ne,jj);
    
    if ~cond_prod
        
       error(['Photon ',num2str(jj),' has not been absorbed.']) 
    end
    
end


for iter=1:2*ne 
    
   [Tab,flag,Circuit,graphs]=disentangle_two_emitters(Tab,np,ne,Circuit,graphs,Store_Graphs);
   
   if flag %flag is true when all the emitters are disentangled.
       
       return
       
   end
   
    
end

if ~flag
   
    error('Failed to disentangle all emitters.')
    
end

end


function [Tab,flag,Circuit,graphs]=disentangle_two_emitters(Tab,np,ne,Circuit,graphs,Store_Graphs)

n   = np+ne;
cnt = 0;

for emitter = np+1:n
   
    [cond_emitter, ~] = qubit_in_product(Tab,n,emitter);
    
    if ~cond_emitter
       
        cnt=cnt+1;
        entangled_emitters(cnt)=emitter;
        
    end
    
end

if cnt==0
    flag=true;

    return
else
    flag=false;
end


optimal_row = smallest_weight_Stab_em(Tab,np,ne,entangled_emitters);
SX_em       = Tab(optimal_row+n,entangled_emitters);
SZ_em       = Tab(optimal_row+n,entangled_emitters+n);

emm_in_X = entangled_emitters( SX_em & ~ SZ_em);
emm_in_Y = entangled_emitters( SX_em &   SZ_em);

for ll = 1: length(emm_in_X)
    
   Tab     = Clifford_Gate(Tab,emm_in_X(ll),'H');
   Circuit = store_gate_oper(emm_in_X(ll),'H',Circuit); 
   
end

for ll = 1: length(emm_in_Y)
   
   Tab     = Clifford_Gate(Tab,emm_in_Y(ll),'P');
   Tab     = Clifford_Gate(Tab,emm_in_Y(ll),'H');
   
   Circuit = store_gate_oper(emm_in_Y(ll),'P',Circuit);
   Circuit = store_gate_oper(emm_in_Y(ll),'H',Circuit);
    
end

SX_em       = Tab(optimal_row+n,entangled_emitters);
SZ_em       = Tab(optimal_row+n,entangled_emitters+n);

emm_in_Z = entangled_emitters(~SX_em &   SZ_em);

%Now the emitters in the particular row are in Z. Apply CNOT on 2 of them.

Tab     = Clifford_Gate(Tab,emm_in_Z(1:2),'CNOT');
Circuit = store_gate_oper(emm_in_Z(1:2),'CNOT',Circuit);



if Store_Graphs
    graphs  = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',num2str(emm_in_Z(1)),',',num2str(emm_in_Z(2)),'} [DE]'),graphs);
end


end


function optimal_Stabrow = smallest_weight_Stab_em(Tab,np,ne,entangled_emitters)

n       = np+ne;
Stabs   = Tab(n+1:2*n,1:2*n);
weight  = zeros(1,n);

for jj=1:n
    
   SX_em  = Stabs(jj,entangled_emitters);
   SZ_em  = Stabs(jj,entangled_emitters+n);
   
   emm_in_X = find( SX_em & ~ SZ_em);
   emm_in_Y = find( SX_em &   SZ_em);
   emm_in_Z = find(~SX_em &   SZ_em);
    
   weight(jj) = length(emm_in_X)+length(emm_in_Y)+length(emm_in_Z);
    
end

locs     = weight>1;
weight   = weight(weight>1);
[~,indx] = min(weight);

possible_rows   = 1:n;
possible_rows   = possible_rows(locs);
optimal_Stabrow = possible_rows(indx);


end


