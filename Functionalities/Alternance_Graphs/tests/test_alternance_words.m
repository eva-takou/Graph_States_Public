%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

clc;
clear;

warning('off')
n=8;
iterMax=100;

for iter=1:iterMax
    
    
    Adj=create_random_graph(n);
    
    m=double_occurrence_arbitrary_graph(Adj);
    
    
    if ~isempty(m) %it is a circle graph and has a word representation
        
        Adj_m = double_occur_words_to_graphs(m,'Adjacency');
        
        
        if ~all(all(Adj==Adj_m{1}))
           error('wrong construction of the word.') 
        end
        
    end
    
    
    
end