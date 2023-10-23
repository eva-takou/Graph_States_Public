function out=double_occur_words_to_graphs(words,formatOption)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Convert alternance words to the edgelist or to the adjacency matrix.
%Input: words: the double-occurence word(s)
%       formatOption: to output the results as edgelist(s) or the adjacency matrix/matrices.
%Output: The edgelist or the adjacency matrix/matrices of the word(s).

n=max(words,[],'all');

for ll=1:size(words,1)
    
    this_word    = words(ll,:);
    
    EdgeList{ll} = [];
   
    for v=1:n

       pos = find(this_word==v);

       nodes_in_between  = this_word(pos(1)+1:pos(2)-1);
       nodes_after       = this_word(pos(2)+1:end);

       w = intersect(nodes_in_between,nodes_after);

       for kk=1:length(w)

           EdgeList{ll}=[EdgeList{ll};[v,w(kk)]];

       end


    end    
    
    
end

switch formatOption
    
    case 'EdgeList'
        
        out=EdgeList;
        
        return
        
    case 'Adjacency'

        LE=length(EdgeList);
        
        Adj = cell(1,LE);
        
        for jj=1:LE
            
            this_list = EdgeList{jj};
            
            Adj{jj} = sparse(n,n);
            
            for kk=1:size(this_list,1)
                
                this_edge = this_list(kk,:);
                Adj{jj}   = Adj{jj} + sparse(this_edge(1),this_edge(2),1,n,n);
                Adj{jj}   = Adj{jj} + sparse(this_edge(2),this_edge(1),1,n,n);
                
            end
            
        end
        
        out=Adj;
        return
        
end




end