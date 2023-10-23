function [emitter,emitter_flag_Gate] = check_for_single_emitter(Tab,n,np,Stabrow)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Check if there is an emitter that is decoupled from others (so that we avoid using emitter CNOTs.)
%Inputs: Tab: Tableau
%        n: total # of qubits (emitters+photons)
%        np: # of photons
%        Stabrow: stabilizer row to test if the weight of the emitter=1
%Output: emitter: the emitter qubit if it exists (otherwise it is empty)
%        emitter_flag_Gate: the Pauli on the emitter for the stabilizer row

emitter           =[];
emitter_flag_Gate =[];

Stabs    = Tab(n+1:2*n,1:2*n);
StabX_em = Stabs(Stabrow,np+1:n);
StabZ_em = Stabs(Stabrow,np+1+n:2*n);

emitters_in_X = find(  StabX_em  & ~ StabZ_em);
emitters_in_Y = find(  StabX_em  &   StabZ_em);
emitters_in_Z = find( ~StabX_em  &   StabZ_em);
    
if length(emitters_in_X)==1 && isempty(emitters_in_Y) && isempty(emitters_in_Z)

    emitter_flag_Gate = 'X';
    emitter           = emitters_in_X +np;
    
elseif length(emitters_in_Y)==1 && isempty(emitters_in_X) && isempty(emitters_in_Z)

    emitter_flag_Gate = 'Y';
    emitter           = emitters_in_Y +np;
    
elseif length(emitters_in_Z)==1 && isempty(emitters_in_X) && isempty(emitters_in_Y)

    emitter_flag_Gate = 'Z';
    emitter           = emitters_in_Z +np;
    
end
    
%Finally, even if the weight of emitters >1 in a particular row, it could 
%happen that the emitter is in product state. But, i dont think we can use
%an emitter in product state, because it wont be connected to the photon to
%be asborbed.

%---THIS IS UNDER TESTING.-------------------------------------------------

% ne=n-np;
% if isempty(emitter)
%     
%     for jj=np+1:np+ne
%         
%         [cond_product, state_flag]= qubit_in_product(Tab,n,jj); 
%         
%         if cond_product
%             [];
%             emitter=jj;
%             emitter_flag_Gate=state_flag;
%             return
%         end
%         
%     end
% end



% if isempty(emitter)
%     
%     ne = n-np;
%     for jj=1:ne
% 
%         Sx_em=Tab(n+1:2*n,np+jj);
%         Sz_em=Tab(n+1:2*n,np+jj+n);
% 
%         locs_X = find(Sx_em);
%         locs_Z = find(Sz_em);
% 
%         if ~isempty(locs_X) && isempty(locs_Z)
% 
%             emitter          = np+jj;
%             emitter_flag_Gate='X';
%             test_cond=true;
%             break
% 
%         elseif isempty(locs_X) && ~isempty(locs_Z)
% 
%             emitter          = np+jj;
%             emitter_flag_Gate='Z';
% 
%             test_cond=true;
%             break
% 
%         elseif length(locs_X)==length(locs_Z)
% 
% 
%             if all(locs_X==locs_Z)
% 
%                 emitter          = np+jj;
%                 emitter_flag_Gate='Y';
%                 test_cond=true;
%                 break
% 
%             end
% 
% 
%         end
% 
%     end
% 
% end


end
