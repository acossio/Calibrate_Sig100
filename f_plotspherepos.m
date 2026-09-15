function [] = f_plotspherepos( echogram, range, spherePos ) 
% util_plotspherepos

    % Figures
    rowoffset = 30;
    rows2plot = floor(nanmean(spherePos.index))-rowoffset : floor(nanmean(spherePos.index))+rowoffset ;
    
    MSUB = 1;
    NSUB = 4;
    figure('Color',[1 1 1],'Name','(calibrateSig100)-Fig1. Sphere location.');
        subplot(MSUB,NSUB,1)
        imagesc( echogram' );
        title('echogram');
        subplot(MSUB,NSUB,2)
        imagesc( echogram' );
        title('echogram');
        
        subplot(MSUB,NSUB,3)
        %plot( mode(echogram,1), [1:size(echogram,2)], '.-k');  %mode(echogram)    
        %title('mode(echogram) by sample')
        %plot( mode(echogram,1), [1:size(echogram,2)], '.-k');  %mode(echogram)
        %title('mode(echogram) by sample')
        plot( max(echogram,1), [1:size(echogram,2)], '.-k');  %max(echogram)
        title('max(echogram) by sample')
        set (gca,'YDir','reverse')
        ylim( [1, size(echogram,2)] );
        
        hold on;
        plot( max(spherePos.ampLin)  ,spherePos.indexmean, 'dg','MarkerSize',12,'LineWidth',2);
        
        subplot(MSUB,NSUB,4)
        plot( mode(echogram,1), range, '.-k');
        title('mode(echogram) by range')
        set (gca,'YDir','reverse')
        ylim( [0, max(range)] );
        % sphere expected location
        hold on;
        plot( 10*log10(spherePos.ampLinmean)    ,spherePos.rangemean, 'og','MarkerSize',12,'LineWidth',2);
        text( 10*log10(spherePos.ampLinmean+0.1),spherePos.rangemean, 'target', 'color',[0, .8, 0]);
    
    MSUB = 3;
    NSUB = 1;
    figure('Color',[1 1 1],'Name','(calibrateSig100)-Fig2. Sphere amp.');
        subplot(MSUB,NSUB,1)
        plot( spherePos.range , spherePos.ampLin, '.-k');
        subplot(MSUB,NSUB,2)
        h1 = histogram(spherePos.ampLin);
        h1.Normalization = 'probability';
        h1.NumBins = 15;
%         subplot(MSUB,NSUB,3)
%         h2 = histogram(spherePos.ampLog);
%         h2.Normalization = 'probability';
%         h2.NumBins = 15;

