function [] = f_plot_echogram_maxamp( mat1 , range , matnames )
% Requires 3 args: mat1 (2D array) , range (1D or 2D array), matnames

doMAX = true;

range = range(1,:);

for(indx=1:length(matnames))
    matnames(indx) = regexprep(matnames(indx), '_',' ');
end

MSUB=1; 
NSUB=3;
figure('Color',[1 1 1],'Name','f_plot_echogram_maxamp-Fig1');
        subplot(MSUB,NSUB,1)
        imagesc( mat1' );
        try
            title(matnames{1});
        catch
            title('echogram 1');
        end
        subplot(MSUB,NSUB,2)        
        if(doMAX)
            plot( max(mat1,[],1), [1:length(max(mat1,[],1))], '.-k');
            title(['max ' matnames{1}]);
            ylabel('index');
        else
            plot( mode(mat1,1), [1:length(mode(mat1,1))], '.-k');
            title(['mode ' matnames{1}]);
            ylabel('index');
        end
        set (gca,'YDir','reverse')
        subplot(MSUB,NSUB,3)        
        if(doMAX)
            plot( max(mat1,[],1), range, '.-k');
            title(['max ' matnames{1}]);
            ylabel('range (m)');
        else
            plot( mode(mat1,1), range, '.-k');
            title(['mode ' matnames{1}]);
            ylabel('range (m)');
        end
        set (gca,'YDir','reverse')
        
end        
        
% % sphere expected location
%         hold on;
%         plot( spherePos.ampLinmean    ,spherePos.rangemean, 'og','MarkerSize',12,'LineWidth',2);
%         text( spherePos.ampLinmean+0.1,spherePos.rangemean, 'target', 'color',[0, .8, 0]);