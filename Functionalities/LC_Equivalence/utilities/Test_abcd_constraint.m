function cond = Test_abcd_constraint(NullVec,n)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

%Input: NullVec: A single null-vector 4x x 1.
%       n: 1/4 of the total unknowns a's, b's, c's, d's.

[a_s,b_s,c_s,d_s] = Get_abcd_coeffs(NullVec,n);

cnt=0;

for ii=1:n

    if mod(a_s(ii)*d_s(ii)+b_s(ii)*c_s(ii),2)==1

        cnt=cnt+1;

    end


end

if cnt==n

   cond=true;
else
    cond=false;
end



end
