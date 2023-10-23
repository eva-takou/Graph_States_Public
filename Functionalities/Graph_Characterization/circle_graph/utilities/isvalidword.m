function isvalidword(m)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Check if the word is a valid alternance word.
%Input m: the word

if (-1)^length(m)~=1
    error('Length of word is not even number.')
end

nodes = unique(m);

for jj=1:length(nodes)
    
    v=nodes(jj);
   
    locs = find(m==v);
    
    if length(locs)~=2
        error('word does not have double occurrence')
    end
    
end



end
