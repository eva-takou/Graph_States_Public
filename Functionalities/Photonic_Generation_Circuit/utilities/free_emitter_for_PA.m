function [Tab,Circuit,graphs]=free_emitter_for_PA(Tab,Circuit,graphs,Store_Graphs,emitter,emitters)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Script to free-up an emitter for the photon absorption with emitter CNOT
%gates. The Pauli acting on the emitters should be a string of Zs.
%Input: Tab: Tableau
%       Circuit: The circuit that we have so far
%       graphs: The graphs that we have so far
%       Store_Graphs: true or false to keep the evolution of the graphs as
%       we run the circuit
%       emitter: the choice of emitter to absorb with index in [np+1,n]
%       emitters: the total emitters in the particular stabilizer row.
%Output: Tab: the updated tableau
%        Circuit: the updated circuit
%        graphs: the updated graphs


for jj=1:length(emitters) %Disentangle the emitter from the rest via CNOT.

   Tab        = Clifford_Gate(Tab,[emitters(jj),emitter],'CNOT');
   Circuit    = store_gate_oper([emitters(jj),emitter],'CNOT',Circuit); 

   if Store_Graphs

        graphs = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',num2str(emitters(jj)),',',num2str(emitter),'} [DE]'),graphs);

   end

end    



end