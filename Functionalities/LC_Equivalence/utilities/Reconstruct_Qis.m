function Q_i = Reconstruct_Qis(sols)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------

%Each sol is one null-vector

L = length(sols{1});
n = L/4;

for jj=1:length(sols)


    [a_s,b_s,c_s,d_s] = Get_abcd_coeffs(sols{jj},n);

    for ii=1:n

        Q_i{jj}{ii} = sparse([a_s(ii), b_s(ii);...
                          c_s(ii), d_s(ii)]);

    end


end




end
