function h=draw_qubits(np,ne,vertical_spacing,Xmax,Init_State_Option)
%--------------------------------------------------------------------------
%Created by: Eva Takou
%
%Last modified: Oct 23, 2023
%--------------------------------------------------------------------------
%
%Function to draw the qubits for a circuit. 
%Inputs:  np: # of photons
%         ne: # of emitters
%         vertical_spacing: the vertical spacing separation of qubit lines
%         Xmax: the max right X value that the qubit line extends.
%         Init_State_Option: '0' or '+' to label the initial state of the
%         qubits

y       = 0; 
qubits  = np+ne;
fntsize = 15; 
xloc    = -0.7; %0.5
lnwidth = 1;
Y0      = vertical_spacing;


switch Init_State_Option
    
    case '0'
        
        state='$|0\rangle_{';
        
    case '+'
        
        state='$|+\rangle_{';
end

for ii=1:qubits

    %h=line([1,qubits],[y+(ii-1)*vspace, y+(ii-1)*vspace],'color','k','linewidth',2);
    h(ii)=line([1,Xmax],[y+(ii-1)*Y0, y+(ii-1)*Y0],'color','k','linewidth',lnwidth);
    hold on

    if ii<=np

        %text(xloc,y+(ii-1)*Y0,strcat('p_{',num2str(ii),'}'),'fontsize',fntsize)
        
        text(xloc,y+(ii-1)*Y0,[state,num2str(ii),'}$'],'fontsize',fntsize,'interpreter','latex')
        hold on

    else

        hold on
        %text(xloc,y+(ii-1)*Y0,strcat('e_{',num2str(ii-np),'}'),'fontsize',fntsize,'color','b')

        text(xloc,y+(ii-1)*Y0,strcat(state,num2str(ii),'}$'),'fontsize',fntsize,'color','b','interpreter','latex')
        
    end

end

set(gcf,'color','w')
set(gca,'fontname','Microsoft Sans Serif','fontsize',fntsize)
axis off
axis equal
title('Photonic graph generation circuit','fontname','Microsoft Sans Serif')



end