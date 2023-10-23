function binary_matrix=Gauss_elim_GF2(binary_matrix)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to implement gaussian elimination in the field GF2.

[m,n]=size(binary_matrix);

%Determine the leftmost non-zero column
col_start=1;
row_start=1;
ROW=1;
COL=1;

while ROW<=m && COL<=n

    for col=col_start:n

        nnz_el=nnz(binary_matrix(row_start:end,col));

        if nnz_el>0
            col_loc = col;
            row_loc = find(binary_matrix(row_start:end,col),1); 
            break
        end

    end

    if nnz_el~=0
    %Use row operations to put a 1 in the topmost position of
    %this column, i.e. SWAP the rows
    binary_matrix=SWAP_rows(binary_matrix,ROW,row_loc+(row_start-1));
    %Use elementary row operations to put 1s below the pivot
    %position
    nnz_rows=find(binary_matrix(row_start:end,col_loc));
    else
        break

    end

    if ~isempty(nnz_rows)

        nnz_rows=nnz_rows+(row_start-1);
        nnz_rows=setxor(nnz_rows,ROW);

        for jj=1:length(nnz_rows)

            binary_matrix=bitxor_rows(binary_matrix,nnz_rows(jj),ROW);

        end


    end


    nnz_full_rows=nnz(binary_matrix(ROW+1:end,:));

    if nnz_full_rows==0
        break

    end

    ROW=ROW+1;   
    COL=COL+1;
    col_start=col_start+1;
    row_start=row_start+1;

end





end