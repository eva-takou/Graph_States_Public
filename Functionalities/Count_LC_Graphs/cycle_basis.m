function [CB,newcycles,store_nu_C]=cycle_basis(Adj)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Basis for the even cycles of an input graph G. CB is represented
%by the rows of the output matrix (binary rep).
%Input:  Adj: Adjacency matrix
%Output: CB: The basis of cycles in binary rep.
%        newcycles:  The cycles in a list.
%        store_nu_C: The symmetric difference of all nodes in each cycle.


n              = length(Adj);
cycles         = cyclebasis(graph(Adj)); 


if isempty(cycles)
    CB         = zeros(1,n);
   
    newcycles  = [];
    store_nu_C = [];
    return
end

%=========== Check that all cycles are even ==============================

indx=[];

for jj=1:length(cycles)
    
   %Construct the induced subgraph whose edgeset is only the loop formed by
   %the nodes in the cycle.
   this_cycle = cycles{jj};
   Adj0       = sparse(n,n);
   
   for p=1:length(this_cycle)-1
      
       node1 = this_cycle(p);
       node2 = this_cycle(p+1);
       Adj0  = Adj0 + sparse([node1,node2],[node2,node1],1,n,n);
       
   end
   
   node1 = this_cycle(1);
   node2 = this_cycle(end);
   Adj0  = Adj0 + sparse([node1,node2],[node2,node1],1,n,n);


   G0  = graph(Adj0);
   deg = degree(G0);
   
   if all((-1).^deg==1) %all deg is even
       
       indx=[indx,jj];
   end
    
end

if length(indx)==length(cycles) && ~isempty(cycles)
   
    disp('All cycles are even.')
    even_cycles = cycles;

else
    
    even_cycles  = cycles(indx);
    
end


if isempty(even_cycles)
   
    CB = zeros(1,n);
    newcycles  = [];
    store_nu_C = [];
    disp('--------------- No even cycles detected. --------------------------')
    return

end

%=============== Get the binary rep =======================================
newcycles  = cycle_to_cell(even_cycles);
newcycles  = to_list_of_edges(newcycles);
MCycles    = [];

cnt=0;
for jj=1:length(newcycles)
    
    this_cycle =  newcycles{jj};
    nu_C       =  [];
    
    for ll=1:length(this_cycle)
        
        this_edge  = this_cycle{ll};
        temp_neigh = neighborhood_xy(Adj,this_edge(1),this_edge(2));
        nu_C       = setxor(nu_C,temp_neigh); %Addition=symmetric difference
        
    end
    
    if ~isempty(nu_C)
       
        cnt             = cnt+1;
        store_nu_C{cnt} = nu_C;
        
    end
    
    %Map to binary
    
    if isempty(nu_C)
       
        vP = zeros(1,n);
        
    else
        
        vP        = zeros(1,n);
        vP(nu_C)  = 1;
        
    end
    
    
    MCycles = [MCycles;vP];
    
end

if cnt==0
    
    store_nu_C=[];
    
end

%==== Do Gauss elimination: =========================================
MCycles = Gauss_elim_GF2(MCycles);

MCycles(~any(MCycles,2),:) = []; %Keep only nnz rows
CB                         = MCycles;

end


function newlist=to_list_of_edges(newcycles)

for jj=1:length(newcycles)
    
   table_of_edges = newcycles{jj} ;
   
   for row=1:size(table_of_edges,1)
   
        newlist{jj}{row} = table_of_edges(row,:);
        
   end
   
    
end


end