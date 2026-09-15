function [] = f_plot_echograms( mat1, mat2 , range , matnames )
% Requires 4 args: mat1 & mat2 (2D array) , range (1D or 2D array), matnames

mat1 = mat1*1.000;
mat2 = mat2*1.000;
range = range(1,:);

if(isempty(matnames))
    matnames = {'mat1','mat2'};
end

for(indx=1:length(matnames))
    matnames(indx) = regexprep(matnames(indx), '_',' ');
end

MSUB=1; 
NSUB=4;
figure('Color',[1 1 1],'Name','f_plot_echograms-Fig1');
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
        gl = 0.6;
        plot( mode(mat1,1), range, '.--','Color',[gl gl gl]);
        set (gca,'YDir','reverse')
        title(['mode ' matnames{1}])
        hold on;
        plot( max(mat1,[],1), range, '.-k');
        set (gca,'YDir','reverse')
        title(['mode&max ' matnames{1}])
        ylim( [0, max(range)] );  
        
        subplot(MSUB,NSUB,4)
        plot( mode(mat2,1), range, '.--','Color',[gl gl gl]);
        title(['mode ' matnames{2}])
        set (gca,'YDir','reverse')
        hold on;
        plot( max(mat2,[],1), range, '.-k');
        title(['mode&max ' matnames{2}])
        set (gca,'YDir','reverse')
        ylim( [0, max(range)] );
        


% % sphere expected location
%         hold on;
%         plot( spherePos.ampLinmean    ,spherePos.rangemean, 'og','MarkerSize',12,'LineWidth',2);
%         text( spherePos.ampLinmean+0.1,spherePos.rangemean, 'target', 'color',[0, .8, 0]);