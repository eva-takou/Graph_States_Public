function [m,bool_obstruction]=second_pass_is_circle(m,gi,non_shift_nodes,Pseq)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------


Lg = length(gi);

for ii=Lg-1:-1:1
   
    A       = gi{ii};
    v       = non_shift_nodes{ii};
    m(m>=v) = m(m>=v)+1;
    p       = Pseq{ii};

    if ~isempty(p{1})
        
        
        for jj=1:length(p)

            q = p{jj};
            A = Local_Complement(A,q);

        end
    
    end
    
    Nv       = Get_Neighborhood(A,v); 
    degv     = length(Nv);
    
    if degv==1 
       
        v_in_m = ismember(v,m); 
        w_in_m = ismember(Nv,m);
        
        if ~v_in_m && ~w_in_m
        
            m=[m,v,Nv,v,Nv];
            
        elseif ~v_in_m && w_in_m
            
            locs   = find(m==Nv);
            prev_m = m(1:locs(2)-1);
            afte_m = m(locs(2)+1:end);
            m      = [prev_m,v,Nv,v,afte_m];
            
        elseif v_in_m && ~w_in_m

            warning('Should not have found v already in word?')
            locs   = find(m==v);
            prev_m = m(1:locs(2)-1);
            afte_m = m(locs(2)+1:end);
            m      = [prev_m,Nv,v,Nv,afte_m];
            
        else
            
            warning('Did nothing in inserting alternance, for degv=1, in 2nd pass.')
            
        end
        
    else %Try randomly, while respecting that alternances be compatible with entries of A matrix.
        
        [m,success_flag] = place_alternance_randomly(m,A,v,Nv);
        
        if ~success_flag %Should be fine to just exit, since we have probably encountered a circle graph obstruction.
            
            bool_obstruction=true;
            m=[];
            
            return
            
        else
            
            %disp('---Random placement of alternance worked.---')
                  
        end
        
    end
    
    m = transform_word_LC(m,p); %Re-apply the operation to transform the alternance word
    
    
end


bool_obstruction=false; %if we didnt return above, then we succeded.




end