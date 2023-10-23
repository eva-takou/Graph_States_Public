function Adj=all_adjacencies(n,discard_isomorphism)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to create all adjacency nxn matrices in GF2.
%Input:  n: the number of nodes 
%        discard_isomorphism: true or false to keep or not the isomorphs.
%Output: all adjacency matrices of order n in cell array.

edges={};
for jj=1:n
    
    for kk=jj+1:n
    
        edges=[edges,{[jj,kk]}];
   
    end    
end

Le  = length(edges);
Adj = {};

edges = parallel.pool.Constant(edges);

parfor jj=n-1:Le %Need to choose AT LEAST n-1 edges for the graph to be connected (necessary but not sufficient)
    
    combs = nchoosek(1:Le,jj);
    
    disp(['running jj=',num2str(jj),' out of ',num2str(Le),' ...'])
    
    rows = size(combs,1);
    
    for mm=1:rows
    
        disp(['mm=',num2str(mm),' out of ',num2str(rows)])
        
        this_comb = combs(mm,:);

        if length(unique([edges.Value{[this_comb]}]))==n %one requirement (necessary, not sufficient) for connected graph is that every node appears in at least one edge
            
            %cnt=cnt+1;
            %EdgeList{cnt}  ={edges{[this_comb]}};
                
            temp = reshape([edges.Value{[this_comb]}],2,length([edges.Value{[this_comb]}])/2).';            
            Adj  = [Adj,{sparse(temp(:,1),temp(:,2),1,n,n)+sparse(temp(:,2),temp(:,1),1,n,n)}];
            
            %Adj{cnt}=;
            
        end
        
    end
    
end

disp('Done.')

clearvars -except Adj n discard_isomorphism


%Check if some of the graphs are disconnected based on dfs search
indx=[];
disp('-----------------------------------------------------------')
disp('Checking disconnected or not...')
parfor kk=1:length(Adj)
    if ~isconnected(Adj{kk},n,'Adjacency')
       indx=[indx,kk]; 
    end
end
disp('Done.')
Adj(indx)=[];
disp('-----------------------------------------------------------')
disp(['Found ',num2str(length(Adj)),' connected graphs.'])

disp('-----------------------------------------------------------')



if discard_isomorphism
    
    
disp('Converting them to graphs...')

for jj=1:length(Adj)
    
   g{jj}=graph(Adj{jj});
    
end
        
        
disp('Done.')
disp('-----------------------------------------------------------')        

indx=[];
LG = length(Adj);

%g = parallel.pool.Constant(g); %This takes too long for n>=6
    
    
    
    
    disp('Checking isomorphism....')
    %WaitMessage = parfor_wait(LG, 'Waitbar', true);

    parfor jj=1:LG
        
        disp(['jj=',num2str(jj),' out of ',num2str(LG)])
        
        for kk=jj+1:LG
            
            if isisomorphic(g{jj},g{kk})
                
               indx=[indx,kk]; 
               break
            end
            
        end
        
        %WaitMessage.Send;
        
        
    end
    %WaitMessage.Destroy;
    disp('Done.')
    
Adj(unique(indx))=[];

disp(['Found ',num2str(length(Adj)),' connected non-isomorphic graphs.'])
    
end



end



%Construct adjacency based on edgelist

% cnt=0;
% disp('Constructing adjacencies...')
% for jj=1:length(EdgeList)
%     
%     disp(['runnning jj=',num2str(jj),' out of ',num2str(length(EdgeList))])
%     current_edges = EdgeList{jj};    
%     cnt           = cnt+1;    
%     Adj{cnt}      = sparse(n,n);
%     
%     for kk=1:length(current_edges)
%    
%         v1       = current_edges{kk}(1);
%         v2       = current_edges{kk}(2);
%         Adj{cnt} = Adj{cnt} + sparse(v1,v2,1,n,n) + sparse(v2,v1,1,n,n);
%         
%     end
%     
% end

% disp('Done.')