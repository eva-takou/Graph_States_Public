classdef Tableau_Class
%--------------------------------------------------------------------------    
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%Class to simulate photonic graph state generation.
%--------------------------------------------------------------------------    
    properties
        
        Tableau                           %Target Tableau for photonic graph state generation
        Tableau_RREF                      %Augmented Tableau (photons+emitters) in RREF
        
        node_ordering                      %Ordering of nodes for photonic generation.
        Photonic_Generation_Gate_Sequence  %Circuit to generate the target graph.
        Photonic_Generation_Graph_Evol     %Evolution of the photonic generation in reverse.
        Emitters                           %Number of emitters to generate a given target graph, based on node_ordering
        Emitter_CNOT_count                 %Total emitters' CNOT count of the photonic generation circuit
        height                             %Height function of target photonic graph.
        Photonic_Generation_Circuit_Depth  %Depth of photonic generation circuit.
        Photonic_Generation_Gate_per_Depth %Photonic generation circuit, where gates are arranged per time-step. 
        
        Destab_String                     %Destabilizer string of Tableau
        Stab_String                       %Stabilizer string of Tableau
        
        VertexDegree                      %Degree of vertices
        Cliques                           %Degree of vertices
        
    end
    
    methods %Constructor method to initialize a Tableau
        
        function obj = Tableau_Class(inp,Option)   
        %Constructor requires input stabilizers in a string or the edgelist.
        %Option specifies which one is provided.
        
        switch Option
            
            case 'Stabs'

                if ischar(inp{1})
                
                S  = Stabs_String_to_Binary(inp);
                
                else %Otherwise given input is binary
                    
                    mustBeBinary(inp)
                    S = inp;
                
                end
                
                [n,cols]  = size(S);
                
                if cols~=2*n && cols~=2*n+1
                        
                    error('Stab array is of incorrect size.')
                    
                end
                
                D  = construct_Destabs(S);  %D is always (n x 2n)
                %S could be  (n x 2n) or (n x 2n+1) -- if we also give a phase.                          
            
                if cols == 2*n
                
                    Tab = [D;S];
                    Tab = [Tab,sparse(2*n,1)];   %Add extra column of 0s for phases
                
                elseif cols== 2*n+1 %We have a column with phases as well
                
                    Tab = [D;S(:,1:2*n)];
                    Tab = [Tab,[sparse(n,1);S(:,2*n+1)]];
                    
                end
                
                Tab = [Tab;sparse(1,2*n+1)]; %Add 2n+1 row
            
            case 'EdgeList'
            
                L = length(inp);
                n = max([inp{:}]);
            
                Sx = speye(n);
                Sz = sparse(n,n);
                
                for l=1:L
                    
                    edge = inp{l};
                    
                    Sz = Sz + sparse(edge(1),edge(2),1,n,n);
                    Sz = Sz + sparse(edge(2),edge(1),1,n,n);
                    
                end
                
                S   = [Sx,Sz];
                D   = construct_Destabs(S);
                Tab = [D;S];    
                Tab = [Tab,sparse(2*n,1)];   %Add extra column
                Tab = [Tab;sparse(1,2*n+1)]; %Add 2n+1 row
             
            
            case 'Adjacency'
                
                mustBeSimple(inp)
                
                n  = size(inp,1);
                Sz = inp;
                Sx = speye(n);
                
                S  = [Sx,Sz];
                Dz = speye(n);
                Dx = sparse(n,n);
                
                D   = [Dx,Dz];
                Tab = [D;S];
                
                Tab = [Tab,sparse(2*n,1)];   %Add extra column
                Tab = [Tab;sparse(1,2*n+1)]; %Add 2n+1 row
             
        end
        
        mustBeValidTableau(Tab)
        obj.Tableau=Tab;
        
        end
        
    end
 
    methods 
        
        function obj=Tableau_To_String(obj,Option)
            
            switch Option
                
                
                case 'Tab'
                    
                    [d,s]=Tab_To_String(obj.Tableau);
                    
                case 'Tab_RREF'
                    
                    [d,s]=Tab_To_String(obj.Tableau_RREF);
                    

            end
            
            obj.Destab_String=d;        
            obj.Stab_String=s;            
            
            
            
            
        end
        
    end

    methods %Graph characterization
        
        %Ok
        function obj=Get_Vertex_Degree(obj)
        %From the adjacency matrix, find with how many other vertices
        %a single node is. This is the vertex degree of each node.
        
        
            
        Gamma=Get_AdjacencyMat(obj.Tableau); %Adjacency matrix
        [n,~]=size(Gamma);
        
        for ii=1:n
            cnt=0;
            
            for jj=1:n
                
               if ii~=jj 
                
                if Gamma(ii,jj)==1 %we have a connection
                    
                    cnt=cnt+1;
                    
                    obj.VertexDegree(ii)=cnt;
                    
                elseif Gamma(ii,jj)==0
                    
                    obj.VertexDegree(ii)=cnt+0;
                    
                end
                
                
               end
            end
        end
             
        end
        
        %I think ok.
        function [obj,Logic]=isBipartite(obj)
            
        %To be a bipartite graph, we need to be able to color every two
        %adjacent nodes with 2 different colors. 2-colorable = bipartite
        
        %=========== Procedure of the algorithm ===========================
        % Assign a red color to some starting vertex S
        % Find the neighbors of S and assign a blue color
        % Find the neighbor's neighbor and assign a red color
        % Continue this until all nodes have been assigned a color
        % If a neighbor vertex and the current vertex have the same color 
        % return "Not a bipartite graph"
        % Otherwise, return "Bipartite graph".
        
        %== Use Depth-first-search algorithm explained here: https://www.techiedelight.com/depth-first-search/
        
        Edges     = Get_Edges(obj.Tableau);
        [n,~]     = size(obj.Tableau);   
        n         = (n-1)/2;
        
        colors    = cell(1,n);
        colors{1} = 'red';      %start coloring 1st vertex
        
        for parent_node = 1 : n 
            
            for e = 1 : length(Edges)
                
               if any(ismember(Edges{e},parent_node))
                   
                   neighbor = Edges{e}(~ismember(Edges{e},parent_node));
                   
                   if strcmp(colors{parent_node},'red') && isempty(colors{neighbor})
                       
                      colors{neighbor}='blue';
                      
                   elseif strcmp(colors{parent_node},'blue') && isempty(colors{neighbor})
                      
                       colors{neighbor}='red';
                       
                   elseif ~isempty(colors{neighbor}) && strcmp(colors{parent_node},colors{neighbor})
                       
                           disp('Graph is not bipartite.')
                           Logic=false;
                           return
                     
                       
                   end
                   
               end
                
            end
            
            
        end
        Logic=true;
        disp('Graph is bipartite.')
        
            
        end
        
        %I think ok.
        function [obj,Logic]=isComplete(obj)
         %Each vertex should have a degree n-1. Otherwise, all off-diagonal
         %entries should have a value of 1.
         
         obj=Get_Vertex_Degree(obj);
         
         [n,~]=size(obj.Tableau); n=(n-1)/2;
         
         for ii=1:n
            
             if obj.VertexDegree(ii)~=(n-1)
                 
                disp('Graph is not complete.')
                Logic=false;
                return
                 
             end
             
         end
            Logic=true;
         disp('Graph is complete.')
         
            
        end
        
        function [obj,Logic]=isEulerian(obj)
            
         obj=Get_Vertex_Degree(obj);
         
         [n,~]=size(obj.Tableau); n=(n-1)/2;
         
         for ii=1:n
            
             if (-1)^obj.VertexDegree(ii)==-1 %odd degree
                 
                disp('Graph is not Eulerian.')
                Logic=false;
                return
                 
             end
             
         end
         Logic=true;   
         disp('Graph is Eulerian.')
            
            
        end
         
        function [obj,Logic]=iskRegular(obj)
            

         obj=Get_Vertex_Degree(obj);
         
         
         v_deg = obj.VertexDegree;
         
         if all(v_deg==v_deg(1))
             Logic=true;
             disp(['Graph is k-regular with k=',num2str(v_deg(1))])
             
         else
             Logic=false;
            disp('Graph is not k-regular.') 
             
         end
         
        
             
            
            
            
        end
       
        function [obj,Logic]=isConnected(obj)
        %Check if graph is connected (GHZ), i.e. if every node has
        %neighbors all other n-1 nodes.
        
        [n,~]=size(obj.Tableau);
        n=(n-1)/2;
        
        for node =  1:n
           
            Neigh=Get_Neighbors(obj.Tableau,node);
            
            if ~all(ismember(setxor(1:n,node),Neigh))
                Logic=false;
                disp('Graph is not connected.')
                return
            end
            
            
            
            
        end
        
            disp('Graph is connected.')
            Logic=true;
        end
        
        function [obj,Logic]=isTree(obj)
        %True if it is connected and has exactly n-1 edges
        
        [n,~]=size(obj.Tableau);
        n=(n-1)/2;
        
        for node =  1:n
           
            Neigh=Get_Neighbors(obj.Tableau,node);
            
            if ~all(ismember(setxor(1:n,node),Neigh))
                Logic=false;
                disp('Graph is not tree.')
                return
            end
            
            
        end
            
        
        Edges = Get_Edges(obj.Tableau);
        
        if length(Edges)==(n-1)
           Logic=true; 
           disp('Graph is a tree.')
            
           
        else
            Logic=false;
            disp('Graph is not a tree.')
        end
            
            
        end
        
        function obj=InducedSubgraphs(obj)
        %Find all the induced subgraphs of G. Let S be a subset of nodes
        %of the nodes of G. Then G[S] is an induced subgraph of G, if it
        %contains all edges of G that have both endpoints in S.
        
        [n,~] = size(obj.Tableau);
        n     = (n-1)/2;
        Edges = Get_Edges(obj.Tableau);
        
        for k=2:n-1
        
            nodes_in_S = nchoosek(1:n,k);
            [rows,~]   = size(nodes_in_S);
            
            for ii=1:rows
                
                cnt           = 0;
                testing_nodes = nodes_in_S(ii,:);
                
                %Add into edge set E_S an edge, if both endpoints in
                %testing_nodes
                
                for e = 1 : length(Edges)
                    
                    if any(ismember(Edges{e}(1),testing_nodes)) && any(ismember(Edges{e}(2),testing_nodes))
                        
                        cnt=cnt+1;
                        Edges_S{cnt} = [Edges{e}(1),Edges{e}(2)];
                        
                    end
                    
                end
                
                if cnt==0
                    
                    continue
                    
                else
                    
                    disp(['The nodes ',num2str(testing_nodes),' with E_S={'])
                     
                    for p=1:cnt
                        
                        disp(['{',num2str(Edges_S{p}),'}'])
                    
                     
                    end
                    
                    disp('}, is an induced subgraph of G.')
                    
                end
                
                
            end
            
            
            
        end
        
            
        end
        
        function [obj,Logic]=isInducedSubgraph(obj,S,ES)
        %Given nodes S and an edge set ES, is the graph H(V,ES) an induced 
        %subgraph of G?
        
          for node_indx = 1 : length(S) 
              
              u = S(node_indx);
              Neigh = Get_Neighbors(obj.Tableau,u);
              
              flag=0;
              
              for neighbor_indx = 1:length(Neigh)
                  
                  v=Neigh(neighbor_indx);
                  
                  %loop through the edge set ES
                  
                  for e = 1 : length(ES) %if the edge (u,v) is not in ES then it is not induced subgraph
                     
                      if any(ismember(u,ES{e})) && any(ismember(v,ES{e}))
                          
                          flag=1;
                          
                      end
                      
                      
                  end
                  
                  if flag==0
                      Logic=false;
                      disp('Input graph is not an induced subgraph of G.')
                      return
                  end
                  
                  
              end
              
              
              
              
          end
        
          if flag==1
              Logic=true;
              disp('Input graph an induced subgraph of G.')
          end
          
        
            
        end
             
        function BronKerbosch1(obj)    
        %R: currently growing clique
        %P: prospective nodes which are all connected to all nodes in R 
        %X: nodes already processed i.e., nodes which were previously in P
        %   and hence all maximal cliques containing them have already been
        %   reported.
        
        %Output: MC list of max cliques
        Tab=obj.Tableau;
        [n,~] = size(Tab);
        n     = (n-1)/2;
        
        R=[]; X=[]; P=1:n;
        
        M=[];
        BK(R,P,X,Tab);
        
            function BK(R,P,X,Tab)

%                 disp('into BK with')
%                 disp(['P : ',num2str(P)])
%                 disp(['R : ',num2str(R)])
%                 disp(['X : ',num2str(X)])
%                 disp('-----------------')
                
                
                if isempty(P) && isempty(X)
                    
                    
                    disp(['Max clique found: ',num2str(R)])
                    
                    %make M to be a column matrix where the columns with
                    %ones (each column is from 1:n) correspond to nodes that form a clique.
                    
                    temp=zeros(n,1);
                    temp(R)=1;
                    
                    M=[M,temp];
                else
                    %M=[];
                
                    
                end
                
                
                for v = 1:length(P)
                    
%                     disp(['Entered for loop of BK with P(v)=',num2str(P(v))])
%                     disp(['and P = ',num2str(P)])
%                     disp(['and X = ',num2str(X)])
%                     disp(['and R = ',num2str(R)])
%                     disp('-----------')
              
                    
                    
                    
                    Neigh=Get_Neighbors(Tab,P(v));
                    
%                     disp(['Calling BK again with R = ',num2str([R,P(v)])])
%                     disp(['and P = ',num2str(intersect(Neigh,P))])
%                     disp(['and X = ',num2str(intersect(Neigh,X))])
%                     disp('--------')
                    
                    BK([R,P(v)],intersect(Neigh,P),intersect(X,Neigh),Tab);
                    
                    
%                     disp('Before setting new rules')
%                     disp(['R: ',num2str(R)])
%                     disp(['P: ',num2str(P)])
%                     disp(['X: ',num2str(X)])
%                     disp('----------')
%                     disp(['Removing v=',num2str(P(v)),' from P and putting into X'])
                    X      = [X,P(v)];
                    P(P==P(v))= nan;
%                     disp(['new P: ',num2str(P)])
%                     disp(['new X: ',num2str(X)])
%                     disp(['R: ',num2str(R)])
                    
                    
                end
                
               
                
                
            end
        
            MC=M;
            [~,col]=size(MC);
            
            disp('Done.')
            disp(['The number of cliques is:',num2str(col)])
            
            
        end

    end
    
    methods %Apply Cliffords or measurements 
        
        function obj=Apply_Clifford(obj,qubit,Oper)
            
            obj.Tableau=Clifford_Gate(obj.Tableau,qubit,Oper);
            
        end
        
        function obj=Apply_SingleQ_Meausurement(obj,qubit,basis)
            
            obj.Tableau=Measure_single_qubit(obj.Tableau,qubit,basis);
        
        end
        
    end
    
    
    methods %Photonic generation scripts

        function obj=reshuffle_nodes(obj,node_ordering)
        %This function is used to reshuffle the nodes of an input tableau.
        %It uses a permutation matrix to do the shuffling.
        
        Tab = obj.Tableau;
        n   = (size(Tab,2)-1)/2;
        
        mustBeValidOrdering(node_ordering,n)
        
        
        P  = speye(n);
        Dx = Tab(1:n,1:n);
        Dz = Tab(1:n,n+1:2*n);
        Sx = Tab(n+1:2*n,1:n);
        Sz = Tab(n+1:2*n,n+1:2*n);
        
        P(:,1:n)=P(:,node_ordering);
        
        %== Shuffle Stabs/Destabs==
        Sx = mod(P*Sx*P',2);
        Sz = mod(P*Sz*P',2);
        Dx = mod(P*Dx*P',2);
        Dz = mod(P*Dz*P',2);
        
        Tab(1:n,1:n)         = Dx;
        Tab(1:n,n+1:2*n)     = Dz;
        Tab(n+1:2*n,1:n)     = Sx;
        Tab(n+1:2*n,n+1:2*n) = Sz;
        
        %== Shuffle the phases (Is this correct?) ========
        
        Tab(1:n,end)     = P*Tab(1:n,end);      %phases of D
        Tab(n+1:2*n,end) = P*Tab(n+1:2*n,end);  %phases of S
        
        
        obj.Tableau=Tab;
            
            
        end
        
        function obj=Get_Emitters(obj,node_ordering)
        %Get the # of Emitters for a particular node ordering of the given graph.
        %The Tableau is updated into the new node ordering.
            
                           n = (size(obj.Tableau,2)-1)/2;
            obj              = obj.reshuffle_nodes(node_ordering);
            obj.height       = height_function(RREF(obj.Tableau,n),n); %The height function needs as input the target photonic generation Tableau.
            obj.Emitters     = max(obj.height);
        
        end

        function obj=Generation_Circuit(obj,node_ordering,Store_Graphs) 
        %Script for generation circuit based on Bikun's approach.
        %Input: Ordering of photon emission.
        %Circuit is in time reversed order.
        %Greedy approach but no optimization in terms of which emitter to
        %select. 
        
        Circuit = [];    
        obj     = obj.Get_Emitters(node_ordering);
        obj.node_ordering = node_ordering;
        
        ne  = obj.Emitters;
        np  = (size(obj.Tableau,2)-1)/2;
        n   = np+ne;    
        h   = obj.height;
        
        %===== The target photonic graph state and Tableau ==============
        Target_Tableau = obj.Tableau; 
        G0             = Get_Adjacency(Target_Tableau);
        
        graphs.Adjacency{1}  = G0;
        graphs.identifier{1} = 'Input';
        
        %== Augment the Tableau with emitters in |0> and put it in RREF ==
        
        workingTab = RREF(AugmentTableau(Target_Tableau,ne),n);
        mustBeValidTableau(workingTab);
        
        %=== Begin the generation procedure (in reverse) =================
        
        for jj = np+1:-1:2

            disp('=================================================================')    
            disp(['Beginning iteration: ',num2str(jj-1)])            
            
            photon = jj-1;
            
            if jj<np+1 
               
                workingTab = RREF_w_back_substitution(workingTab,n);
                h          = height_function(workingTab,n);
                
            end
            
            obj.Tableau_RREF=workingTab;
            %obj.Tableau_To_String('Tab_RREF')
            
            
            dh = h(jj)-h(jj-1); 
            
            if dh<0 %Need TRM--cannot absorb photon yet.
                
                [workingTab,Circuit,graphs]=time_reversed_measurement(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs);
                
            end

            obj.Tableau_RREF=workingTab;
            %obj.Tableau_To_String('Tab_RREF')
            
            
            [workingTab,Circuit,graphs,discovered_emitter,~]=photon_absorption_WO_CNOT(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs);
            
            
            if ~discovered_emitter
               
                [workingTab,Circuit,graphs]=photon_absorption_W_CNOT(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs);
                
            end
            
            if photon==1 %all photons were absorbed
            
                break
                
            end
            
        end
        
        workingTab = RREF(workingTab,n);
        %mustBeValidTableau(workingTab)
        
        if ne>1 %Disentangle the emitters:
            [workingTab,Circuit,graphs]=disentangle_all_emitters(workingTab,np,ne,Circuit,graphs,Store_Graphs);
        end
        
        [workingTab,Circuit] = remove_redundant_Zs(workingTab,np,ne,Circuit); %Convert the tableau to Zs:
        [workingTab,Circuit] = fix_phases(workingTab,np,ne,Circuit); %Fix phases:
       
        mustBeValidTableau(workingTab)
        
        Verify_Quantum_Circuit(Circuit,n,ne,Target_Tableau)
        obj.Photonic_Generation_Gate_Sequence  = Circuit;
        obj.Photonic_Generation_Graph_Evol     = graphs;
        
        %=== End of photonic generation ==================================
        
        end
        
        function obj=Optimize_Generation_Circuit(obj,node_ordering,Store_Graphs,prune,avoid_subs_emitters,tryLC,LC_Rounds) 
        %Script for generation circuit based on Bikun's approach.
        %This script inspects all emitter choices by branching new choices as recursions.  
        %Input: Ordering of photon emission.
        %Circuit is in time reversed order.
        %Optimize for all emitter choices for photon absorption, by allowing as well 
        %row operations. 
        %This doesn't include yet the additional optimization for TRMs.

        Circuit           = [];    
        obj               = obj.Get_Emitters(node_ordering); 
        obj.node_ordering = node_ordering;
        
        ne  = obj.Emitters;
        np  = (size(obj.Tableau,2)-1)/2;
        n   = np+ne;    
        
        %===== The target photonic graph state and Tableau ==============
        Target_Tableau       = obj.Tableau; 
        G0                   = Get_Adjacency(Target_Tableau);
        graphs.Adjacency{1}  = G0;
        graphs.identifier{1} = 'Input';

        %== Augment the Tableau with emitters in |0> and put it in RREF ==

        workingTab = RREF(AugmentTableau(Target_Tableau,ne),n);
        mustBeValidTableau(workingTab);

        %=== Run the generation procedure (in reverse) ====================

        [OUT_Tab,OUT_Circ,OUT_graphs]=Generation_Circuit_Opt(obj,workingTab,Circuit,graphs,np,ne,n,Store_Graphs,prune,avoid_subs_emitters,tryLC,LC_Rounds);
              
        %=================================================================
        
        %Now apply the disentangling procedure of emitters:

        LT        = length(OUT_Tab);
        CNOT_cnt  = zeros(1,LT);
        depth_cnt = zeros(1,LT);
        
        for jj=1:length(OUT_Circ)
           
            current_cnots(jj)=emitter_CNOTs(OUT_Circ{jj},ne,np);
            
        end
        
        for kk=1:LT

            workingTab = OUT_Tab{kk};
            Circuit    = OUT_Circ{kk};
            graphs     = OUT_graphs{kk};

            workingTab = RREF(workingTab,n);
            %mustBeValidTableau(workingTab)

            if ne>1 %Disentangle the emitters:

                [workingTab,Circuit,graphs]=disentangle_all_emitters(workingTab,np,ne,Circuit,graphs,Store_Graphs);

            end 

            %mustBeValidTableau(workingTab)
            [workingTab,Circuit] = remove_redundant_Zs(workingTab,np,ne,Circuit); %Convert the tableau to Zs
            [workingTab,Circuit] = fix_phases(workingTab,np,ne,Circuit); %Fix phases

            %mustBeValidTableau(workingTab)
            Verify_Quantum_Circuit(Circuit,n,ne,Target_Tableau)

            
            OUT_Circ{kk}   = Circuit;
            OUT_graphs{kk} = graphs;
            %obj.Photonic_Generation_Gate_Sequence  = Circuit;
            %obj.Photonic_Generation_Graph_Evol     = graphs;

            CNOT_cnt(kk)  = emitter_CNOTs(Circuit,ne,np);
            depth_cnt(kk) = circuit_depth(Circuit,ne,np);
            
        end

        
        %We could make several choices of which circuit to pick
        %and we could choose to study all of the above.
        
        %CNOT_cnt
        %depth_cnt
        
        [~,indx] = min(CNOT_cnt);
        
        obj.Emitter_CNOT_count                = CNOT_cnt(indx);
        obj.Photonic_Generation_Circuit_Depth = depth_cnt(indx);
        obj.Photonic_Generation_Gate_Sequence = OUT_Circ{indx};
        obj.Photonic_Generation_Graph_Evol    = OUT_graphs{indx};
        
        
        end
        
        function obj=Count_emitter_CNOTs(obj,node_ordering)
            
            
            if isempty(obj.Photonic_Generation_Gate_Sequence)
               obj= obj.Generation_Circuit(node_ordering);
            end
            
            ne       = obj.Emitters;
            np       = (size(obj.Tableau,1)-1)/2;
            Circuit  = obj.Photonic_Generation_Gate_Sequence;
            
            CNOT_cnt = emitter_CNOTs(Circuit,ne,np);
            
            obj.Emitter_CNOT_count=CNOT_cnt;
            
            
            
        end
        
        function obj=Count_Circuit_Depth(obj)
            
            Circuit = obj.Photonic_Generation_Gate_Sequence;
            np      = (size(obj.Tableau,1)-1)/2;
            ne      = obj.Emitters;
            
            [depth,Gates_per_depth]=circuit_depth(Circuit,ne,np);
            
            obj.Photonic_Generation_Circuit_Depth  = depth;
            obj.Photonic_Generation_Gate_per_Depth = Gates_per_depth;
            
        end
        
    end
    
    
end


