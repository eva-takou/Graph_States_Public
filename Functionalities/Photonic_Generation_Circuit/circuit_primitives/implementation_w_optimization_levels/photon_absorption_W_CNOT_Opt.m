function [TabOut,CircuitOut,graphsOut,emitter_choices]=photon_absorption_W_CNOT_Opt(Tab,np,ne,photon,Circuit,graphs,Store_Graphs,try_LC,LC_Rounds)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Script where we test all the freedom in performing absorption of a photon,
%in the scenario where we need to apply emitter gates first.
%We first apply photon absorptions be freeing-up each emitter that can absorb the photon.
%Then, we inspect row operations and we repeat the same.
%Then, if requested we also try intermediate LC operations. 
%
%Very costly optimization, but the hope is that this is complete,
%and that we can figure out whether for the constrained LC problem we are
%studying, each graph in the LC class can be prepared with the same cost or
%not.
%
%Input: Tab: The tableau
%       np: # of photons
%       ne: # of emitters
%       photons: index of photon to be absorbed \in [1,np]
%       Circuit: The circuit we have so far
%       graphs: The graphs we have so far corresponding to each step of the
%       circuit
%       Store_Graphs: True or false (to store the graph evolution)
%       try_LC: true or false to attempt LCs before photon absorption
%       LC_Rounds: How many LC rounds to apply on distinct nodes (allowing
%       repetitions)
%Output: TabOut: All realizations of new Tableaus after photon absorption
%        CircuitOut: All new circuits
%        graphsOut: All new graphs
%        emitter_choices: a cell array of all emitter choices we made performed.

fixedTab     = Tab;
fixedCircuit = Circuit;
fixedGraphs  = graphs;

n = np+ne;

%-Get the rows where the Pauli starts from the photon to be absorbed.
%-Get also operators where we have support solely on emitters.

[row_ids_photon,photon_flag_Gate] = detect_Stabs_start_from_photon(fixedTab,photon,n);
row_ids_emitters                  = Stabs_with_support_on_emitters(fixedTab,np,ne);

%-Check all emitter choices w/o allowing row multiplications.--------------

cnt = 0;

for ll=1:length(row_ids_photon)
   
   newTab                                      = fixedTab;
   Circuit                                     = fixedCircuit;
   graphs                                      = fixedGraphs;
   
   [emitters_in_X,emitters_in_Y,emitters_in_Z] = emitters_Pauli_in_row(newTab,row_ids_photon(ll),np,ne);
   possible_emitters                           = [emitters_in_X,emitters_in_Y,emitters_in_Z];
    
    %-------- Bring all emitters in Z for the particular row: -------------
    
    [newTab,Circuit]=put_emitters_in_Z(newTab,Circuit,emitters_in_X,emitters_in_Y);
    
    %---------- Loop through all cases of choosing emitters ---------------
    
    for mm=1:length(possible_emitters)
        
        thisTab        = newTab;
        thisCirc       = Circuit;
        thesegraphs    = graphs;
        emitter        = possible_emitters(mm);
        other_emitters = setxor(possible_emitters,emitter);
        
        [thisTab,thisCirc,thesegraphs]=free_emitter_for_PA(thisTab,thisCirc,thesegraphs,Store_Graphs,emitter,other_emitters);
        
        photon_Gate = photon_flag_Gate{ll};
        emitter_flag_Gate='Z';
        
        [thisTab,thisCirc,thesegraphs]=PA_subroutine(thisTab,thisCirc,thesegraphs,photon,emitter,emitter_flag_Gate,photon_Gate,Store_Graphs);
        
        
        cnt                  = cnt+1;
        TabOut{cnt}          = thisTab;
        CircuitOut{cnt}      = thisCirc;
        graphsOut{cnt}       = thesegraphs;       
        emitter_choices{cnt} = emitter;    
        
    end
    
end

%--------------------------------------------------------------------------
%              Allow LC operations and repeat the same:  
%--------------------------------------------------------------------------
if try_LC
    
    [newTab,newCirc,newGraphs,new_emitter_choices]=LC_and_PA_subroutine(fixedTab,fixedCircuit,fixedGraphs,n,np,ne,photon,Store_Graphs,LC_Rounds);
    
    to_remove=[];
    for jj=1:length(newTab)
       
        for kk=jj+1:length(newTab)
           
            if all(all(newTab{jj}(n+1:2*n,1:2*n)==newTab{kk}(n+1:2*n,1:2*n)))
               
                to_remove=[to_remove,kk];
                break
                
            end
            
        end
        
    end
    newTab(to_remove)=[];
    newCirc(to_remove)=[];
    newGraphs(to_remove)=[];
    new_emitter_choices(to_remove)=[];
    
    TabOut          = [TabOut,newTab];
    CircuitOut      = [CircuitOut,newCirc];
    graphsOut       = [graphsOut,newGraphs];
    emitter_choices = [emitter_choices,new_emitter_choices];
    
end

%--------------------------------------------------------------------------
%           Allow row multiplications and repeat the same.
%--------------------------------------------------------------------------

% if isempty(row_ids_emitters)
%     return
% end
% 
% cnt=length(TabOut);

% for j1=1:length(row_ids_photon)
%     
%     row1=row_ids_photon(j1);
%     
%     for j2=1:length(row_ids_emitters)
%         
%         row2=row_ids_emitters(j2);
%             
%         newTab  = fixedTab;
%         Circuit = fixedCircuit;
%         graphs  = fixedGraphs;
%         
%         newTab  = update_Tab_rowsum(newTab,n,row1,row2);
%         
%         [new_rows,photon_flag_Gate] = detect_Stabs_start_from_photon(newTab,photon,n);
%         
%         
%         for ll=1:length(new_rows)
%             
%             [emitters_in_X,emitters_in_Y,emitters_in_Z] = emitters_Pauli_in_row(newTab,new_rows(ll),np,ne);
%             possible_emitters                           = [emitters_in_X,emitters_in_Y,emitters_in_Z];
%             [newTab,Circuit]=put_emitters_in_Z(newTab,Circuit,emitters_in_X,emitters_in_Y);
%  
%             for mm=1:length(possible_emitters)
% 
%                 thisTab        = newTab;
%                 thisCirc       = Circuit;
%                 thesegraphs    = graphs;
%                 emitter        = possible_emitters(mm);
%                 other_emitters = setxor(possible_emitters,emitter);
% 
%                 [thisTab,thisCirc,thesegraphs]=free_emitter_for_PA(thisTab,thisCirc,thesegraphs,Store_Graphs,emitter,other_emitters);                    
% 
%                 %------ Bring the photon into Z -----------------------------------
% 
%                 photon_Gate = photon_flag_Gate{ll};
%                 emitter_flag_Gate='Z';
% 
%                 [thisTab,thisCirc,thesegraphs]=PA_subroutine(thisTab,thisCirc,thesegraphs,photon,emitter,emitter_flag_Gate,photon_Gate,Store_Graphs);
% 
%                 cnt                  = cnt+1;
%                 TabOut{cnt}          = thisTab;
%                 CircuitOut{cnt}      = thisCirc;
%                 graphsOut{cnt}       = thesegraphs;       
%                 emitter_choices{cnt} = emitter;
%                 
%             end
%             
%         end
%         
%     end
%     
%     
% end

%TEST THIS:
%Even multiplying the photonic stabilizers together matters and can reduce
%the CNOT count. So in general, inspecting only Sem*Sph is not enough.
%Really not sure why this is the case.
%Let's say we have Sem=IXII
%Let's say we have Sph=XXZI
%                  Sph*Sem = XIZI
%But if we have Sph1*Sph2 = (IIXIIIXXX)(IIZZIIXXZ)=IIYZIIIIZ -> YZ no CNOT
%                                                                  needed(?)



%all_rows = [row_ids_photon,row_ids_emitters]; %Stabilizer rows.

all_rows = [row_ids_photon]; %Stabilizer rows.

%Multiplication including emitter rows seems to not matter in most cases.
%In some cases it matters.

if length(all_rows)==1
    return
end

for j1=1:length(all_rows)
    
    row1 = all_rows(j1);
    
    for j2=1:length(all_rows)
        
        if j1~=j2 
            
            row2    = all_rows(j2);
            newTab  = fixedTab;
            Circuit = fixedCircuit;
            graphs  = fixedGraphs;
            
            newTab  = update_Tab_rowsum(newTab,n,row1,row2);
            
            %Now, find again the photon state, the emitters state, and loop over all choices.
            [row_ids_photon,photon_flag_Gate] = detect_Stabs_start_from_photon(newTab,photon,n);
            
            for ll=1:length(row_ids_photon)
           
                [emitters_in_X,emitters_in_Y,emitters_in_Z] = emitters_Pauli_in_row(newTab,row_ids_photon(ll),np,ne);
                possible_emitters                           = [emitters_in_X,emitters_in_Y,emitters_in_Z];

                %---Put emitters in Z.------------------------------------
                [newTab,Circuit]=put_emitters_in_Z(newTab,Circuit,emitters_in_X,emitters_in_Y);
                
                
                for mm=1:length(possible_emitters)

                    thisTab        = newTab;
                    thisCirc       = Circuit;
                    thesegraphs    = graphs;
                    emitter        = possible_emitters(mm);
                    other_emitters = setxor(possible_emitters,emitter);
                   
                    [thisTab,thisCirc,thesegraphs]=free_emitter_for_PA(thisTab,thisCirc,thesegraphs,Store_Graphs,emitter,other_emitters);                    
 
                    %------ Bring the photon into Z -----------------------------------

                    photon_Gate = photon_flag_Gate{ll};

                    emitter_flag_Gate='Z';
                    
                    [thisTab,thisCirc,thesegraphs]=PA_subroutine(thisTab,thisCirc,thesegraphs,photon,emitter,emitter_flag_Gate,photon_Gate,Store_Graphs);

                    cnt                  = cnt+1;
                    TabOut{cnt}          = thisTab;
                    CircuitOut{cnt}      = thisCirc;
                    graphsOut{cnt}       = thesegraphs;       
                    emitter_choices{cnt} = emitter;
                    
                end
                
            end
            
        end
        
    end
    
end


%--- Consider checking for Tableaus that are exactly the same -------------
%    and drop them to speed up the computation. Not sure yet if this
%    is valid to do, or if we will miss out some optimal cases in this way.




end



