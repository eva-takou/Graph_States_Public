function [Tab,Circuit,graphs]=time_reversed_measurement(Tab,np,ne,photon,Circuit,graphs,Store_Graphs)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to perform time reversed measurement of the emitter, when photon
%absorption is not possible.
%Inputs: Tab: Tableau
%        np: # of photons
%        ne: # of emitters
%        photon: photon index of photon to be absorbed.
%        Circuit: the circuit that we have so far
%        graphs: the graphs for each step of the generation
%        Store_Graphs: true or false to store the updates on the graph
%        level.
%Output: Tab: The updated tableau
%        Circuit: The updated circuit
%        graphs: The updated graphs
%
%1) Find emitter in |0> state (with stab that has support only on the emitter sites).
%2) Bring it into |+> state.
%3) Do CNOT_{ij} between the emitter and the current photon.
%
%The TRM measurement, will connect an emitter with the neighborhood of the
%photon to be absorbed. 
%
%Methods from Ref: Bikun Li et al, npj Quantum Information 8, 11, (2022)

n = np+ne;

for emitter_qubit=np+1:n
    
    [discovered, state_flag] = qubit_in_product(Tab,n,emitter_qubit);
    
    if discovered %true, and can be just any emitter qubit (no freedom in TRM)
        
       switch state_flag
           
           case 'Y'
               
               Tab     = Clifford_Gate(Tab,emitter_qubit,'P');  %Convert to eigenstate of X (up to phase)
               Circuit = store_gate_oper(emitter_qubit,'P',Circuit); 
               
           case 'Z'
               
               Tab     = Clifford_Gate(Tab,emitter_qubit,'H'); %Convert to eigenstate of X
               Circuit = store_gate_oper(emitter_qubit,'H',Circuit); 
       end
       
       Tab     = Clifford_Gate(Tab,[emitter_qubit,photon],'CNOT'); %This TRM will connect the emitter with N(photon).
       Circuit = store_gate_oper([emitter_qubit,photon],'Meas',Circuit); 
       
       if Store_Graphs
           
            graphs  = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',num2str(emitter_qubit),',',num2str(photon),'} [TRM]'),graphs);
            
       end
       
       disp(['Applied TRM on emitter:',num2str(emitter_qubit)])
       
       return
       
    end
    
end

%If function didn't return above then we need CNOT emitter gates.

disp('Need emitter gates before TRM.') 
[emitter_qubit,other_emitters,Tab,Circuit]=minimize_emitter_length(Tab,Circuit,n,np,ne);


for jj=1:length(other_emitters) %disentangle emitters
    
   control = other_emitters(jj);
   Tab     = Clifford_Gate(Tab,[control,emitter_qubit],'CNOT');
   
   Circuit = store_gate_oper([control,emitter_qubit],'CNOT',Circuit); 
   
   if Store_Graphs
        graphs  = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',num2str(control),',',num2str(emitter_qubit),'} [DE]'),graphs);
   end
end
%Put the emitter in |+>
Tab           = Clifford_Gate(Tab,emitter_qubit,'H');
Circuit       = store_gate_oper(emitter_qubit,'H',Circuit); 
%Now do the TRM
Tab           = Clifford_Gate(Tab,[emitter_qubit,photon],'CNOT');
Circuit       = store_gate_oper([emitter_qubit,photon],'Meas',Circuit); 

if Store_Graphs
    graphs  = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',num2str(emitter_qubit),',',num2str(photon),'} [TRM]'),graphs);
end

disp(['Applied TRM on emitter:',num2str(emitter_qubit)])
end


