function bool=is_complete_bipartite(A,B,Adj)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Check if every node in A connects with every node in B?

if length(B)==1
    
    bool=false;
    
    return
    
end
    
LA = length(A);
NA = cell(1,LA);

for jj=1:LA
   
    NA{jj} = Get_Neighborhood(Adj,A(jj))';
    NA{jj} = setdiff(NA{jj},A);
    
end


for kk=2:length(B)
    
   Bsets = nchoosek(B,kk);
   
   for ll=1:size(Bsets,1)
       
      
       this_B = Bsets(ll,:);
       
       discovered=false(1,LA);
       
       for p=1:LA
          
           
           if length(NA{p})~=length(this_B)
               
               
               break
              
           else
               
               if all(NA{p}==this_B)
                   
                   discovered(p)=true;
                   
                   
               end
               
               
           end
           
           
       end
       
       
       if all(discovered)
           
           bool=true;
           return
           
           
       end
       
       
   end
    
    
end

bool=false;




end