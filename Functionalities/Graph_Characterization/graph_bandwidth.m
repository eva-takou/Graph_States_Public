function [Adj,minbandwidth,order]=graph_bandwidth(Adj0)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%Function to calculate the bandwidth of a graph.
%Calculating the graph bandwidth of a given adjacency matrix.
%It is NP-hard to find it. Cannot be calculated efficiently for larger n.
%Input: Adj0: The adjacency matrix
%Output: Adj: The updated adjacency matrix (with smallest bandwidth)
%        minbandwidth: the bandwidth of the output adjacency matrix
%        order: the permutation order to transform the input to output
%        adjacency matrix.

n          = length(Adj0);
orderings  = perms(1:n);
P0         = eye(n);
bandwidths = zeros(1,factorial(n));

for jj=1:factorial(n)
    
    this_order     = orderings(jj,:);
    P              = P0;
    P(:,1:n)       = P(:,this_order);
    Adj            = P*Adj*P';
    bandwidths(jj) = matrix_bandwidth(Adj);
    
end

[minbandwidth,indx] = min(bandwidths);
order               = orderings(indx,:);
P                   = P0;
P(:,1:n)            = P(:,order);
Adj                 = P*Adj*P';

end


function max_val=matrix_bandwidth(M)
%The bandwidth of a matrix M=(mij) is the max value of |i-j| such that mij
%is non-zero.

vals = [];

for ii=1:length(M)
    
    for jj=ii+1:length(M)
        
        if M(ii,jj)==1
            
            vals=[vals,abs(ii-jj)];
            
        end
        
    end
    
end

max_val = max(vals);

end