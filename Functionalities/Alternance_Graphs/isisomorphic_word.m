function bool=isisomorphic_word(X,Y)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Check if the two-alternance words lead to graphs which are isomorphic.
%We transform the words to graphs to give the answer by applying the graph
%isomorphism algorithm.
%
%Input:  X, Y: The two double occurence words
%Output: bool: true or false (isomorphic or not)

isvalidword(X)
isvalidword(Y)

L = length(X)/2;

if L~=length(Y)/2
    
    bool=false;
    return
    
end

%Check if degrees are the same

degX = zeros(1,L);
degY = zeros(1,L);

for jj=1:L
    
    for kk=jj+1:L
        
        if exists_v1v2_alternance(jj,kk,X)
           
            degX(jj)=degX(jj)+1;
            degX(kk)=degX(kk)+1;
            
        end
        
    end
    
end

for jj=1:L
    
    for kk=jj+1:L
        
        if exists_v1v2_alternance(jj,kk,Y)
           
            degY(jj)=degY(jj)+1;
            degY(kk)=degY(kk)+1;
            
        end
        
    end
    
end

degX = sort(degX);
degY = sort(degY);

if any(degX~=degY)
   bool=false;
   return
end


A1=double_occur_words_to_LC_graphs(X,'Adjacency');
A1=A1{1};

A2=double_occur_words_to_LC_graphs(Y,'Adjacency');
A2=A2{1};

bool = isisomorphic(graph(A1),graph(A2));


           
    
    
    
    
end



