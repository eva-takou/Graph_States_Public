function  value = ai_di_plus_bi_ci(VEC,ith_entry)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

%Input: A vector 4n x 1.
%       ii: the i-th entries of the coeffs a's, b's, c's, d's

%the ordering is: x = [c_1 ... c_n a_1 ... a_n d_1 ... d_n b_1 ... b_n]^T 
%we want a_i*d_i+b_i*c_i=1 for all i\in[1,n]

n     = length(VEC)/4;
value = mod( VEC(ith_entry+n)*VEC(ith_entry+2*n) + VEC(ith_entry)*VEC(ith_entry+3*n) ,2);

end
