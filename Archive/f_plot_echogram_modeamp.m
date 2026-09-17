function [] = f_plot_echogram_modeamp( mat2d , range )
% Requires 2 args: mat2d (2D array) , range (1D or 2D array)
% range can be empty and then range=1:size(mat1)

if(isempty(range)) 
    range = [1:size(mat2d,2)];
else
    range = range(1,:);
end

MSUB=1; 
NSUB=4;
figure('Color',[1 1 1],'Name','f_plot_echogram_and_modeamp-Fig1');
        subplot(MSUB,NSUB,1)
        imagesc( 10.^(mat2d/10)' );
        title('echogram (linear)');
        subplot(MSUB,NSUB,2)
        imagesc( mat2d' );
        title('echogram (log)');
        subplot(MSUB,NSUB,3)
        plot( mode(mat2d,1), [1:size(mat2d,2)], '.-k');
        set (gca,'YDir','reverse')
        title('mode by sample')
        ylim( [1, size(mat2d,2)] );    
        subplot(MSUB,NSUB,4)
        plot( mode(mat2d,1), range, '.-k');
        title('mode by range')
        set (gca,'YDir','reverse')
        ylim( [0, max(range)] );
        
% % sphere expected location
%         hold on;
%         plot( spherePos.ampLinmean    ,spherePos.rangemean, 'og','MarkerSize',12,'LineWidth',2);
%         text( spherePos.ampLinmean+0.1,spherePos.rangemean, 'target', 'color',[0, .8, 0]);