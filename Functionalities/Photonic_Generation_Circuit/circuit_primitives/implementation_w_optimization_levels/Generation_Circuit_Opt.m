function [Tab_Out,Circ_Out,Graphs_Out,Emitter_History_Out_Mat]=Generation_Circuit_Opt(obj,workingTab,Circuit,graphs,np,ne,n,Store_Graphs,prune,avoid_subs_emitters,tryLC,LC_Rounds)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Optimization script for finding the circuit to prepare a photonic graph
%state from emitters, by miniming the CNOT cost between emitters.
%It explores photonic emissions by different emitters, row operations, and
%local complementations. The circuit is traversed in reverse order, to
%convert the target tableau (provided in canonical form) to a product state
%where all qubits start from |0>^{\otimes n}.
%The local complementations are strictly applied after we have started
%consuming away some part of the graph e.g., right after the 2nd TRM.
%We also perform local complementation right after a CNOT gate between
%emitters.
%
%We further have the option to prune away choices, or force the optimizer
%to select different emitter qubits for consecutive photonic emissions.
%
%Input: Tab: Target Tableau in canonical form.
%       Circuit: An empty struct with field Circuit.Gate.name and
%       Circuit.Gate.qubit
%       graphs: A struct with fields graphs.Adjacency and graphs.identifier
%       np: # of photons
%       ne: # of emitters
%       Store_Graphs: true or false to keep track of how the graph changes
%       prune: true or false to discard realizations
%       avoid_subs_emitters: true or false to restrict search such that we
%       do not use the same emitter in consecutive emissions
%       tryLC: true or false to allow local complementations during the
%       generation
%       LC_Rounds: 1 or 2 or 3 or 4 regarding up to how many LC sequences
%       we want to go. (TRM only explores 1). Example: 1 LC round is only
%       about single nodes v, 2 LC rounds is about v1*v2, v1*v3,... v2*v1
%       etc
%Output: Tab_Out: All possible tableaus
%        Circ_Out: All corresponding circuits
%        Graphs_Out: All corresponding graph evolutions
%        Emitter_History_Out_Mat: A matrix of how we used the emitters.
%
%Note: The emitters have not yet been decoupled for all tableaus, we have
%only finished with consuming all the photons.


%TO DO:
%Finish up with the lines regarding pruning and avoiding subsequent use of
%the same emitter.

%--------------------------------------------------------------------------
level               = np+1; %Call this level because it is related to recursions.
Tab_Out             = [];
Circ_Out            = [];
Graphs_Out          = [];
Emitter_History     = zeros(1,np);
Emitter_History_Out = {};
%------ Initialize empty stacks ------------------------------------------
newTab           = repmat({[]},1,np+1);  
newCirc          = newTab;
newgraphs        = newTab;
emitter_choices  = newTab;

trmTab          = newTab;
trmCirc         = newCirc;
trmGraphs       = newgraphs; 
perform_TRM     = true;
%-------------------------------------------------------------------------
while true %Keep looping till we have used up all trmTabs and all newTabs

    photon           = level-1;
    workingTab       = RREF(workingTab,n);
    h                = height_function(workingTab,n);
    obj.Tableau_RREF = workingTab;  %obj.Tableau_To_String('Tab_RREF');
    dh               = h(level)-h(level-1); 
    %-------- TRM stage ---------------------------------------------------
    
    if perform_TRM
        
        if dh<0 %Need TRM

            [tempTab,tempCirc,tempGraphs]=time_reversed_measurement(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs);

            %Try LCs after TRM (just consider 1 round of LCs):
            
            if photon<np && tryLC
                
                Adj0=Get_Adjacency(tempTab);
                
                LC_qubits=[];
                
                for jj=1:n
                   
                    [cond_prod,~]=qubit_in_product(tempTab,n,jj);
                    
                    if ~cond_prod
                       
                        LC_qubits=[LC_qubits,jj];
                        
                    end
                    
                end
                
                Tab0    = tempTab;
                Circ0   = tempCirc;
                Graphs0 = tempGraphs;
                
                tempTab    ={};
                tempCirc   ={};
                tempGraphs ={};
                
                for k=1:length(LC_qubits)
                    
                   v=LC_qubits(k);
                   Nv=Get_Neighborhood(Adj0,v);
                   
                   Tab=Tab0;
                   Circuit=Circ0;
                   Graphs=Graphs0;
                   
                   if length(Nv)>1
                      
                     
                       Tab = Clifford_Gate(Tab,v,'H');
                       Tab = Clifford_Gate(Tab,v,'P');
                       Tab = Clifford_Gate(Tab,v,'H');

                       Circuit = store_gate_oper(v,'H',Circuit);  
                       Circuit = store_gate_oper(v,'P',Circuit);  
                       Circuit = store_gate_oper(v,'H',Circuit);  

                       for l=1:length(Nv)
                           
                            Tab     = Clifford_Gate(Tab,Nv(l),'P');
                            Circuit = store_gate_oper(Nv(l),'P',Circuit);  
                           
                       end
                           
                       
                       if Store_Graphs
                          
                           Graphs  = store_graph_transform(Local_Complement(Adj0,v),strcat('After LC_{',num2str(v),'} [After TRM]'),Graphs);
                           
                       end
                       
                       tempTab    = [tempTab,{Tab}];
                       tempCirc   = [tempCirc,{Circuit}];
                       tempGraphs = [tempGraphs,{Graphs}];
                       
                   end
                    
                    
                    
                end
                
                
                
            end
            
            
            if ~iscell(tempTab)
                
                %The first ne TRMS need no optimization. We have available emitters we can pick for free.
                %The output of time_reversed_measurement_NEW is a unique decision.
                
                tempTab    ={tempTab};
                tempCirc   ={tempCirc};
                tempGraphs ={tempGraphs};
                    
            end
                
            trmTab{level}    = [trmTab{level},tempTab];
            trmCirc{level}   = [trmCirc{level},tempCirc];
            trmGraphs{level} = [trmGraphs{level},tempGraphs];

        end
        
    end
    
    %----- FIFO on trmTabs ------------------------------------------------
    if dh<0 %We entered a TRM above so we need to pick out a workingTab to proceed
    
        workingTab = trmTab{level}{1};
        Circuit    = trmCirc{level}{1};
        graphs     = trmGraphs{level}{1};
        
        trmTab{level}(1)    =[];
        trmCirc{level}(1)   =[];
        trmGraphs{level}(1) =[];
    
    else %We didn't entered a TRM above, so we have a workingTab already
         
        perform_TRM=true; %We need to re-allow TRM for next iterations.
        
    end
    %----------------------------------------------------------------------
    
    obj.Tableau_RREF = workingTab; %obj.Tableau_To_String('Tab_RREF');               

    %----------- PA step --------------------------------------------------    
    
    [workingTab,Circuit,graphs,discovered_emitter,emitters]=photon_absorption_WO_CNOT_Opt(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs);

    if ~discovered_emitter 

        
        [workingTab,Circuit,graphs,emitters]=photon_absorption_W_CNOT_Opt(workingTab,np,ne,photon,Circuit,graphs,Store_Graphs,tryLC,LC_Rounds); %Output Tab, circuit and graphs are cells 

        if ~iscell(workingTab)

            error('WHY DID THIS ENTER HERE??????')

        end

    else

        %Emitter_History(photon) = emitters; %Single emitter was found.
        %workingTab = {workingTab};
        %Circuit    = {Circuit};
        %graphs     = {graphs};
        %emitters   = {emitters};

    end
        
    newTab{level}          = [workingTab,newTab{level}]; %FIFO
    newCirc{level}         = [Circuit,newCirc{level}];        
    newgraphs{level}       = [graphs,newgraphs{level}];
    emitter_choices{level} = [emitters,emitter_choices{level}];
        
    %--------- Moving to next level ---------------------------------------
    
    if photon==1 %We have absorbed the last photon -- store all tableaus of this last level.

        if prune %Discard circuits of current level whose CNOT cnt exceeds the min CNOT cnt.

            [newTab,newCirc,newgraphs,emitter_choices]=prune_procedure(newTab,newCirc,newgraphs,emitter_choices,ne,np,level);            CNOT_cnt = zeros(1,length(newTab{level})); %re-initialize.

        end

        %Avoid using the same emitter in subsequent steps:
        if avoid_subs_emitters && length(unique(cell2mat(emitter_choices{level})))>1 

            [newTab,newCirc,newgraphs,emitter_choices,Emitter_History]=penalize_sequential_emitter_usage(newTab,newCirc,newgraphs,emitter_choices,Emitter_History,level);

        end

        LN = length(newTab{level});

        for jj=1:LN  %Store every tab, all have been processed (for a particular TRM Tab) and we have absorbed photon #1

            Tab_Out      = [Tab_Out,newTab{level}(jj)];
            Circ_Out     = [Circ_Out,newCirc{level}(jj)];
            Graphs_Out   = [Graphs_Out,newgraphs{level}(jj)];

            %if avoid_subs_emitters && length(unique(cell2mat(emitter_choices{level})))>1 

                %Emitter_History_Out = [Emitter_History_Out,Emitter_History];
            %else
                %Emitter_History(1)  = emitter_choices{level}{jj};
                %Emitter_History_Out = [Emitter_History_Out,Emitter_History];
            %end

        end

        newTab{level}(1:LN)          = [];
        newCirc{level}(1:LN)         = [];
        newgraphs{level}(1:LN)       = [];
        %emitter_choices{level}(1:LN) = [];

    end

    %Pop out and remove from list. -- Move to appropriate level.

    if isempty(newTab{level})

        indx = get_next_nonempty_level_newTab(newTab);
        
        if isempty(indx)   %All tableaus from newTab have been processed.
            
            indx=get_next_nonempty_level_trmTab(trmTab); %Have we used up all trmTabs?
            
            if isempty(indx)
                
                break %Exhausted all possibilities. Exit the loop.
                
            else 
                
                perform_TRM = false; %Turn this off, because we are returning to the same level and we don't want to re-perform TRM.
                level       = indx;  
                
                [workingTab,Circuit,graphs,trmTab,trmCirc,trmGraphs,emitter_choices,level]=...
                    process_next_trmTab(trmTab,trmCirc,trmGraphs,emitter_choices,level);                
                
                continue %Skip lines below because there are no more newTabs left.
                
            end
            
        end

        level = indx;        

    end    

    if ~isempty(newTab{level}) %Pop out the next tableau to process.

        if prune %Discard circuits of current level whose CNOT cnt exceeds the min CNOT cnt.

            [newTab,newCirc,newgraphs,emitter_choices]=prune_procedure(newTab,newCirc,newgraphs,emitter_choices,ne,np,level);

        end

        if avoid_subs_emitters && length(unique(cell2mat(emitter_choices{level})))>1 
            
            %Need to be careful to not terminate if we dont have the option
            %to use another emitter. This is taken care off based on the
            %last constraint.

            [newTab,newCirc,newgraphs,emitter_choices,Emitter_History]=penalize_sequential_emitter_usage(newTab,newCirc,newgraphs,emitter_choices,Emitter_History,level);            
            %Restore, because we did overwriting above:
            %Emitter_History(level-1) = emitter_choices{level}{1};
            
        else
            
            %Emitter_History(level-1) = emitter_choices{level}{1};
            
        end

        
        [workingTab,Circuit,graphs,newTab,newCirc,newgraphs,emitter_choices,level]=...
         process_next_newTab(newTab,newCirc,newgraphs,emitter_choices,level);
        
    end    


end

%--- Make sure we have processed all Tableaus -----------------------------

indx1=get_next_nonempty_level_newTab(newTab);
indx2=get_next_nonempty_level_trmTab(trmTab);

if ~isempty(indx1) || ~isempty(indx2)
    
   error('Some realizations have not been processed all the way to the end.') 
    
end


for jj=1:length(Emitter_History_Out)
    
    Emitter_History_Out_Mat(jj,:)=Emitter_History_Out{jj};
   
    
end

%---Check that we found the emitter history/usage per photon correctly:----
% Emitter_History_Out_Mat_TEST = zeros(size(Emitter_History_Out_Mat,1),size(Emitter_History_Out_Mat,2));
% 
% for jj=1:length(Circ_Out) %Check that we are calculating correctly the emitters used per step:
%     
%     this_Circ = Circ_Out{jj};
%     
%     for ll=1:length(this_Circ.Gate.qubit)
%     
%         qubits = this_Circ.Gate.qubit{ll};
%         
%         if length(qubits)>1 && qubits(2)<=np 
%             
%             Emitter_History_Out_Mat_TEST(jj,qubits(2)) = qubits(1);
%             
%         end
%         
%     end
%     
%     
% end
% 
% if ~all(all(Emitter_History_Out_Mat_TEST==Emitter_History_Out_Mat))
%    
%     error('Did not store the emitter usage correctly.') 
%     
% end
% 
%---------The above passes the test so we can comment the lines.----------


%Drop remaining cases where we use the same emitter in consecutive steps:

if ne>1 && avoid_subs_emitters
    
    to_remove=[];
    
    for jj=1:size(Emitter_History_Out_Mat,1)

        this_History = Emitter_History_Out_Mat(jj,:);

        if any(diff(this_History)==0) %Checks x(2)-x(1), x(3)-x(2)...
                                      %if any element=0, then we used the same
                                      %emitter in consecutive steps.
            to_remove=[to_remove,jj];

        end

    end
    
    if length(to_remove)<length(Tab_Out)
        
        Tab_Out(to_remove)    = [];
        Circ_Out(to_remove)   = [];
        Graphs_Out(to_remove) = [];
        Emitter_History_Out_Mat(to_remove,:)=[];
        
    end
end


if prune

    
    CNOT_cnt=zeros(1,length(Circ_Out));

    for p=1:length(Circ_Out)

        CNOT_cnt(p)=emitter_CNOTs(Circ_Out{p},ne,np);

    end

    [minCNOT_cnt,~]=min(CNOT_cnt);

    to_remove = find(CNOT_cnt>minCNOT_cnt);
    
    if length(to_remove)<length(CNOT_cnt)
    
        Tab_Out(to_remove)=[];
        Circ_Out(to_remove)=[];
        Graphs_Out(to_remove)=[];
        Emitter_History_Out_Mat(to_remove,:)=[];
    
    end
    
end

if  isempty(Tab_Out)
    
   error('We have a bug, we probably generated circuits but discarded all of them in the process.') 
   
end

end


function [newTab,newCirc,newgraphs,emitter_choices]=prune_procedure(newTab,newCirc,newgraphs,emitter_choices,ne,np,level)
%Discard circuits of current level. If at the current level a particular
%Circuit has a min value of CNOT count = s, and the other Circuits at the
%current level have a min value of CNOT count > s, then we discard those
%Tableaus and circuits, and we do not process them till the end.

CNOT_cnt = zeros(1,length(newTab{level})); %re-initialize.
            
for p=1:length(newTab{level})

    CNOT_cnt(p)=emitter_CNOTs(newCirc{level}{p},ne,np);

end

[minCNOT,~]     = min(CNOT_cnt);

CNOT_exceed_min = find(CNOT_cnt>minCNOT);

if length(CNOT_exceed_min)<length(CNOT_cnt)

    newTab{level}(CNOT_exceed_min)          = [];
    newCirc{level}(CNOT_exceed_min)         = [];
    newgraphs{level}(CNOT_exceed_min)       = [];
    emitter_choices{level}(CNOT_exceed_min) = [];

end
            
        



end

function [newTab,newCirc,newgraphs,emitter_choices,Emitter_History]=penalize_sequential_emitter_usage(newTab,newCirc,newgraphs,emitter_choices,Emitter_History,level)

to_remove = [];

for p=1:length(newTab{level})

    Emitter_History(level-1) = emitter_choices{level}{p};

    if Emitter_History(level-1)==Emitter_History(level)

        to_remove = [to_remove,p];

    end

end

if length(to_remove)<length(newTab{level})

    newTab{level}(to_remove)          = [];
    newCirc{level}(to_remove)         = [];
    newgraphs{level}(to_remove)       = [];
    emitter_choices{level}(to_remove) = [];

end

end


function indx=get_next_nonempty_level_newTab(newTab)

indx=[];
for jj=1:length(newTab)  %Find the next non-empty level

    if ~isempty(newTab{jj})

        indx=jj;
        break

    end

end

end

function indx=get_next_nonempty_level_trmTab(trmTab)

cond=false;
for jj=1:length(trmTab)  %Find the next non-empty level

    if ~isempty(trmTab{jj})

        indx=jj;
        cond=true;
        break

    end

end 

if ~cond
   indx=[]; 
end


end


function [workingTab,Circuit,graphs,newTab,newCirc,newgraphs,emitter_choices,level]=...
         process_next_newTab(newTab,newCirc,newgraphs,emitter_choices,level)


workingTab              = newTab{level}{1};
Circuit                 = newCirc{level}{1};
graphs                  = newgraphs{level}{1}; 

newTab{level}(1)          = [];    %FIFO
newCirc{level}(1)         = [];
newgraphs{level}(1)       = []; 
%emitter_choices{level}(1) = [];
level                     = level-1; %Get the tableau and go to photon absorption of next photon.


end


function [workingTab,Circuit,graphs,trmTab,trmCirc,trmgraphs,emitter_choices,level]=...
         process_next_trmTab(trmTab,trmCirc,trmgraphs,emitter_choices,level)


workingTab              = trmTab{level}{1};
Circuit                 = trmCirc{level}{1};
graphs                  = trmgraphs{level}{1}; 

trmTab{level}(1)          = [];    %FIFO
trmCirc{level}(1)         = [];
trmgraphs{level}(1)       = []; 
%emitter_choices{level}(1) = [];

%Do not move one level down, because we are not done with the photon
%absorption of the current photon.

end