function [varargout]=is_split_free_brute(Adj,verbose)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Brute force implementation to check if input graph is split-free.
%Input: Adj: The adjacency matrix
%       versbose: true or false to print statements
%Output: bool: true or false
%        if false: output the split.


n=length(Adj);

for jj=2:n-1
   
    A=nchoosek(1:n,jj);
    
    for ll=1:size(A,1)
       
        this_A = A(ll,:);
        %this_B = setxor(1:n,this_A);
        this_B = MY_setdiff(1:n,this_A); %faster implementation than setxor
        
        NA = [];
        NB = [];
        
        for k1=1:length(this_A)
            
            NA = [NA,Get_Neighborhood(Adj,this_A(k1))'];
            
        end
        
        NA = setdiff(NA,this_A);
       
        
        for k1=1:length(this_B)
            
            NB = [NB,Get_Neighborhood(Adj,this_B(k1))'];
            
        end
        
        NB = setdiff(NB,this_B);
        
        
        if length(this_A)<2 || length(this_B)<2 
           
            continue %to next iter
            
        end
        
        
        flag_split = true;
        
        for l1=1:length(NB)
           
            u=NB(l1);
            
            for l2=1:length(NA)
                
                v=NA(l2);
                
                if Adj(u,v)==0
                    
                    flag_split = false;
                
                    break
                end
                
                
            end
            
            if ~flag_split
                break
                
            end
            
        end
        
        if flag_split
            
               
            if verbose
                
            
                disp(['Split was found. The partition is A=',num2str(this_A),' and B=', num2str(this_B)])
                
                
                
            end 
            
            bool=false;
            varargout{1}=bool;
            varargout{2} = {{this_A},{this_B}};
            varargout{3} = {{NB},{NA}};
            
            return
            
        end
        
        
        
        
    end
        
            
end
        
   
        
  
bool=true;

varargout{1}=bool;  
varargout{2}={[]};  
varargout{3}={[]};  


end








