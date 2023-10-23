function out=create_cluster(m,n,formatOption)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Create the edgelist or the adjacency of a cluster state.
%Default labeling is per vertical column i.e. per m-th column.
%Input: m,n: size of cluster
%       formatOption: 'Edgelist' or 'Adjacency' to control the output.


EdgeList = [];

for jj=1:n %Need n such paths in total

    temp = create_Pn(m,'EdgeList'); %The path from 1 till m

    for ll=1:length(temp)

        temp{ll}=temp{ll}+m*(jj-1); 

    end

    EdgeList = [EdgeList,temp];

end

newEdgeList = EdgeList;

%Add the parallel edges:

for jj=1:n-1

    Edges_Pj_1 = EdgeList(1       : (m-1));
    Edges_Pj_2 = EdgeList(1+(m-1) : 2*(m-1));

    for ll=1:length(Edges_Pj_1)

        edge1 = Edges_Pj_1{ll};
        edge2 = Edges_Pj_2{ll};

        for k=1:2

            newEdgeList = [newEdgeList,{[edge1(k),edge2(k)]}];
        end

    end

    EdgeList(1 : (m-1))=[];

end

%remove duplicates
indx = [];

for j1=1:length(newEdgeList)

    for j2=j1+1:length(newEdgeList)

        if all(newEdgeList{j1}==newEdgeList{j2})

            indx= [indx,j2];
            break

        end
    end

end

newEdgeList(indx) = [];
out               = newEdgeList;

switch formatOption
    
    case 'EdgeList'
        
        return

    case 'Adjacency'
        
        out=edgelist_to_Adj(newEdgeList,m*n);
        return
        
end

end