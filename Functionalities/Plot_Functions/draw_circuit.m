function draw_circuit(np,ne,Gate_Sequence,circuit_order,layer_shift,Init_State_Option)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%
%Input: # of photons, # of emitters, 
%       Gate_Sequence: A struct Gate_Sequence.Gate with 2 fields qubit (indices of qubits) and
%       name (name of the gate). For 2-qubit gates, the first qubit is by
%       default the control.
%       circuit_order: 'forward' or 'backward' regarding how we pass the
%       order of the circuit as an input.
%       Layer shift: some value to shift the gate boxed by 1 layer (indicating different depth index)
%       Init_State_Option: '0' or '+' for labeling the input state of the
%       qubits.
%
%
%This scripts draws a quantum circuit with 1:np photons (bottom lines)
%and np+1:np+ne emitters (top lines).
%
%

%--- Fix some parameters which work good for visualization ----------------
vspace     = 1;
box_width  = (vspace/4)*30/20; 
box_height = box_width;
LnWidths   = 1;
%==========================================================================

fntGate     = 9;
gate_colors = get_Gate_Colors;
gate_names  = get_Gate_Names;


%Get an approximate total length based on the # of gates the circuit has:

%h=draw_qubits(np,ne,vspace,Right_X,'0');

Right_X=length(Gate_Sequence.Gate.name)*(box_width+box_width)+layer_shift;


%If the Init_State_Option=='+', then check if every qubit starts with an H
%gate. Then, remove those gates and, start all the qubits with '+'

switch Init_State_Option
    
    case '+'
        
        switch circuit_order
           
            
            case 'forward'
                
                Gates  = (Gate_Sequence.Gate.name);
                Qubits = (Gate_Sequence.Gate.qubit);
                
            case 'backward' %put in forward order
                
                Gates  = flip(Gate_Sequence.Gate.name);
                Qubits = flip(Gate_Sequence.Gate.qubit);
        end
        
        
        n = np+ne;
        
        init_H_gates=false(1,n);
        locs=[];
        
        for jj=1:n
            
            for kk=1:length(Gates)
                
                if ismember(jj,Qubits{kk}) 
                    
                    if strcmpi(Gates{kk},'H')
                        
                        locs=[locs,kk];
                   
                        init_H_gates(jj)=true;
                    
                    end
                    
                    break
                end
                
            end
            
        end
        
        if all(init_H_gates)
            
            Gates(locs)=[];
            Qubits(locs)=[];
            
            
            switch circuit_order
                
                
                case 'forward' %leave it in forward order
                    
                    Gate_Sequence.Gate.qubit=(Qubits);
                    Gate_Sequence.Gate.name=(Gates);
                    
                case 'backward' %flip again to backward order

                    Gate_Sequence.Gate.qubit=flip(Qubits);
                    Gate_Sequence.Gate.name=flip(Gates);
                    

            end
            
            
            
            
            h=draw_qubits(np,ne,vspace,Right_X,'+');
            
        else
            
            h=draw_qubits(np,ne,vspace,Right_X,'0');
            
        end
        
    case '0'
        
        h=draw_qubits(np,ne,vspace,Right_X,'0'); 
        
end



switch circuit_order
    
    case 'forward'
        
        l0=1;
        lstep=+1;
        lf=length(Gate_Sequence.Gate.qubit);
        
    case 'backward'
        
        l0=length(Gate_Sequence.Gate.qubit);
        lstep=-1;
        lf=1;
        
end


for ll=l0:lstep:lf

    qubits = Gate_Sequence.Gate.qubit{ll};
    gates  = Gate_Sequence.Gate.name{ll};
    hold on
    
    if length(qubits)==1 %Single qubit gate.
        
        if strcmpi(gates,'Pdag')
            clr = gate_colors.('P');
        else
            clr = gate_colors.(gates);
        end
        rectangle('Position',[layer_shift (h(qubits).YData(1)-box_height/2) box_width box_height],... %x,y,w,h 
                  'linewidth',LnWidths,'facecolor',clr);
            
        pos=[layer_shift,(h(qubits).YData(1)-box_height/2),box_width,box_height];
              
        if ~strcmpi(gates,'Pdag')
            text(pos(1)+pos(3)/2,pos(2)+pos(4)/2,gate_names.(gates),'HorizontalAlignment','center','fontsize',fntGate)      
        else
            text(pos(1)+pos(3)/2,pos(2)+pos(4)/2,'$P^\dagger$','HorizontalAlignment','center','fontsize',fntGate,'interpreter','latex')      
        end

        layer_shift=layer_shift+0.5+box_width/2;
        
        continue
              
    end
    
    
    %If it is not a measurement, draw the circle for the control qubit:
    
    if ~strcmpi(gates,'Meas') && ~strcmpi(gates,'MeasX') && ~strcmpi(gates,'MeasY')
        
       scatter(layer_shift+box_width/2,h(qubits(1)).YData(1),40,'filled','markerfacecolor','k',...
           'markeredgecolor','k')
        hold on

        %Draw the vertical line from qubit 1 to qubit 2
        line([layer_shift+box_width/2,layer_shift+box_width/2],[h(qubits(1)).YData(1),h(qubits(2)).YData(1)],...
            'color','k','linewidth',LnWidths)
        hold on
        
    end
    
    %Now if it is CNOT draw a box, if it's CZ draw another circle:
    
    if strcmpi(gates,'CNOT')
        
        clr = gate_colors.(gates);
        
        rectangle('Position',[layer_shift (h(qubits(2)).YData(1)-box_height/2) box_width box_height],... %x,y,w,h 
                  'linewidth',LnWidths,'facecolor',clr) 
              
        pos=[layer_shift,(h(qubits(2)).YData(1)-box_height/2),box_width,box_height];      
        text(pos(1)+pos(3)/2,pos(2)+pos(4)/2,gate_names.(gates),'HorizontalAlignment','center','fontsize',fntGate)      
        
    elseif strcmpi(gates,'CZ')
        
        
        scatter(layer_shift+box_width/2,h(qubits(2)).YData(1),40,'filled','markerfacecolor','k','markeredgecolor','k')          
        
    end
    
    
    if strcmpi(gates,'Meas') || strcmpi(gates,'MeasY') || strcmpi(gates,'MeasX')
        

        %Draw vertical lines from measured emitter to previously absorbed photon. 

        line([layer_shift+box_width*0.4,layer_shift+box_width*0.4],[h(qubits(1)).YData(1)-box_height/2,h(qubits(2)).YData(1)],...
            'color','k','linewidth',LnWidths)

        line([layer_shift+box_width*0.6,layer_shift+box_width*0.6],[h(qubits(1)).YData(1)-box_height/2,h(qubits(2)).YData(1)],...
            'color','k','linewidth',LnWidths)                
        
        %Draw the gate of feed-forward
        rectangle('Position',[layer_shift (h(qubits(2)).YData(1)-box_height/2) box_width box_height],'linewidth',LnWidths,...
           'facecolor',gate_colors.('X')) %x,y,w,h 
       
        pos=[layer_shift,(h(qubits(2)).YData(1)-box_height/2),box_width,box_height];
        
        text(pos(1)+pos(3)/2,pos(2)+pos(4)/2,gate_names.('X'),'HorizontalAlignment','center','fontsize',fntGate)      

       %Draw the box of measurement
        rectangle('Position',[layer_shift (h(qubits(1)).YData(1)-box_height/2) box_width box_height],'linewidth',LnWidths,...
           'facecolor','k') %x,y,w,h 
       
        if strcmpi(gates,'Meas')
            
            text(layer_shift+2*box_width/2,(h(qubits(1)).YData(1)-box_height/2)-box_height/2,'Z','HorizontalAlignment','center','fontsize',fntGate)      
            
        elseif strcmpi(gates,'MeasX')
            
            text(layer_shift+2*box_width/2,(h(qubits(1)).YData(1)-box_height/2)-box_height/2,'X','HorizontalAlignment','center','fontsize',fntGate)      
           
            
        elseif strcmpi(gates,'MeasY')
            
            text(layer_shift+2*box_width/2,(h(qubits(1)).YData(1)-box_height/2)-box_height/2,'Y','HorizontalAlignment','center','fontsize',fntGate)      
            
        end
       
        b=1.3;
       
        th = linspace(0,pi,100);
        R  = box_width/4*b;
        x  = R*cos(th)+layer_shift+box_width/2;
        y  = R*sin(th)+h(qubits(1)).YData(1)-box_width/8*b;
       
       
        plot(x,y,'color','w','linewidth',1.2)
        %plot a y=x line but shifted arguments i.e. y-y0 = (x-x0)
       
        line([layer_shift+box_width/2,layer_shift+3*box_width/4],...
             [h(qubits(1)).YData(1)-box_width/8*b,h(qubits(1)).YData(1)+box_height/3],'color','w','linewidth',1.2)

       
    end
    
    layer_shift=layer_shift+0.5+box_width/2;

end

set(gcf,'color','w')
axis off
axis equal
ax = gca;               % get the current axis
ax.Clipping = 'off';

zoom(1)






end