function [TabOUT,CircOUT,graphsOUT,discovered_emitter,emitterOUT]=photon_absorption_WO_CNOT_Opt...
                                                                  (Tab,np,ne,photon,Circuit,graphs,Store_Graphs)
%%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to try to perform photon absorption. If there is no available
%emitter then we exit with the same tableau, circuit and graphs, and output
%that an emitter was not discovered. If we could do photon absorption, then
%we allow all emitter choices, and also inspect the row multiplications.
%
%Inputs: Tab: Tableau
%        np: # of photons
%        ne: # of emitters
%        photon: # index of photon to be absorbed
%        Circuit: the circuit we have so far
%        graphs: the graph evolution as we evolve the circuit.
%Output: Tab: The updated tableau
%        Circuit: The updated circuit
%        graphs: The updated graphs
%        discovered emitter: true or false if the photon absorption
%        happened
%        emitter: if above is true, it gives the index from np+1:n of the
%        emitter, if above is false then emitter is empty.
%
%To do the photon absorption we search for a stabilizer which starts with
%L(Sa)=index of photon to be absorbed. If for this kind of stabilizer there
%is only 1 non-trivial pauli on emitter sites, then the photon can be
%asborbed. Otherwise we need emitter gates. This script tries to do photon
%absorption w/o needing CNOT gates between emitters.

%----Default options of optimization---------------------------------------

allow_Row_Mult = true;
%--------------------------------------------------------------------------

fixedTab    = Tab;
fixedCirc   = Circuit;
fixedgraphs = graphs;

n                  = np+ne;
discovered_emitter = false;

%Get stabs whose left index starts from a Pauli on the photon to be absorbed
[potential_rows,photon_flag_Gate,~]   = detect_Stabs_start_from_photon(fixedTab,photon,n);
row_ids_emitters                      = Stabs_with_support_on_emitters(fixedTab,np,ne);

%=== Search for every emitter that can absorb the photon ==================

cnt=0;

for jj=1:length(potential_rows) 
    
    [emitter,emitter_flag_Gate] = check_for_single_emitter(fixedTab,n,np,potential_rows(jj));
    
    if ~isempty(emitter)
        
        discovered_emitter = true;
        
        %Perform PA using any of the available emitters.
        cnt=cnt+1;
        
        [Tab,Circuit,graphs]=PA_subroutine(fixedTab,fixedCirc,fixedgraphs,photon,emitter,emitter_flag_Gate,photon_flag_Gate{jj},Store_Graphs);
        
        TabOUT{cnt}     = Tab;
        CircOUT{cnt}    = Circuit;
        graphsOUT{cnt}  = graphs;
        emitterOUT(cnt) = emitter;
        %return
    end
    
end


%Check if multiplying the rows for which L(Sa)=photon index with rows that
%have solely support on emitters leads to a new emitter choice.

if ~discovered_emitter && ~isempty(row_ids_emitters) && allow_Row_Mult
    
    for p=1:length(potential_rows)
       
        row1=potential_rows(p);
        
        for kk=1:length(row_ids_emitters)
            
            row2=row_ids_emitters(kk);
            
            testTab=update_Tab_rowsum(fixedTab,n,row1,row2);
            
            [new_rows,new_photon_flag_Gate,testTab] = detect_Stabs_start_from_photon(testTab,photon,n);
            
            for jj=1:length(new_rows) %Check again if we can find an emitter here:
                
                [emitter,emitter_flag_Gate] = check_for_single_emitter(testTab,n,np,new_rows(jj));
                
                if ~isempty(emitter)

                    discovered_emitter = true;

                    warning('In photon absorption w/o CNOT, multiplication of stabilizers gives PA for free.')
                    
                    disp(['Single Emitter #',num2str(emitter), ' was found to absorb photon #',num2str(photon),' w/o emitter gates.']) 

                    [Tab,Circuit,graphs]=PA_subroutine(testTab,fixedCirc,fixedgraphs,photon,emitter,emitter_flag_Gate,new_photon_flag_Gate{jj},Store_Graphs);

                    cnt=cnt+1;
                    
                    TabOUT{cnt}=Tab;
                    CircOUT{cnt}=Circuit;
                    graphsOUT{cnt}=graphs;
                    emitterOUT(cnt)=emitter;
                    %return
                end                
                
            end
            
        end
       
    end
    
end

%Check if multiplying the 2 stabs for which L(Sa)=photon index gives an
%operator such that we can allow photon absorption:
%Example: (IIXIIIXXX)(IIZZIIXXZ)=IIYZIIIIZ (4th photon decoupled) absorb
%photon 3 by last emitter.

if ~discovered_emitter && length(potential_rows)>1 && allow_Row_Mult
    
    for p=1:length(potential_rows)
       
        row1=potential_rows(p);
        
        for kk=p+1:length(potential_rows)
            
            row2=potential_rows(kk);
            
            testTab=update_Tab_rowsum(fixedTab,n,row1,row2);
            
            [new_rows,new_photon_flag_Gate,testTab] = detect_Stabs_start_from_photon(testTab,photon,n);
            
            for jj=1:length(new_rows) %Check again if we can find an emitter here:
                
                [emitter,emitter_flag_Gate] = check_for_single_emitter(testTab,n,np,new_rows(jj));
                
                if ~isempty(emitter)

                    discovered_emitter = true;

                    disp(['Single Emitter #',num2str(emitter), ' was found to absorb photon #',num2str(photon),' w/o emitter gates.']) 

                    [Tab,Circuit,graphs]=PA_subroutine(testTab,fixedCirc,fixedgraphs,photon,emitter,emitter_flag_Gate,new_photon_flag_Gate{jj},Store_Graphs);

                    cnt=cnt+1;
                    
                    TabOUT{cnt}=Tab;
                    CircOUT{cnt}=Circuit;
                    graphsOUT{cnt}=graphs;
                    emitterOUT(cnt)=emitter;
                   
                    %return
                    
                end                
                
            end
             
        end
       
    end
    
end


if ~discovered_emitter
   
    emitterOUT=[];
    TabOUT=fixedTab;
    CircOUT=fixedCirc;
    graphsOUT=fixedgraphs;
    return 
    
end




end

