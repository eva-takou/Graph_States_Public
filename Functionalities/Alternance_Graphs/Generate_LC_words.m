function [store_word,adj]=Generate_LC_words(Adj,iters)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Generate words corresponding to LC graphs of an arbitrary input graph.
%Pick a random node and apply a k-transformation (i.e., LC operation).
%
%This method does not ensure that it will span the complete orbit. If we
%know the size of the LC orbit, we can make the iterations sufficiently
%larget to ensure that we find all LC graphs.
%
%Input: Adj:   Adjacency matrix of the graph for which we want to find the
%              local clifford equivalent graphs
%       iters: maximum iterations of sampling
%
%Output: words_LC: the alternance words of the LC graphs that we found.


verbose  = false;
[bool,m] = is_circleG(Adj,verbose);

if ~bool
    store_word=[];
    return
end

init_word = m;
n         = max(init_word);

LCnodes    = randi([1,n],1,iters);
store_word = init_word;

LCnodes = parallel.pool.Constant(LCnodes);

parfor iter=1:iters
    
    store_word(iter,:)=update_word_after_LC(init_word,LCnodes.Value(1:iter));
    
end

%Now make sure that we exclude the words that give rise to same graphs:

store_word = [init_word;store_word];
store_word = unique(store_word,'rows');

%I think that sometimes the above is not enough, so then do the following:

adj=double_occur_words_to_graphs(store_word,'Adjacency');
indx=[];
for k1=1:length(adj)
    
    for k2=k1+1:length(adj)
   
        if all(all(adj{k1}==adj{k2}))
           
            indx=[indx,k2];
            break
            
        end
        
    end
    
end
        
store_word(indx,:)=[];      

 
end


