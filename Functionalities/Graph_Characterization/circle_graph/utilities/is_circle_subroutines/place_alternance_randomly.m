function [mnew,success_flag] = place_alternance_randomly(m,A,v,Nv)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Check: Should we respect all alternances, or does it suffice to respect
%that the N(vi+1) is the same as the alternances involved in the new graph?
%--- This is not clear in Bouchet's algorithm. ---------------------------

mfixed      = m;
random_locs = nchoosek(1 : (length(m)+2) ,2);
other_nodes = setxor(1:length(A),[Nv',v]);
degv        = length(Nv);

for jj = 1:size(random_locs,1)

    mnew = m;
    locs = random_locs(jj,:);
    mnew = insert_occurences_v(mnew,v,locs);

    exists_wrong_alternance = false;
    flag_found_alternance   = false(1,degv);

    %First: Make sure that we respect the connections in A.

    for k=1:length(other_nodes)

        u = other_nodes(k);
        

        if exists_v1v2_alternance(u,v,mnew) && A(u,v)==0

            exists_wrong_alternance(k)=true; 

        end

    end             

    %Second: Check if we created an alternance wv for each w\in Nv 
    for k=1:degv

        if exists_v1v2_alternance(Nv(k),v,mnew)

            flag_found_alternance(k)=true; 
            
        else
            
            break
        end

    end

    if all(flag_found_alternance) 
        
        if ~any(exists_wrong_alternance)
        
            
            success_flag = true;
        
       
            return 
            
        end
        
    end


end

success_flag = false;
mnew         = mfixed; %do not change the word if we failed.

end
