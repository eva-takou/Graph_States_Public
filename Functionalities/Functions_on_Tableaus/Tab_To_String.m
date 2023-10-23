function [destab_str,stab_str]=Tab_To_String(Tab)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to output the stabilizer and destabilizer of a tableau as Pauli
%strings.
%Input: Tab: The tableau
%Output: destab_str: the destabizer Pauli strings in cell array
%        stab_str  : the stabilizer Pauli strings in cell array

n          = (size(Tab,2)-1)/2;
stab_str   = cell(1,n);
destab_str = cell(1,n);

for ii=1:n %Destabs

    for jj=1:n

        if Tab(ii,jj)==0 && Tab(ii,jj+n)==0 

            this_destab(jj)='I';

        elseif Tab(ii,jj)==1 && Tab(ii,jj+n)==0 

            this_destab(jj)='X';

        elseif Tab(ii,jj)==1 && Tab(ii,jj+n)==1 

            this_destab(jj)='Y';

        elseif Tab(ii,jj)==0 && Tab(ii,jj+n)==1 

            this_destab(jj)='Z';

        end

        if Tab(ii,end)==0

            phase='+';

        elseif Tab(ii,end)==1

            phase='-';

        end

        destab_str{ii}=[phase,this_destab];

    end

end

for ii=1:n %Stabs

    for jj=1:n

        if Tab(ii+n,jj)==0 && Tab(ii+n,jj+n)==0 

            this_stab(jj)='I';

        elseif Tab(ii+n,jj)==1 && Tab(ii+n,jj+n)==0 

            this_stab(jj)='X';

        elseif Tab(ii+n,jj)==1 && Tab(ii+n,jj+n)==1 

            this_stab(jj)='Y';

        elseif Tab(ii+n,jj)==0 && Tab(ii+n,jj+n)==1 

            this_stab(jj)='Z';

        end

        if Tab(ii+n,end)==0

            phase='+';

        elseif Tab(ii+n,end)==1

            phase='-';

        end

        stab_str{ii}=[phase,this_stab];

    end

end


end
