function [] = f_plot_2echograms_norange( mat1, mat2 , range , matnames )
% Requires 4 args: mat1 & mat2 (2D array) , range (1D or 2D array), matnames

doMAX = true;

range = range(1,:);

MSUB=1; 
NSUB=4;
figure('Color',[1 1 1],'Name','f_plot_2echograms_norange-Fig1');
        subplot(MSUB,NSUB,1)
        imagesc( mat1' );
        try
            title(matnames{1});
        catch
            title('echogram 1');
        end
        subplot(MSUB,NSUB,2)
        imagesc( mat2' );
        try
            title(matnames{2});
        catch
            title('echogram 2');
        end
        subplot(MSUB,NSUB,3)
        if(doMAX)
            plot( max(mat1,[],1), [1:length(max(mat1,1))], '.-k');
            title(['max ' matnames{1}])
        else
            plot( mode(mat1,1), [1:length(mode(mat1,1))], '.-k');
            title(['mode ' matnames{1}])
        end
        set (gca,'YDir','reverse')
        
        %ylim( [0, max(range)] );  
        
        subplot(MSUB,NSUB,4)
        if(doMAX)
            plot( max(mat2,[],1), [1:length(max(mat2,1))], '.-k');
            title(['max ' matnames{2}])
        else
            plot( mode(mat2,1), [1:length(mode(mat2,1))], '.-k');
            title(['mode ' matnames{2}])
        end
        set (gca,'YDir','reverse')
        %ylim( [0, max(range)] );
        
% % sphere expected location
%         hold on;
%         plot( spherePos.ampLinmean    ,spherePos.rangemean, 'og','MarkerSize',12,'LineWidth',2);
%         text( spherePos.ampLinmean+0.1,spherePos.rangemean, 'target', 'color',[0, .8, 0]);