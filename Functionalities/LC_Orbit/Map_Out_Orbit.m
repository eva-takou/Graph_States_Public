function Adj_LC=Map_Out_Orbit(Adj,Optimizer)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Script to generate the entire LC orbit of an input graph.
%The optimizer bruteforce keeps all isomorphic graphs.
%The optimizer prune discards isomorphic graphs.

n              = length(Adj);
AdjList(1).Adj = {Adj};

switch Optimizer
    
    case 'bruteforce'
        
        cnt=1;
        
        while true %Till we generate no new graphs:
            
            AdjList(cnt+1).Adj={};
            
            for kk=1:length(AdjList(cnt).Adj) %for each adjacency in previous stage
                
                test_Adj = AdjList(cnt).Adj{kk};
                leaves   = detect_leaves(test_Adj,n);
                LC_nodes = setxor(1:n,leaves);
                
                for p=1:length(LC_nodes)
                   
                    flag   = true;
                    newAdj = Local_Complement(test_Adj,LC_nodes(p));
                    
                    %Test that the newAdj is not the same with any of the
                    %previously generated ones:
                    
                    all_Adjacencies=[AdjList.Adj];
                    
                    for l=1:length(all_Adjacencies)
                       
                        if all(all(newAdj==all_Adjacencies{l}))
                        
                           flag=false;
                           break 
                        end
                        
                    end
                    
                    if flag
                        
                        AdjList(cnt+1).Adj=[AdjList(cnt+1).Adj,{newAdj}];
                        
                    end
                    
                    
                end
                
            end
            

            if isempty(AdjList(cnt+1).Adj)
                
               break 
               
            end
            
            cnt=cnt+1;
            
        end
            
        Adj_LC = [AdjList.Adj];
        
        
    case 'prune' %To discard isomorphism
        
        cnt=1;
        
        while true %Till we generate no new graphs (and not isomorphic):
            
            AdjList(cnt+1).Adj={};
            
            for kk=1:length(AdjList(cnt).Adj) %for each adjacency in previous stage
                
                test_Adj = AdjList(cnt).Adj{kk};
                leaves   = detect_leaves(test_Adj,n);
                LC_nodes = setxor(1:n,leaves);
                
                for p=1:length(LC_nodes)
                   
                    flag   = true;
                    newAdj = Local_Complement(test_Adj,LC_nodes(p));
                    
                    %Test that the newAdj is not the same with any of the
                    %previously generated ones:
                    
                    all_Adjacencies=[AdjList.Adj];
                    
                    for l=1:length(all_Adjacencies)
                       
                        if all(all(newAdj==all_Adjacencies{l})) || ...
                           isisomorphic(graph(newAdj),graph(all_Adjacencies{l}))
                        
                           flag=false;
                           break 
                        end
                        
                    end
                    
                    if flag
                        
                        AdjList(cnt+1).Adj=[AdjList(cnt+1).Adj,{newAdj}];
                        
                    end
                    
                    
                end
                
            end
            

            if isempty(AdjList(cnt+1).Adj)
                
               break 
               
            end
            
            cnt=cnt+1;
            
        end
            
        Adj_LC = [AdjList.Adj];
        
        
end





end