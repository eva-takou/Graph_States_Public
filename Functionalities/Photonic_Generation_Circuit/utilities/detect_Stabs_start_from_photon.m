function [potential_rows,photon_flag_Gate,Tab]=detect_Stabs_start_from_photon(Tab,photon,n)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Detect a stab whose Left index starts from the photon to be absorbed.
%Input: Tab: Tableau
%       photon: the photon that we intend to absorb
%       n: total # of qubits (photons+emitters)
%Output: potential rows: an array all the stabilizer rows where the left index starts from a Pauli
%        on the photon.
%        photon_flag_Gate: a cell of the Pauli that acts on the photon in
%        each case
%        Tab: The input tableau is returned back (nothing changes)

Stabs = Tab(n+1:2*n,1:2*n);
cnt   = 0;

if photon>1

    for ii=n:-1:1

        SX_other_photons = Stabs(ii,1:photon-1);
        SZ_other_photons = Stabs(ii,n+1:n+(photon-1));

        xi_target_photon = Stabs(ii,photon);
        zi_target_photon = Stabs(ii,photon+n);

        if all(SX_other_photons==0) && all(SZ_other_photons==0) %trivial Paulis on other photons

            if xi_target_photon==0 && zi_target_photon==1 %Conditions for non-trivial Paulis on target photon.

                cnt = cnt+1;
                photon_flag_Gate{cnt} = 'Z';
                potential_rows(cnt)   = ii;

            elseif xi_target_photon==1 && zi_target_photon==1

                cnt = cnt+1;
                photon_flag_Gate{cnt} = 'Y';
                potential_rows(cnt)   = ii;

            elseif xi_target_photon==1 && zi_target_photon==0    

                cnt = cnt+1;
                photon_flag_Gate{cnt} = 'X';
                potential_rows(cnt)   = ii;

            end

        end

    end
    
elseif photon==1
    
    for ii=n:-1:1

        xi_target_photon = Stabs(ii,photon);
        zi_target_photon = Stabs(ii,photon+n);

        if xi_target_photon==0 && zi_target_photon==1 %Conditions for non-trivial Paulis on target photon.

            cnt = cnt+1;
            photon_flag_Gate{cnt} = 'Z';
            potential_rows(cnt)   = ii;

        elseif xi_target_photon==1 && zi_target_photon==1

            cnt = cnt+1;
            photon_flag_Gate{cnt} = 'Y';
            potential_rows(cnt)   = ii;

        elseif xi_target_photon==1 && zi_target_photon==0    

            cnt = cnt+1;
            photon_flag_Gate{cnt} = 'X';
            potential_rows(cnt)   = ii;

        end

    end
    
end

if cnt==0
    
    error('Did not find Stab whose 1st Pauli starts from photon to be absorbed.')
    
end



end
