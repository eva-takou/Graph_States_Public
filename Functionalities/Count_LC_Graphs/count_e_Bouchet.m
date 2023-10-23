function eF=count_e_Bouchet(Adj)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Recursive implementation to count the e number for a given graph F. 
%Based on Bouchet's paper: Recognizing locally equivalent graphs, 1991.
%Input : Adjacency matrix of graph
%Output: The index e(F).

if length(Adj)==1 %graph P_1 (single node)
    
    eF=2;
    return
    
end

v  = 1;
Nv = Get_Neighborhood(Adj,v);

if isempty(Nv) %isolated node

    Adj(:,v)=[];
    Adj(v,:)=[];
    eF = 2*count_e_Bouchet(Adj);
    
else
   
    A1 = Adj;
    A1(:,v)=[];
    A1(v,:)=[];
    
    A2 = Adj;
    A2 = Local_Complement(A2,v);
    A2(:,v)=[];
    A2(v,:)=[];
    
    w  = Nv(1);
    
    A3 = Adj;
    A3 = Local_Complement(A3,v);
    A3 = Local_Complement(A3,w);
    A3 = Local_Complement(A3,v);
    A3(:,v)=[];
    A3(v,:)=[];
    
    eF = count_e_Bouchet(A1)+count_e_Bouchet(A2)+count_e_Bouchet(A3);
    
end


end



