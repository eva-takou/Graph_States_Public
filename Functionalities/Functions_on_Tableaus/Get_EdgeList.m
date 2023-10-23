function [EdgeList,Le]=Get_EdgeList(Adj,Option)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

n = length(Adj);

switch Option
    
    case 'Cell'
        
        EdgeList = {};

        for jj=1:n

            for kk=jj+1:n
       
                if Adj(jj,kk)==1
           
                    EdgeList = [EdgeList;{[jj,kk]}];
       
                end
                
            end
            
        end

        Le = size(EdgeList,1);        
        
    case 'Matrix'
        
        EdgeList = [];

        for jj=1:n

            for kk=jj+1:n
       
                if Adj(jj,kk)==1
           
                    EdgeList = [EdgeList;[jj,kk]];
       
                end
                
            end
            
        end

        Le = size(EdgeList,1);        
     
end







end