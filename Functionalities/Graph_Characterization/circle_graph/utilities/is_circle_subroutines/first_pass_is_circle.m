function [gi,non_shift_nodes,Pseq]=first_pass_is_circle(Adj0)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Subroutine to obtain elementary i-minors of an input graph based on
%Bouchet's circle graph recognition algorithm. In this paper, this
%procedure is mentioned as the "first pass".


if ~is_split_free_brute(Adj0,false)
    
    error('Error in first pass. The input graph is not prime wrt splits.')
    
end

%Input: Adjacency matrix (should be prime)
%       Output: 

%If the input Adjacency matrix is a prime graph (wrt splits) then
%we will be able to find a pair for each elementary i-minor subgraph of G.
%If the input graph is circle, then those subgraphs will be circle graphs
%and we should be able to construct an alternance word.


n   = length(Adj0);
n0  = n;
Adj = Adj0;

non_shift_nodes = [];
vertices        = [];
Pseq            = [];
gi              = {Adj0};

while n>5
    
    for v = 1:n
    
        [node,p,bool_split_free,Adj] = find_pair(v,Adj); 
        
        if bool_split_free
            
           break 
           
        end
    
    end
    
    if bool_split_free

        non_shift_nodes = [non_shift_nodes,node];
        
        if n~=n0
           node{1} = node{1}+(n0-n); 
        end        
        
        vertices = [vertices,node];
        Pseq     = [Pseq,p];
        gi       = [gi,{Adj}];
        
    else
        
        bool_circle = false;
        return
        
    end
    
    n = length(Adj);
    
end









end