function out=create_encoded_RGS(core_qubits,branching_parameter,formatOption)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Script to generate encoded RGS based on
%https://journals.aps.org/prx/pdf/10.1103/PhysRevX.7.041023.
%The core is fully connected, and the encoding happens on the arms of the 
%regular RGS. The branching parameter specifies how many leaves we attach
%to each arm.
%
%To each core qubit attach a number of leaves per branching parameter.
%The branching parameter should be a vector. e.g. [2,2]
%will attach 2 nodes per core qubit and then each of these
%will again be connected to another 2 leaves.

%Input: core_qubits: # of central qubits of RGS.
%       branching_parameter: # of leaves to attach per core qubit.
%       formatOption: 'EdgeList' or 'Adjacency'.
%Output: The edgelist or adjacency of the encoded RGS.



%============ Fully connected core: =======================================

EdgeList = {};

for node = 1:core_qubits
   
    for node_other = node+1:core_qubits
        
        EdgeList = [EdgeList,[node,node_other]];
        
    end
    
end

%=== Start attaching leaves per core qubit: ==============================

previous_qubits = core_qubits;


%==== Find the number of qubits per layer, and their labeling: ==========
node_labels_per_layer = cell(1,length(branching_parameter));
nodes_per_layer       = zeros(1,length(branching_parameter));

for jj=1:length(branching_parameter)
    
    nodes_per_layer(jj)         = previous_qubits*branching_parameter(jj);
    
    if jj==1
        node_labels_per_layer{jj} = previous_qubits+1:previous_qubits+nodes_per_layer(jj);
    else
        node_labels_per_layer{jj} = node_labels_per_layer{jj-1}(end)+1:node_labels_per_layer{jj-1}(end)+nodes_per_layer(jj);
    end
    
    previous_qubits = length(node_labels_per_layer{jj});
    
end

%=== Now create the connections between the various layers: ===============
%--- Leafs corresponding to same inner qubits get subsequent labeling.-----


for k=1:core_qubits
   
    shift = branching_parameter(1);
    
    for ll=1:branching_parameter(1)
       
        EdgeList = [EdgeList,[k,node_labels_per_layer{1}(ll)+(k-1)*shift]];
        
    end
    
    
end

for ll=1:length(node_labels_per_layer)-1
    
    this_layer = node_labels_per_layer{ll+1};
    
    old_qubits = node_labels_per_layer{ll};
    
    shift = branching_parameter(ll+1);
    
    for p=1:length(old_qubits)
        
        for k=1:branching_parameter(ll+1)

            EdgeList = [EdgeList,[old_qubits(p),this_layer(k)+(p-1)*shift]];

        end        
        
    end
    
    
    
end



n=max([EdgeList{:}]);


switch formatOption
    
    case 'EdgeList'
        
        out = EdgeList;
        
        
    case 'Adjacency'


        out = edgelist_to_Adj(EdgeList,n);
        
        
        
end




end