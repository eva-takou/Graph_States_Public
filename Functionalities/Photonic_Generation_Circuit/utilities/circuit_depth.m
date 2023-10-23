function [depth,Gates_per_depth]=circuit_depth(Circuit,ne,np)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to calculate the circuit depth of the photonic generation circuit.
%Input: Circuit: The circuit which transforms the canonical form tableau
%       into a product state |0>^{\otimes n}.
%       ne: # of emitters
%       np: # of photons
%Output: depth: the circuit depth
%        Gates_per_depth: the gates arranged per depth

%Time-ordered
Circuit.Gate.qubit = flip(Circuit.Gate.qubit); 
Circuit.Gate.name  = flip(Circuit.Gate.name);
L                  = length(Circuit.Gate.name);
n                  = np+ne;

%Encode operations into sparse matrix

Qubit_Matrix = sparse(L,n);
Gate_Matrix  = sparse(L,n);

%Gates are       H, P,  X,  Meas CNOT_{ij} , 'Y', 'Z', 'CZ'
%So put code:    1  2   3    4    56          7    8    910

f=@ (row,col,val) sparse(row,col,val,L,n);

for jj=1:L

    qubits = Circuit.Gate.qubit{jj};
    oper   = Circuit.Gate.name{jj};

    if length(qubits)==1 && ~strcmpi(oper,'Meas') %Single qubit gate

        Qubit_Matrix = Qubit_Matrix + f(jj,qubits,1);

        if strcmpi(oper,'H')

            Gate_Matrix = Gate_Matrix + f(jj,qubits,1);

        elseif strcmpi(oper,'P')

            Gate_Matrix = Gate_Matrix + f(jj,qubits,2);

        elseif strcmpi(oper,'X')    

            Gate_Matrix = Gate_Matrix + f(jj,qubits,3);
            
        elseif strcmpi(oper,'Y') 

            Gate_Matrix = Gate_Matrix + f(jj,qubits,7);
        
        elseif strcmpi(oper,'Z')     
            
            Gate_Matrix = Gate_Matrix + f(jj,qubits,8);
            
        end

    elseif strcmpi(oper,'Meas')  %Measurement of emitter

        Qubit_Matrix = Qubit_Matrix + f(jj,qubits(1),1);

        Gate_Matrix  = Gate_Matrix  + f(jj,qubits(1),4);

    elseif length(qubits)==2 && strcmpi(oper,'CNOT')  %CNOT (between emitters, or photon emission)

        Qubit_Matrix = Qubit_Matrix + f(jj,qubits(1),1); %control
        Qubit_Matrix = Qubit_Matrix + f(jj,qubits(2),1); %target

        Gate_Matrix = Gate_Matrix + f(jj,qubits(1),5);
        Gate_Matrix = Gate_Matrix + f(jj,qubits(2),6);
        
    elseif length(qubits)==2 && strcmpi(oper,'CZ')
        
        Qubit_Matrix = Qubit_Matrix + f(jj,qubits(1),1); %control
        Qubit_Matrix = Qubit_Matrix + f(jj,qubits(2),1); %target

        Gate_Matrix = Gate_Matrix + f(jj,qubits(1),9);
        Gate_Matrix = Gate_Matrix + f(jj,qubits(2),10);
        

    end

end

newGate_Matrix  = Gate_Matrix;
newQubit_Matrix = Qubit_Matrix;

while true

    L=length(newQubit_Matrix);

    for jj=1:L-1

        locs1 = find(newQubit_Matrix(jj,:));
        locs2 = find(newQubit_Matrix(jj+1,:));

        if all(~ismember(locs1,locs2)) %Rows can be combined

            newQubit_Matrix(jj,:)   = newQubit_Matrix(jj,:)+newQubit_Matrix(jj+1,:);
            newQubit_Matrix(jj+1,:) = [];

            newGate_Matrix(jj,:)    = newGate_Matrix(jj,:)+newGate_Matrix(jj+1,:);
            newGate_Matrix(jj+1,:)  = [];
            break
            
        end

    end

    if jj==L-1
        break

    end

end

depth           = size(newGate_Matrix,1);
Gates_per_depth = newGate_Matrix;

end