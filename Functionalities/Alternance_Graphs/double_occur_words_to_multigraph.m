function out=double_occur_words_to_multigraph(words,formatOption)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Construct the multigraph from a double occurence word.
%
%Input: words (the double occurence words as a matrix where each row is a
%             word)
%Output: EdgeList
%

for ll=1:size(words,1)
    
    this_word=words(ll,:);
    EdgeList{ll}=[];
    
    for kk=1:length(this_word)
    
        if kk<length(this_word)
            
            EdgeList{ll} = [EdgeList{ll}; [this_word(kk),this_word(kk+1)]];
        else
            EdgeList{ll} = [EdgeList{ll};[this_word(kk),this_word(1)]];
            
        end
    end
    
    
    
    
end

switch formatOption
    
    case 'EdgeList'
   
        
        out=EdgeList;
        return
        
        
    case 'Adjacency'
        
        n = max([EdgeList{:}]);
        out=edgelist_to_Adj(EdgeList,n);
        
end



end