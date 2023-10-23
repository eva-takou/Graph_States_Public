function [Tab,Circuit,graphs,discovered_emitter,emitter]=photon_absorption_WO_CNOT(Tab,np,ne,photon,Circuit,graphs,Store_Graphs)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to try to perform photon absorption. If there is no available
%emitter then we exit with the same tableau, circuit and graphs, and output
%that an emitter was not discovered.
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
%
%Methods from Ref: Bikun Li et al, npj Quantum Information 8, 11, (2022)

n                  = np+ne;
discovered_emitter = false;
emitter            = [];

%Get stabs whose left index starts from a Pauli on the photon to be absorbed
[potential_rows,photon_flag_Gate,Tab] = detect_Stabs_start_from_photon(Tab,photon,n);
row_ids_emitters                      = Stabs_with_support_on_emitters(Tab,np,ne);

%=== Search for emitter not entangled with others to absorb the photon ====

for jj=1:length(potential_rows) %Check for emitter not entangled with others to absorb the photon:
    
    [emitter,emitter_flag_Gate] = check_for_single_emitter(Tab,n,np,potential_rows(jj));
    
    if ~isempty(emitter)
        
        discovered_emitter = true;
        photon_flag_Gate   = photon_flag_Gate{jj};
        
        break
        
    end
    
end


if ~discovered_emitter && length(potential_rows)>1

    testTab=update_Tab_rowsum(Tab,n,potential_rows(1),potential_rows(2));
    [new_rows,photon_flag_Gate,testTab] = detect_Stabs_start_from_photon(testTab,photon,n);
    
    for jj=1:length(new_rows)
       
        [emitter,emitter_flag_Gate] = check_for_single_emitter(testTab,n,np,new_rows(jj));

        if ~isempty(emitter)

            discovered_emitter = true;
            photon_flag_Gate   = photon_flag_Gate{jj};
            Tab                = testTab;
            break

        end        
        
    end
    
    
end

%If we didnt find the emitter and there is no other operator with support
%completely on the emitters, we cannot redefine the stabilizers.
if ~discovered_emitter && isempty(row_ids_emitters)
    
    return
    
end


%=== Check if multiplying the rows for which L(Sa)=photon index with rows
%that have complete support on the emitter gives a new operator with weight
%1 on photon and weight 1 on emitter in one stabilizer row.
%Note that in principle we could do more multiplications (e.g. first
%multiply 2 emitter stabilizers and then multiply them on the photon
%stabilizers and so on).

if ~discovered_emitter && ~isempty(row_ids_emitters)
    
    for p=1:length(potential_rows)
       
        row1=potential_rows(p);
        
        for kk=1:length(row_ids_emitters)
            
            row2=row_ids_emitters(kk);
            
            testTab=update_Tab_rowsum(Tab,n,row1,row2);
            
            [new_rows,photon_flag_Gate,testTab] = detect_Stabs_start_from_photon(testTab,photon,n);
            
            for jj=1:length(new_rows) %Check again if we can find an emitter here:
                
                [emitter,emitter_flag_Gate] = check_for_single_emitter(testTab,n,np,new_rows(jj));
                
                if ~isempty(emitter)

                    discovered_emitter = true;
                    photon_flag_Gate   = photon_flag_Gate{jj};
                    
                    
                    warning('In photon absorption w/o CNOT, multiplication of stabilizers gives PA for free.')
                    disp(['photon #',num2str(photon)])
                    break

                end                
                
            end
            
            if discovered_emitter

                Tab = testTab;
                break
            end            
            
        end
        
        if discovered_emitter
            
            break
            
        end

    end
    
end



%If we still didnt discovered an emitter, then we cannot absorb the photon.

if ~discovered_emitter
   
    return 
    
end

disp(['Single Emitter #',num2str(emitter), ' was found to absorb photon #',num2str(photon),' w/o emitter gates.']) 

[Tab,Circuit,graphs]=PA_subroutine(Tab,Circuit,graphs,photon,emitter,emitter_flag_Gate,photon_flag_Gate,Store_Graphs);

end
