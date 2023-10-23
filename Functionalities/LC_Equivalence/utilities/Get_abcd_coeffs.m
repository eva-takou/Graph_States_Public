function [a_s,b_s,c_s,d_s]=Get_abcd_coeffs(Null_vec,n)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

%Function to get the a-d coeffients from the Null vector.
%Input: Null_vec: A 4n x 1 Null vector
%       n: 1/4 of the total unknown coefficients
%x = [c_1 ... c_n a_1 ... a_n d_1 ... d_n b_1 ... b_n]^T   

c_s = Null_vec(1:n);
a_s = Null_vec(n+1:2*n);
d_s = Null_vec(2*n+1:3*n);
b_s = Null_vec(3*n+1:end);

end
