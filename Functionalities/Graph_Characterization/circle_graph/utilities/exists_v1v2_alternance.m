function bool = exists_v1v2_alternance(u,v,word)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Check if the word has a particular alternance uvuv or vuvu
%Input: u: a graph node
%       v: another graph node
%       word: the alternance word
%Output: bool: true or false

locs_u = find(word==u);
l1_u   = locs_u(1);
l2_u   = locs_u(2);

locs_v = find(word==v);
l1_v   = locs_v(1);
l2_v   = locs_v(2);

alternance1 = [l1_u,l1_v,l2_u,l2_v];
alternance2 = [l1_v,l1_u,l2_v,l2_u];

if issorted(alternance1) || issorted(alternance2)
   
    bool=true;
    
else
    
    bool=false;
    
end



end
