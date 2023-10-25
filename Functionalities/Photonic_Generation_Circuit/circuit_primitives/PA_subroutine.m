function [Tab,Circuit,graphs]=PA_subroutine(Tab,Circuit,graphs,photon,emitter,emitter_flag_Gate,photon_flag_Gate,Store_Graphs)
%--------------------------------------------------------------------------    
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%Class to simulate photonic graph state generation.
%--------------------------------------------------------------------------
%Subroutine to do photon absorption.
%Input:  Tab: Tableau
%        Circuit: The circuit so far
%        graphs: The graphs so far
%        photon: The photon index \in [1,np]
%        emitter: The emitter index in [np+1,n]
%        emitter_flag_Gate: 'X','Y' or 'Z'
%        photon_flag_Gate: 'X', 'Y' or 'Z'
%        Store_Graphs: true or false
%Output: Tab: the updated tableau
%        Circuit: the updated circuit
%        graphs: the updated graphs

switch emitter_flag_Gate %bring the emitter to Z

  case 'X'

        Tab     = Clifford_Gate(Tab,emitter,'H');
        Circuit = store_gate_oper(emitter,'H',Circuit);   

  case 'Y'

        Tab     = Clifford_Gate(Tab,emitter,'P');
        Tab     = Clifford_Gate(Tab,emitter,'H');
        Circuit = store_gate_oper(emitter,'P',Circuit);   
        Circuit = store_gate_oper(emitter,'H',Circuit);   
   
end

switch photon_flag_Gate

  case 'X'

      Tab     = Clifford_Gate(Tab,photon,'H');
      Circuit = store_gate_oper(photon,'H',Circuit);  

  case 'Y'

      Tab     = Clifford_Gate(Tab,photon,'P');
      Tab     = Clifford_Gate(Tab,photon,'H');
      Circuit = store_gate_oper(photon,'P',Circuit);   
      Circuit = store_gate_oper(photon,'H',Circuit);   

end


disp(['Photon #',num2str(photon),' is absorbed by emitter #',num2str(emitter)])
Tab     = Clifford_Gate(Tab,[emitter,photon],'CNOT'); %photon and emitter in Z
Circuit = store_gate_oper([emitter,photon],'CNOT',Circuit); 


if Store_Graphs
    graphs  = store_graph_transform(Get_Adjacency(Tab),strcat('After CNOT_{',num2str(emitter),',',num2str(photon),'} [PA]'),graphs);
end

disp(['Single Emitter #',num2str(emitter), ' was found to absorb photon #',num2str(photon),' w/o emitter gates.']) 


end
