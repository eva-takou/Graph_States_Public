function [Tab,Circuit]=CNF1(Tab,n,Circuit)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Algorithm to bring the tableau in canonical form.
%Given an arbitrary tableau, it finds the sequence of operations to
%generate it. This algorithm has no restriction between which qubits
%we allow the operations to be performed.
%At the end we would need to put a sequence of H gates
%and also some X gates to restore phases.
%Ref: K. M. R. Audenaert and M. B Plenio, New J Phys. 7, 170 (2005)
%

KU = 1;
KL = n;
NL = 1;
NR = n;

while true

    %Count # of Pauli operators in 1st column NL of the active region from
    %columns KU up to KL
    
    Pauli_X = find( Tab(KU+n:KL+n , NL) & ~Tab(KU+n:KL+n , NL+n));
    Pauli_Y = find( Tab(KU+n:KL+n , NL) &  Tab(KU+n:KL+n , NL+n));
    Pauli_Z = find(~Tab(KU+n:KL+n , NL) &  Tab(KU+n:KL+n , NL+n));
    
    cond_X  = ~isempty(Pauli_X) && isempty(Pauli_Y) && isempty(Pauli_Z);
    cond_Y  = ~isempty(Pauli_Y) && isempty(Pauli_X) && isempty(Pauli_Z);
    cond_Z  = ~isempty(Pauli_Z) && isempty(Pauli_X) && isempty(Pauli_Y);
    
    cond_XY = ~isempty(Pauli_X) &&  ~isempty(Pauli_Y) &&  isempty(Pauli_Z);
    cond_XZ = ~isempty(Pauli_X) &&   isempty(Pauli_Y) && ~isempty(Pauli_Z);
    cond_YZ =  isempty(Pauli_X) &&  ~isempty(Pauli_Y) && ~isempty(Pauli_Z);
    
    if isempty([Pauli_X,Pauli_Y,Pauli_Z]) %no pauli operators in column NL
        
        %If necessary transpose column NL with column NR
        
        if NL~=NR
           
            Tab = SWAP_cols(Tab,NL,NR);
            
        end
        
        NR = NR-1;
        
    elseif cond_X || cond_Y || cond_Z %1 kind of pauli
        
        %Let k be the first row in active region where column NL contains aPauli.
        
        if cond_X
            
            k    = Pauli_X(1);
            flag = [];
            
        elseif cond_Y
            
            k    = Pauli_Y(1);
            flag = 'P';
            
        elseif cond_Z
            
            k    = Pauli_Z(1);
            flag = 'H';
        end
        
        k = k + (KU-1);
        
        if k~=KU
            
            Tab = SWAP_rows(Tab,k+n,KU+n); %SWAP stabs
            Tab = SWAP_rows(Tab,k,KU);     %SWAP destabs
            
        end
        
        %Apply whatever single-qubit operation on column NL that brings the
        %Pauli to an X operator.
        
        if ~isempty(flag)
           
            Tab     = Clifford_Gate(Tab,NL,flag);
            Circuit = store_gate_oper(NL,flag,Circuit);
            
        end
            
        %Multiply row KU with all other rows in active region that have an
        %X in column NL:
        
        for ll=KU+1:KL              
        
            if Tab(ll+n,NL)==1 && Tab(ll+n,NL+n)==0
            
                Tab = rowsumV2(Tab,ll+n,KU+n); %Stab update
                Tab = rowsumV2(Tab,KU,ll);     %Destab update
                
            end
            
        end
        
        %Consider the elements of KU for col>NL in active region.
        %To each columns beyond the 1st one, that contains pauli different
        %than X apply a gate to turn it into X.
        
        for col=NL+1:NR
            
            if Tab(KU+n,col)==1 && Tab(KU+n,col+n)==1 %Y
                
                Tab     = Clifford_Gate(Tab,col,'P');
                Circuit = store_gate_oper(col,'P',Circuit);
                Tab     = Clifford_Gate(Tab,[NL,col],'CNOT');
                Circuit = store_gate_oper([NL,col],'CNOT',Circuit);
               
            elseif Tab(KU+n,col)==0 && Tab(KU+n,col+n)==1 %Z
                
                Tab     = Clifford_Gate(Tab,col,'H');
                Circuit = store_gate_oper(col,'H',Circuit);
                Tab     = Clifford_Gate(Tab,[NL,col],'CNOT');
                Circuit = store_gate_oper([NL,col],'CNOT',Circuit);
            end
            
        end
        
        KU = KU+1;
        NL = NL+1;
        
    else %2 different types of opers in column NL
        
        if cond_XY
           
            temp = sort([Pauli_X(1),Pauli_Y(1)]);
            k1   = temp(1);
            k2   = temp(2);
            
        elseif cond_XZ

            temp = sort([Pauli_X(1),Pauli_Z(1)]);
            k1   = temp(1);
            k2   = temp(2);
            
        elseif cond_YZ
            
            temp = sort([Pauli_Y(1),Pauli_Z(1)]);
            k1   = temp(1);
            k2   = temp(2);
            
        end
        
        k1 = k1 + (KU-1);
        k2 = k2 + (KU-1);
        
        if k1~=KU
           
            Tab = SWAP_rows(Tab,k1,KU);
            Tab = SWAP_rows(Tab,k1+n,KU+n);
            
        end
        
        if k2~=(KU+1)
            
            Tab = SWAP_rows(Tab,k2,KU+1);
            Tab = SWAP_rows(Tab,k2+n,KU+1+n);
        end
        
        %Bring element on row KU to an X and element on row KU+1 to a Z
        %by applying a single-qubit operation on column NL
        
        x1 = Tab(KU+n,NL);
        z1 = Tab(KU+n,NL+n);
        
        x2 = Tab(KU+1+n,NL);
        z2 = Tab(KU+1+n,NL+n);
        
        if x1 == 0 && z1 ==1 && x2==1 && z2 ==0 %Z and X -> (H) -> X and Z
           
            Tab     = Clifford_Gate(Tab,NL,'H');
            Circuit = store_gate_oper(NL,'H',Circuit); 
        
        elseif x1==0 && z1==1 && x2==1 && z2==1 %Z and Y -> (P) -> Z and X -> (H) -> X and Z
            
            Tab     = Clifford_Gate(Tab,NL,'P');
            Tab     = Clifford_Gate(Tab,NL,'H');
            Circuit = store_gate_oper(NL,'P',Circuit);
            Circuit = store_gate_oper(NL,'H',Circuit);
            
        elseif  x1==1 && z1==1 && x2==0 && z2==1 %Y and Z-> (P) -> X and Z
            
            Tab     = Clifford_Gate(Tab,NL,'P');
            Circuit = store_gate_oper(NL,'P',Circuit);
            
        elseif x1==1 && z1==1 && x2==1 && z2==0 %Y and X -> (H) -> Y and Z -> (P) -> X and Z
            
            Tab     = Clifford_Gate(Tab,NL,'H');
            Tab     = Clifford_Gate(Tab,NL,'P');
            Circuit = store_gate_oper(NL,'H',Circuit);
            Circuit = store_gate_oper(NL,'P',Circuit);
            
        elseif x1==1 && z1==0 && x2==1 && z2==1 %X and Y -> (P) ->  Y and X -> (H) -> Y and Z -> (P) -> X and Z
            
            
            Tab     = Clifford_Gate(Tab,NL,'P');
            Tab     = Clifford_Gate(Tab,NL,'H');
            Tab     = Clifford_Gate(Tab,NL,'P');
            Circuit = store_gate_oper(NL,'P',Circuit);
            Circuit = store_gate_oper(NL,'H',Circuit);
            Circuit = store_gate_oper(NL,'P',Circuit);
            
        end
        
        %Consider rows KU and KU+1 in active region
        %Find 1st column beyond column NL say (l) that contains an
        %anticommuting pair on those rows (2 non-identical paulis)
        
        for ll=NL+1:NR
           
            x1 = Tab(KU+n,ll);
            z1 = Tab(KU+n,ll+n);
            x2 = Tab(KU+1+n,ll);
            z2 = Tab(KU+1+n,ll+n);
            
            if mod([x1,z1]*[0 1 ; 1 0]*[x2,z2]',2)~=0 %commutation relation.
                
                flag=true;
                break
                
            end
            
        end
        
        %Bring the anti-commuting pair to an (X,Y) pair by applying if
        %necessary a single qubit operation to that column.

        if flag
           
            if x1 == 0 && z1 ==1 && x2==1 && z2 ==0 %Z and X -> (P) -> Z and Y -> (H) -> X and Y

                Tab     = Clifford_Gate(Tab,ll,'P');
                Tab     = Clifford_Gate(Tab,ll,'H');
                Circuit = store_gate_oper(ll,'P',Circuit); 
                Circuit = store_gate_oper(ll,'H',Circuit); 

            elseif x1==0 && z1==1 && x2==1 && z2==1 %Z and Y -> (H) ->  X and Y

                Tab     = Clifford_Gate(Tab,ll,'H');
                Circuit = store_gate_oper(ll,'H',Circuit);

            elseif  x1==1 && z1==1 && x2==0 && z2==1 %Y and Z-> (H) -> Y and X -> (P) -> X and Y

                Tab     = Clifford_Gate(Tab,ll,'H');
                Tab     = Clifford_Gate(Tab,ll,'P');
                Circuit = store_gate_oper(ll,'H',Circuit);
                Circuit = store_gate_oper(ll,'P',Circuit);

            elseif x1==1 && z1==1 && x2==1 && z2==0 %Y and X -> (P) -> X and Y

                Tab     = Clifford_Gate(Tab,ll,'P');
                Circuit = store_gate_oper(ll,'P',Circuit);

            elseif x1==1 && z1==0 && x2==0 && z2==1 %X and Z -> (P) ->  Y and Z -> (H) -> Y and X -> (P) -> X and Y

                Tab     = Clifford_Gate(Tab,ll,'P');
                Tab     = Clifford_Gate(Tab,ll,'H');
                Tab     = Clifford_Gate(Tab,ll,'P');
                Circuit = store_gate_oper(ll,'P',Circuit);
                Circuit = store_gate_oper(ll,'H',Circuit);
                Circuit = store_gate_oper(ll,'P',Circuit);

            end
            
            Tab = Clifford_Gate(Tab,[NL,ll],'CNOT');
            Circuit = store_gate_oper([NL,ll],'CNOT',Circuit);
            
        end
        
        %The extent of active region is not changed in this case.
        
        
    end
    
    %if active region still has non-zero size (NL<=NR and KU<=KL)
    %continue with step 1 else terminate.
    
    if NL<=NR && KU<=KL
        continue
    else
        break
    end
    
end

Sx = Tab(n+1:2*n,1:n);




if ~all(all(Sx==eye(n))) 
   
    error('CNF1 failed.')
    
end
    

%Apply on all n qubits Hadamards:
for jj=1:n
    
    Tab     = Clifford_Gate(Tab,jj,'H');
    Circuit = store_gate_oper(jj,'H',Circuit);
    
    if Tab(jj+n,end)~=0
        %Need to also apply an X since XZX = -Z
        Tab     = Clifford_Gate(Tab,jj,'X');
        Circuit = store_gate_oper(jj,'X',Circuit);
        
    end
    
end




end