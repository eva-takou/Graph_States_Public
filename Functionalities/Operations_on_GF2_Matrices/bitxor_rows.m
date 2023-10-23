function  Matrix=bitxor_rows(Matrix,row_replace,row_fixed)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to output the updated matrix after adding 2 rows.
%The row_replace is updated in the input matrix.
%Input: Matrix: The matrix to do the row operation
%       row_replace: the row that is replaced
%       row_fixed: the row that is added to the row that is replaced.
%Output: The updated matrix.

added_rows            = Matrix(row_replace,:)+ Matrix(row_fixed,:);
added_rows            = mod(added_rows,2);
Matrix(row_replace,:) = added_rows;


end