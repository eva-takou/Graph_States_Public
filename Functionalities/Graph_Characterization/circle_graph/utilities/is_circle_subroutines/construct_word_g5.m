function m=construct_word_g5(Adj)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%It should happen that g5 is LC equivalent to the 5-cycle.
%If not, then something is wrong.
Adj0  = Adj;
AdjCn = create_Cn(5,'Adjacency');
edges = sum(Adj,'all')/2;
degs  = degree(graph(Adj));

%======= First, is the graph already C5? ==================================

if edges==5 && all(degs==2)

   %disp('Graph g5 is C5 up to permutation.') 
   
   m = permute_to_C5(AdjCn,Adj);
   
   if ~is_correct_word(Adj,m)
       
       error('Error in construction of word for g5.')
       
   end
   
   return
    
end

%====== The graph must be LC equivalent to a C5 ===========================

if edges==6 && length(find(degs==2))==4 && length(find(degs==3))==1 %Single chord
   
   v3  = find(degs==3);
   Adj = Local_Complement(Adj,v3);
   m   = permute_to_C5(AdjCn,Adj);
   m   = transform_word_LC(m,{v3});
   
elseif edges==7 && length(find(degs==2))==2 && length(find(degs==3))==2  %a node has deg=4
    
    v2 = find(degs==2);
    
    for jj=1:length(v2)
        
        Adj = Local_Complement(Adj,v2(jj));
        
    end
    
    m   = permute_to_C5(AdjCn,Adj);
    v2  = flip(v2);
    
    for jj=1:length(v2)
        
        m   = transform_word_LC(m,{v2(jj)});
        
    end
    
elseif edges==8 && length(find(degs==3))==4 %a node has degree 4
    
    %it would be false, because we would have a split
    error('Should not step into 4 nodes of deg=3.')
    
elseif edges==6 && length(find(degs==3))==2 && length(find(degs==2))==3  %basically a house
    
    v3 = find(degs==3);
    N1 = Get_Neighborhood(Adj,v3(1));
    N2 = Get_Neighborhood(Adj,v3(2));
    
    w   = intersect(N1,N2);
    Adj = Local_Complement(Adj,w);
    m   = permute_to_C5(AdjCn,Adj);
    m   = transform_word_LC(m,{w});
    
else
    error('Did not cover some case in constructing g5.')
    
    
    
end



if ~is_correct_word(Adj0,m)

   error('Check construction of word again.')

else


   return

end
    

end

