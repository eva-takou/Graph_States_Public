function Tab=rowsum(Tab,H_replace,I)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to add 2 rows together in the Tableau.
%Input: Tab: Tableau
%       H_replace: The row to replace
%       I: The row to add to H_replace
%Output: The updated Tableau.

[~,n]=size(Tab);

if (-1)^n==1 %even so no phase vec was provided
    n=n/2;   %this is for the 2nd evaluation of the height function

else
    n=(n-1)/2;

end

row1 = Tab(H_replace,1:2*n);
row2 = Tab(I,1:2*n);

rest_pos = find(  ~(row1(1:n)==row2(1:n) & row1(n+1:2*n)==row2(n+1:2*n)) ....
              &   ~(row1(1:n)==0 & row1(n+1:2*n)==0) ...
              &   ~(row2(1:n)==0 & row2(n+1:2*n)==0));

if isempty(rest_pos)
   
    
    Tab(H_replace,end)   = mod(Tab(H_replace,end)+Tab(I,end),2);
    
else
    
    if (-1)^(length(rest_pos))==1 %even
       
        Tab(H_replace,end)   = mod(Tab(H_replace,end)+Tab(I,end),2);
        
    else
        
        Tab(H_replace,end)   = mod(Tab(H_replace,end)+Tab(I,end)+1,2);
    end
    
    
end

Tab(H_replace,1:2*n) = mod(Tab(H_replace,1:2*n)+Tab(I,1:2*n),2);




end