function [Tab,Circuit]=remove_redundant_Zs(Tab,np,ne,Circuit)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to bring all emitters in Z/to row-multiply to remove trivial Z
%operators.
%Inputs: Tab: Tableau
%        np: # of photons
%        ne: # of emitters
%        Circuit: The circuit so far
%Output: Tab: The updated tableau
%        Circuit: The updated circuit

n = np+ne;

%Make sure that all qubits are in product:

for qubit = 1:n
    
   [cond_product, state_flag]= qubit_in_product(Tab,n,qubit); 
    
   if ~cond_product
       
      ME=exception('MyComponent:falseCond','Some qubit was not in product state');
      throw(ME)
       
   else
       
       %Bring all the qubits into Zs:
       
       switch state_flag
           
           case 'X'
               
               Tab     = Clifford_Gate(Tab,qubit,'H');
               Circuit = store_gate_oper(qubit,'H',Circuit); 
               
           case 'Y'
               
               Tab = Clifford_Gate(Tab,qubit,'P');
               Tab = Clifford_Gate(Tab,qubit,'H');
           
               Circuit = store_gate_oper(qubit,'P',Circuit); 
               Circuit = store_gate_oper(qubit,'H',Circuit); 
       end
       
   end
   
end


Tab=do_gauss(Tab,n);  %this will not update correctly destabilizers, but put them as Xs

Dx = speye(n);
Dz = sparse(n,n);

D=[Dx,Dz];

Tab(1:n,1:2*n)=D;
Tab(1:n,end)=0;


end


% function Tab=do_gauss(Tab,n)
% %I think I should do this with rowsum
% %Make sure I'm keeping track of the phases correctly.
% 
% 
% col_start=1;
% row_start=1;
% ROW=1;
% COL=1;
% 
% binary_matrix=Tab(n+1:2*n,n+1:2*n);
% 
% while ROW<=n && COL<=n
% 
% for col=col_start:n
% 
%     nnz_el=nnz(binary_matrix(row_start:end,col));
% 
%     if nnz_el>0
%         col_loc = col;
%         row_loc = find(binary_matrix(row_start:end,col),1); 
%         break
%     end
% 
% end
% 
% %Use row operations to put a 1 in the topmost position of
% %this column, i.e. SWAP the rows
% binary_matrix=SWAP_rows(binary_matrix,ROW,row_loc+(row_start-1));
% Sx          = SWAP_rows(Tab(n+1:2*n,1:n),ROW,row_loc+(row_start-1));
% 
% Tab(n+1:2*n,n+1:2*n)=binary_matrix;
% Tab(n+1:2*n,1:n)=Sx;
% 
% %Use elementary row operations to put 1s below the pivot
% %position
% nnz_rows=find(binary_matrix(row_start:end,col_loc));
% 
% if ~isempty(nnz_rows)
% 
%     nnz_rows=nnz_rows+(row_start-1);
%     nnz_rows=setxor(nnz_rows,ROW);
% 
%     for jj=1:length(nnz_rows)
% 
%         binary_matrix = bitxor_rows(binary_matrix,nnz_rows(jj),ROW);
%         Sx            = bitxor_rows(Tab(n+1:2*n,1:n),nnz_rows(jj),ROW);
%         Tab(n+1:2*n,n+1:2*n)=binary_matrix;
%         Tab(n+1:2*n,1:n)=Sx;
% 
%     end
% 
% 
% end
% 
% 
% nnz_full_rows=nnz(binary_matrix(ROW+1:end,:));
% 
% if nnz_full_rows==0
%     break
% 
% end
% 
% ROW=ROW+1;   
% COL=COL+1;
% col_start=col_start+1;
% row_start=row_start+1;
% 
% end            
% 
% 
% if ~all(all(speye(n)==binary_matrix))
% 
%     for col=n:-1:1
% 
%         nnz_rows=find(binary_matrix(:,col));
%         rrow=col;
% 
%         if length(nnz_rows)>=2
% 
%             nnz_rows=setxor(nnz_rows,col);
% 
% 
%             for ll=1:length(nnz_rows)
% 
%                 binary_matrix = bitxor_rows(binary_matrix,nnz_rows(ll),rrow); 
%                 Sx            = bitxor_rows(Tab(n+1:2*n,1:n),nnz_rows(ll),rrow);
% 
%             end
% 
% 
%         end
% 
%     end
% 
% 
% 
% end
% 
% Tab(n+1:2*n,n+1:2*n)=binary_matrix;        
% Tab(n+1:2*n,1:n)=Sx;           
% 
% 
% 
% end

function Tab=do_gauss(Tab,n)

col_start=1;
row_start=1;
ROW=1;
COL=1;


while ROW<=n && COL<=n

for col=col_start:n

    nnz_el=nnz(Tab(n+row_start:2*n,col+n));

    if nnz_el>0
        col_loc = col;
        row_loc = find(Tab(n+row_start:2*n,col+n),1); 
        break
    end

end

%Use row operations to put a 1 in the topmost position of this column, i.e. SWAP the rows

Tab = SWAP_rows(Tab,ROW,row_loc+(row_start-1));     %SWAP Destabilizers
Tab = SWAP_rows(Tab,ROW+n,row_loc+(row_start-1)+n); %SWAP Stabilizers

%binary_matrix = SWAP_rows(binary_matrix,ROW,row_loc+(row_start-1));
%Sx            = SWAP_rows(Tab(n+1:2*n,1:n),ROW,row_loc+(row_start-1));


%Tab(n+1:2*n,n+1:2*n) = binary_matrix;
%Tab(n+1:2*n,1:n)     = Sx;

%Use elementary row operations to put 1s below the pivot position
%nnz_rows=find(binary_matrix(row_start:end,col_loc));
nnz_rows=find(Tab(n+row_start:2*n,n+col_loc)); %Sz part

if ~isempty(nnz_rows)

    nnz_rows=nnz_rows+(row_start-1);
    nnz_rows=setxor(nnz_rows,ROW);

    for jj=1:length(nnz_rows)

        
        Tab = update_Tab_rowsum(Tab,n,nnz_rows(jj),ROW);
        %binary_matrix = bitxor_rows(binary_matrix,nnz_rows(jj),ROW);
        %Sx            = bitxor_rows(Tab(n+1:2*n,1:n),nnz_rows(jj),ROW);
        %Tab(n+1:2*n,n+1:2*n)=binary_matrix;
        %Tab(n+1:2*n,1:n)=Sx;

    end


end


nnz_full_rows=nnz(Tab(n+ROW+1:2*n,1:2*n));

if nnz_full_rows==0
    break

end

ROW=ROW+1;   
COL=COL+1;
col_start=col_start+1;
row_start=row_start+1;

end            


if ~all(all(speye(n)==Tab(n+1:2*n,1:n)))

    for col=n:-1:1

        nnz_rows=find(Tab(n+1:2*n,col+n));
        rrow=col;

        if length(nnz_rows)>=2

            nnz_rows=setxor(nnz_rows,col);


            for ll=1:length(nnz_rows)

                
                Tab=update_Tab_rowsum(Tab,n,nnz_rows(ll),rrow);
                %binary_matrix = bitxor_rows(binary_matrix,nnz_rows(ll),rrow); 
                %Sx            = bitxor_rows(Tab(n+1:2*n,1:n),nnz_rows(ll),rrow);

            end


        end

    end



end

% Tab(n+1:2*n,n+1:2*n)=binary_matrix;        
% Tab(n+1:2*n,1:n)=Sx;           



end

