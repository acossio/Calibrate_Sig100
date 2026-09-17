util_plotspherepos

    % Figures
    rowoffset = 30;
    rows2plot = floor(nanmean(spherePos90fm.index))-rowoffset : floor(nanmean(spherePos90fm.index))+rowoffset ;
    
    MSUB = 1;
    NSUB = 4;
    figure('Color',[1 1 1],'Name','(calibrateSig100)-Fig1. Sphere location.');
        subplot(MSUB,NSUB,1)
        imagesc( pcLin' );
        title('pcLin');
        subplot(MSUB,NSUB,2)
        imagesc( pcLog' );
        title('pcLog');
        
        subplot(MSUB,NSUB,3)
        %plot( mode(pcLog,1), [1:size(pcLog,2)], '.-k');  %mode(pcLog)    
        %title('mode(pcLog) by sample')
        %plot( mode(pcLin,1), [1:size(pcLog,2)], '.-k');  %mode(pcLin)
        %title('mode(pcLin) by sample')
        plot( max(pcLin,1), [1:size(pcLog,2)], '.-k');  %max(pcLin)
        title('max(pcLin) by sample')
        set (gca,'YDir','reverse')
        ylim( [1, size(pcLog,2)] );
        
        hold on;
        plot( max(spherePos90fm.ampLin)  ,spherePos90fm.indexmean, 'dg','MarkerSize',12,'LineWidth',2);
        
        subplot(MSUB,NSUB,4)
        plot( mode(pcLog,1), range, '.-k');
        title('mode(pcLog) by range')
        set (gca,'YDir','reverse')
        ylim( [0, max(range)] );
        % sphere expected location
        hold on;
        plot( 10*log10(spherePos90fm.ampLinmean)    ,spherePos90fm.rangemean, 'og','MarkerSize',12,'LineWidth',2);
        text( 10*log10(spherePos90fm.ampLinmean+0.1),spherePos90fm.rangemean, 'target', 'color',[0, .8, 0]);
    
    MSUB = 3;
    NSUB = 1;
    figure('Color',[1 1 1],'Name','(calibrateSig100)-Fig2. Sphere amp.');
        subplot(MSUB,NSUB,1)
        plot( spherePos90fm.range , spherePos90fm.ampLin, '.-k');
        subplot(MSUB,NSUB,2)
        h1 = histogram(spherePos90fm.ampLin);
        h1.Normalization = 'probability';
        h1.NumBins = 15;
%         subplot(MSUB,NSUB,3)
%         h2 = histogram(spherePos90fm.ampLog);
%         h2.Normalization = 'probability';
%         h2.NumBins = 15;

