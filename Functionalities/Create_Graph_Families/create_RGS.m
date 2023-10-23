function out=create_RGS(core_qubits,ordering,max_leafs,formatOption) %,leafs
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Create a repeater graph state. 
%Input: core qubits: fully connected inner qubits
%       leafs: # of leaf qubits per core qubit
%       ordering: ordering of nodes i.e., how to name them assuming we
%       start from core-qubits and traverse them clock-wise and then we
%       traverse the leafs again clock-wise.

%The RGS is created by first creating clock-wise the inner core, and then
%labeling clock-wise the leafs. 



%Make fully connected core first:

EdgeList = {};

for node = 1:core_qubits
   
    for node_other = node+1:core_qubits
        
        
        EdgeList = [EdgeList,[node,node_other]];
        
    end
    
end

%To each core qubit attach a single leaf:

leaf=core_qubits;

for node = 1:max_leafs
    
   leaf     = leaf+1;
   EdgeList = [EdgeList,[node,leaf]];
   
end


if ~isempty(ordering) %I think this is ok?
    
    
    for jj=1:length(EdgeList)
       
        EdgeList{jj}(1)=ordering(EdgeList{jj}(1));
        EdgeList{jj}(2)=ordering(EdgeList{jj}(2));
        
        
    end
    
    
    
    
end

n = core_qubits + max_leafs;


switch formatOption
    
    
    case 'EdgeList'
        
        out = EdgeList;
        
    case 'Adjacency'

        out = edgelist_to_Adj(EdgeList,n);

end

end