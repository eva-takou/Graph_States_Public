function binary_rank=sprank_GF2(binary_matrix)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to find the rank of the binary matrix.
%Input: the binary matrix
%Output: the binary rank.

binary_matrix = Gauss_elim_GF2(binary_matrix);    
binary_rank   = 0;


for ii=1:size(binary_matrix,1)

    test_cond = find(binary_matrix(ii,:), 1);

    if ~isempty(test_cond)

        binary_rank = binary_rank + 1;

    end

end





end