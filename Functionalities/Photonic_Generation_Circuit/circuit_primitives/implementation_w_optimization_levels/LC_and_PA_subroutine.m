function [TabOut,CircuitOut,graphsOut,emitter_choices]=LC_and_PA_subroutine(Tab,Circuit,graphs,n,np,ne,photon,Store_Graphs,LC_Rounds)
%
%%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Script to do apply intermediate LCs right before perfoming photon
%absorption in the case when we need emitter gates.
%
%Input: Tab: The tableau
%       Circuit: The circuit we have so far
%       graphs: The graphs we have so far
%       n: total # of qubits
%       ne: # of emitters indices \in[np+1,n]
%       np: # of photons
%       photon: index of photon to be absorbed
%       Store_Graphs: true or false to store the progress in graph
%       evolution
%       LC_Rounds: how many rounds of local complementations to apply
%
%Output: TabOut: All the Tableaus we created
%        CircuitOut: All the circuits corresponding to updated tableaus
%        graphsOut: All the graphs corresponding to updates performed so
%        far on each tableau
%        emitter_choices: a cell array which stores which emitter we picked
%        in each realization.
%
%--------------------------------------------------------------------------


%---- Exclude the qubits that are in product state ------------------------

LC_qubits=[];

for jj=1:n
   
    [cond_prod,~]=qubit_in_product(Tab,n,jj);

    if ~cond_prod
        
        LC_qubits=[LC_qubits,jj];
        
    end
    
end

Adj0 = Get_Adjacency(Tab);
    
%----------- Apply the LCs and perform again the photon absorptions -------

TabOut          = {};
CircuitOut      = {};
graphsOut       = {};
emitter_choices = {};

for jj=1:LC_Rounds
    
    LC_sequences=Get_LC_Sequences(LC_qubits,jj);
    
    for Q = 1:size(LC_sequences,1)  %Each LC sequence
        
        this_LC    = LC_sequences(Q,:);
        
        [newTabs,newCirc,newGraphs,new_emitter_choices]=apply_subroutine_of_LC(n,ne,np,photon,Tab,Adj0,Circuit,graphs,this_LC,Store_Graphs);
        
        TabOut          = [TabOut,newTabs];
        CircuitOut      = [CircuitOut,newCirc];
        graphsOut       = [graphsOut,newGraphs];
        emitter_choices = [emitter_choices,new_emitter_choices];
        
    end
    
end

end


function [TabOut,CircuitOut,graphsOut,emitter_choices]=apply_subroutine_of_LC(n,ne,np,photon,Tab,Adj0,Circuit,graphs,LC_sequence,Store_Graphs)
%Apply the local complementation given a particular LC sequence.
%If we choose a node v, then the LC up to some phase is doing H*P*H on node
%v, and P (more accurately P^dagger) on N(v).

AdjTemp    = Adj0;

for k=1:length(LC_sequence)
    
    v       = LC_sequence(k);
    Nv      = Get_Neighborhood(AdjTemp,v);
    
    if length(Nv)>1

        Tab = Clifford_Gate(Tab,v,'H');
        Tab = Clifford_Gate(Tab,v,'P');
        Tab = Clifford_Gate(Tab,v,'H');

        Circuit = store_gate_oper(v,'H',Circuit);  
        Circuit = store_gate_oper(v,'P',Circuit);  
        Circuit = store_gate_oper(v,'H',Circuit);  

        for l=1:length(Nv)

            Tab     = Clifford_Gate(Tab,Nv(l),'P'); 
            Circuit = store_gate_oper(Nv(l),'P',Circuit);

        end

    else

        continue %To next iter, we do not need to apply any operation 

    end
    
    %Update the Adjacency matrix:
    AdjTemp = Local_Complement(AdjTemp,v);
    %Here we could also use: AdjTemp=Get_Adjacency(Tab);
    
end

%Save the graph after the whole LC sequence

if Store_Graphs
    graphs  = store_graph_transform(AdjTemp,strcat('After LC_{',num2str(LC_sequence),'} [Before PA]'),graphs);
end            


[potential_rows,photon_flag_Gate,~] = detect_Stabs_start_from_photon(Tab,photon,n);

fixedTab    = Tab;
fixedCirc   = Circuit;
fixedGraphs = graphs;

cnt=0;

for p=1:length(potential_rows)

    Tab     = fixedTab;
    Circuit = fixedCirc;
    graphs  = fixedGraphs;

    [emitters_in_X,emitters_in_Y,emitters_in_Z] = emitters_Pauli_in_row(Tab,potential_rows(p),np,ne);
    possible_emitters                           = [emitters_in_X,emitters_in_Y,emitters_in_Z];
    %-------- Bring all emitters in Z for the particular row: -------------
    [Tab,Circuit]=put_emitters_in_Z(Tab,Circuit,emitters_in_X,emitters_in_Y);

    for mm=1:length(possible_emitters)

        thisTab     = Tab;
        thisCirc    = Circuit;
        thesegraphs = graphs;

        emitter        = possible_emitters(mm);
        other_emitters = setxor(possible_emitters,emitter);
        [thisTab,thisCirc,thesegraphs]=free_emitter_for_PA(thisTab,thisCirc,thesegraphs,Store_Graphs,emitter,other_emitters);

        photon_Gate = photon_flag_Gate{p};
        emitter_flag_Gate = 'Z';

        [thisTab,thisCirc,thesegraphs]=PA_subroutine(thisTab,thisCirc,thesegraphs,photon,emitter,emitter_flag_Gate,photon_Gate,Store_Graphs);

        cnt=cnt+1;

        TabOut{cnt}=thisTab;
        CircuitOut{cnt}=thisCirc;
        graphsOut{cnt}=thesegraphs;
        emitter_choices{cnt}=emitter;

    end


end





end



function LC_sequences=Get_LC_Sequences(LC_nodes,LC_Round)
%Helper function to create the LC sequences we want to inspect.
%Since G*v*v = G (local complementation is its own inverse) then we want
%consecutive node indices to differ.

LC_sequences=[];

if LC_Round==1
    
        LC_sequences=LC_nodes;
        
        %Need it to be LC_nodes x 1
        
        if size(LC_sequences,2)~=1
           
            LC_sequences=LC_sequences';
            
        end
    
elseif LC_Round==2
    
        for k1=1:length(LC_nodes)
           
            for k2=1:length(LC_nodes)
               
                if k2~=k1
                   
                    LC_sequences=[LC_sequences;[LC_nodes(k1),LC_nodes(k2)]];
                    
                end
                
            end
            
        end
    
elseif LC_Round==3
    
        for k1=1:length(LC_nodes)
           
            for k2=1:length(LC_nodes)
                
                for k3=1:length(LC_nodes)
               
                    if k2~=k1 && k3~=k2
                   
                        LC_sequences=[LC_sequences;[LC_nodes(k1),LC_nodes(k2),LC_nodes(k3)]];
                        
                    end
                
                end
                
            end
            
        end        
        
elseif LC_Round==4
    
    
        for k1=1:length(LC_nodes)
           
            for k2=1:length(LC_nodes)
                
                for k3=1:length(LC_nodes)
                    
                    for k4=1:length(LC_nodes)
               
                        if k2~=k1 && k3~=k2 && k4~=k3

                            LC_sequences=[LC_sequences;[LC_nodes(k1),LC_nodes(k2),LC_nodes(k3),LC_nodes(k4)]];

                        end
                    
                    end
                
                end
                
            end
            
        end       
    
    
end

end