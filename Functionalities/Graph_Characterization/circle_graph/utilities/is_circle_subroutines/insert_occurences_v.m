function mnew=insert_occurences_v(m,v,locs)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
mnew = m;

if locs(1)==1 && locs(2)==length(m)
   
    mnew = [v,mnew(1:end-2),v,mnew(end-1:end)];
    
elseif locs(1)==1 %locs2 is some i-th position
    
    mnew = [v,mnew(1:locs(2)-2),v,mnew(locs(2)-1:end)];
    
elseif locs(1)>1 && locs(2)==length(mnew)
    
    mnew = [mnew(1:locs(1)-1),v,mnew(locs(1):end-2),v,mnew(end-1:end)];
else %locs1 and locs2 are in i-th and j-th position
    
    mnew = [mnew(1:locs(1)-1),v,mnew(locs(1):locs(2)-2),v,mnew(locs(2)-1:end)];
    
end

if ~all(locs==find(mnew==v))
    
    error('Did not place correctly the occurence of v.')
    
end

if length(mnew)~=length(m)+2
   
    error('Word was not augmented by +2 letters.')
    
end

isvalidword(mnew)


end
