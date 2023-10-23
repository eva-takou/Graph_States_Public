function Verify_Quantum_Circuit(Circuit,n,ne,Target_Tableau)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Script to verify that the quantum circuit gives rise to the Target
%tableau.
%The input: Circuit to generate the Target tableau
%           n: number of qubits
%           ne: # of emitters
%           Target_Tableau: the target tableau in canonical form.

%Define a new tableau that corresponds to all qubits in |0>.

Init_Tab = Initialize_Tab(n);
Tab      = Init_Tab;
L        = length(Circuit.Gate.name);

for ll=L:-1:1 %Loop in reverse
   
    Oper   = Circuit.Gate.name{ll};
    Qubits = Circuit.Gate.qubit{ll};
    
    if strcmpi(Oper,'Meas')
        Oper = 'CNOT';
    end
    
    if numel(Qubits)<=2 && ~iscell(Oper)
        
        Tab    = Clifford_Gate(Tab,Qubits,Oper);
    
    elseif size(Qubits,1)==1 && iscell(Oper)
        
        for jj=1:length(Qubits)
            
            Tab    = Clifford_Gate(Tab,Qubits(jj),Oper{jj});
            
        end
        
    elseif size(Qubits,1)>1 && iscell(Oper)  %Parallel gates, but for verification just apply them in subsequence
        
        for jj=1:size(Qubits,1)
            
            Tab = Clifford_Gate(Tab,Qubits(jj,:),Oper{jj});
            
        end
        
        
    end

    
end
mustBeValidTableau(Tab) 

%Will it hold that Tableaus are exactly the same? -- they could be
%equivalent up to a basis change for example [row-operations]

%Will this comparison be reliable at all times?
 
G0 = Get_Adjacency(Target_Tableau);
G1 = Get_Adjacency(Tab);
G1 = G1(1:n-ne,1:n-ne); %Remove the emitters (last positions)


if any(any(G0~=G1))
   
    error('Found different adjacency matrices.')
    
end

%*** Plot also the input graph and the one obtained by the algorithm ***


end


function Tab=Initialize_Tab(n)
%Create the trivial tableau: all qubits start from |0>.

Sz = speye(n);
Sx = sparse(n,n);
Dx = speye(n);
Dz = sparse(n,n);

D   = [Dx,Dz];
S   = [Sx,Sz];
Tab = [D;S];
Tab = [Tab,sparse(2*n,1)];
Tab = [Tab;sparse(1,2*n+1)];

end