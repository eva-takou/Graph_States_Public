function  Matrix=SWAP_rows(Matrix,row1,row2)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to swap rows in a matrix.
%Input: The matrix, and the rows
%Output: The matrix with swapped rows.

Matrix([row2,row1],:)=Matrix([row1,row2],:);


end