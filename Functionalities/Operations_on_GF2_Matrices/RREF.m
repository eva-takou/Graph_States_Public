function Tab=RREF(Tab,n)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to bring the Tableau into RREF (w/o backsubstitution)
%Input: Tab:Tableau
%       n: # of qubits
%Output: The updated Tableau.
%
%Ref: K. M. R. Audenaert and M. B Plenio, New J Phys. 7, 170 (2005)


Active_Region_Start_Row = 1;
Active_Region_Start_Col = 1;
Active_Region_End_Row   = n;
Active_Region_End_Col   = n;

KU = Active_Region_Start_Row;
NL = Active_Region_Start_Col;
K  = Active_Region_End_Row; 
N  = Active_Region_End_Col; 

FLAG=0;

while FLAG==0

    if NL>N || KU>K

        break

    end                
    
    inspect_rows = KU+n:K+n; %note that k or (k1,k2) indices we
                             %find next, measure from row KU
                             %so we need to shift them.

    Pauli_Pos_X = find( Tab(inspect_rows,NL)   & ~Tab(inspect_rows,NL+n));
    Pauli_Pos_Z = find(~Tab(inspect_rows,NL)   &  Tab(inspect_rows,NL+n));
    Pauli_Pos_Y = find( Tab(inspect_rows,NL)   &  Tab(inspect_rows,NL+n));

    
    onlyX = isempty(Pauli_Pos_Y) && isempty(Pauli_Pos_Z);
    onlyY = isempty(Pauli_Pos_X) && isempty(Pauli_Pos_Z);
    onlyZ = isempty(Pauli_Pos_X) && isempty(Pauli_Pos_Y);
    
    if isempty(Pauli_Pos_X) && isempty(Pauli_Pos_Z) && isempty(Pauli_Pos_Y) %No pauli operator for this qubit

        NL = NL+1;  
        
    elseif onlyX || onlyY || onlyZ %Only 1 kind of Pauli Operator for this qubit

        k = [Pauli_Pos_X,Pauli_Pos_Y,Pauli_Pos_Z]; %only 1 out of 3 kinds will be non-empty
        k = k(1);
        k = k + (KU-1); %We redefine k because in the find command the first row is KU.
                        %e.g. if KU=4 and k=2, then k is actually 4+(2-1)=5th row of the stabs

        if k~=KU  %SWAP if necessary:

            Tab = SWAP_rows(Tab,k,KU);     %SWAP destabs
            Tab = SWAP_rows(Tab,k+n,KU+n); %SWAP stabs

        end

        for ll=(KU+1):K %Multiply row KU with all other rows in the active
                        %region that have the same Pauli in column NL.
                        
            xi = Tab(ll+n,NL); zi=Tab(ll+n,NL+n);

            if  xi~=0 || zi~=0 %non-identity
                
                %Tab = rowsum(Tab,ll+n,KU+n); %Stab update
                Tab = rowsum(Tab,ll+n,KU+n); %Stab update
                %Tab = rowsum(Tab,KU,ll);     %Destab update
                Tab = rowsum(Tab,KU,ll);     %Destab update
                
            end
            
        end

        NL = NL+1;
        KU = KU+1;

    else %>2 kinds of operators XY, YZ, XZ or XZY.

        indx_X  = min(Pauli_Pos_X);
        indx_Y  = min(Pauli_Pos_Y);
        indx_Z  = min(Pauli_Pos_Z);
        temp    = sort([indx_X,indx_Y,indx_Z]);
        k1      = temp(1); %Pick 1st occurence of non-trivial pauli
        temp(1) = [];
        k2      = temp(1);
        
        if any(k1==indx_X) %ismember(k1,indx_X)
            
            flag1 = 'X';
            
            if any(k2==indx_Y) %ismember(k2,indx_Y)
                
                flag2='Y';
                
            else
                
                flag2='Z';
                
            end
            

        elseif any(k1==indx_Y) %ismember(k1,indx_Y)
            
            flag1='Y';
            
            if any(k2==indx_X) %ismember(k2,indx_X)
                
                flag2='X';
                
            else
                
                flag2='Z';
                
            end
                
        elseif any(k1==indx_Z) %ismember(k1,indx_Z)
            
            flag1='Z';
            
            if any(k2==indx_X) %ismember(k2,indx_X)
                
                flag2='X';
                
            else
                
                flag2='Y';
                
            end
            
            
        end

        k1=k1+(KU-1); 
        k2=k2+(KU-1);

        if k1~=KU %SWAP if necessary:

            Tab = SWAP_rows(Tab,k1,KU);
            Tab = SWAP_rows(Tab,k1+n,KU+n); 

        end

        if k2~=(KU+1)

            Tab = SWAP_rows(Tab,k2,(KU+1));
            Tab = SWAP_rows(Tab,k2+n,(KU+1)+n);

        end

        for row=KU+2:K %Multiply all other rows in the active region either 
                       %with row KU,row KU+1, both or none, depending on their element
                       
            xi = Tab(row+n,NL); zi = Tab(row+n,NL+n);

            if xi==1 && zi==0 

                if flag1=='X'

                    %Tab=rowsum(Tab,row+n,KU+n);  %Stab update
                    Tab=rowsum(Tab,row+n,KU+n);  %Stab update
                    Tab=rowsum(Tab,KU,row);      %destab update
                    %Tab=rowsum(Tab,KU,row);      %destab update

                elseif flag2=='X'

                    %Tab=rowsum(Tab,row+n,(KU+1)+n); %Stab update
                    Tab=rowsum(Tab,row+n,(KU+1)+n); %Stab update
                    Tab=rowsum(Tab,(KU+1),row); %Destab update
                    %Tab=rowsum(Tab,(KU+1),row); %Destab update

                elseif flag1=='Y' && flag2=='Z' %First rowsum with KU and then with KU+1
                    
                    %Tab=rowsum(Tab,row+n,KU+n);
                    Tab=rowsum(Tab,row+n,KU+n);
                    Tab=rowsum(Tab,KU,row);
                    %Tab=rowsum(Tab,KU,row);

                    %Tab=rowsum(Tab,row+n,(KU+1)+n);
                    Tab=rowsum(Tab,row+n,(KU+1)+n);
                    Tab=rowsum(Tab,(KU+1),row);
                    %Tab=rowsum(Tab,(KU+1),row);

                elseif flag1=='Z' && flag2=='Y' %First rowsum with KU+1 and then with KU

                    %Tab=rowsum(Tab,row+n,(KU+1)+n);
                    Tab=rowsum(Tab,row+n,(KU+1)+n);
                    Tab=rowsum(Tab,(KU+1),row);
                    %Tab=rowsum(Tab,(KU+1),row);

                    %Tab=rowsum(Tab,row+n,KU+n);
                    Tab=rowsum(Tab,row+n,KU+n);
                    Tab=rowsum(Tab,KU,row);
                    %Tab=rowsum(Tab,KU,row);

                end

            elseif xi==1 && zi==1

                if flag1=='Y'

                    %Tab=rowsum(Tab,row+n,KU+n);
                    Tab=rowsum(Tab,row+n,KU+n);
                    Tab=rowsum(Tab,KU,row);
                    %Tab=rowsum(Tab,KU,row);

                elseif flag2=='Y'

                    %Tab=rowsum(Tab,row+n,(KU+1)+n);
                    Tab=rowsum(Tab,row+n,(KU+1)+n);
                    Tab=rowsum(Tab,(KU+1),row);
                    %Tab=rowsum(Tab,(KU+1),row);

                elseif (flag1=='X' && flag2=='Z')  || (flag1=='Z' && flag2=='X')

                    %Tab=rowsum(Tab,row+n,KU+n);
                    Tab=rowsum(Tab,row+n,KU+n);
                    Tab=rowsum(Tab,KU,row);
                    %Tab=rowsum(Tab,KU,row);

                    %Tab=rowsum(Tab,row+n,(KU+1)+n);
                    Tab=rowsum(Tab,row+n,(KU+1)+n);
                    Tab=rowsum(Tab,(KU+1),row);
                    %Tab=rowsum(Tab,(KU+1),row);

                end


            elseif xi==0 && zi==1

                if flag1=='Z'

                    Tab=rowsum(Tab,row+n,KU+n);
                    %Tab=rowsum(Tab,row+n,KU+n);
                    Tab=rowsum(Tab,KU,row);
                    %Tab=rowsum(Tab,KU,row);

                elseif flag2=='Z'


                    Tab=rowsum(Tab,row+n,(KU+1)+n);
                    %Tab=rowsum(Tab,row+n,(KU+1)+n);
                    %Tab=rowsum(Tab,(KU+1),row);
                    Tab=rowsum(Tab,(KU+1),row);


                elseif flag1=='X' && flag2=='Y'  %First with Y and then with X
                

                    %Tab = rowsum(Tab,row+n,(KU+1)+n);
                    Tab = rowsum(Tab,row+n,(KU+1)+n);
                    Tab = rowsum(Tab,(KU+1),row);
                    %Tab = rowsum(Tab,(KU+1),row);

                    %Tab = rowsum(Tab,row+n,KU+n);
                    Tab = rowsum(Tab,row+n,KU+n);
                    Tab = rowsum(Tab,KU,row);
                    %Tab = rowsum(Tab,KU,row);

                elseif flag1=='Y' && flag2=='X' %First with Y and then with X

                    %Tab = rowsum(Tab,row+n,KU+n);
                    Tab = rowsum(Tab,row+n,KU+n);
                    Tab = rowsum(Tab,KU,row);
                    %Tab = rowsum(Tab,KU,row);

                    %Tab = rowsum(Tab,row+n,(KU+1)+n);                                
                    Tab = rowsum(Tab,row+n,(KU+1)+n);                                
                    Tab = rowsum(Tab,(KU+1),row);
                    %Tab = rowsum(Tab,(KU+1),row);

                end


            end


        end

        NL=NL+1;
        KU=KU+2; %this should be ok.

    end


end





end