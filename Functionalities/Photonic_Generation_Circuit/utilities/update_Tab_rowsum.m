function Tab=update_Tab_rowsum(Tab,n,row_replace,row)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to update the Tableau after row-sum operation.
%Inputs: Tab: Tableau
%        n: total # of qubits
%        row_replace: the row we are replacing with Rj*Rk
%        row: the row we are multiplying to row_replace
%
%Input rows need to be from 1 till n, (stabilizer row).

Tab = rowsum(Tab,row_replace+n,row+n);
Tab = rowsum(Tab,row,row_replace);



end