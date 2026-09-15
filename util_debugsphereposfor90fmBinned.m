
%% Debug f_find_spherepos for 90fmBinned
close all;

doFORCERANGEPOS = false;

% Compare sizes of Range array and echogram
myfields = fieldnames( echogramiq90fm );
myfield  = myfields{ 4 };

if( size(Range90fm,2) ~= size(echogramiq90fm.(myfield),2) )
    %% Force size of Range array to match echogram
    %     Range90fm = Range90fm(1: size( echogramiq90fm.(myfield) ,2) );      
end

if(doFORCERANGEPOS)
    Range90fmPositive = Range90fm(Range90fm>=0);
else
    Range90fmPositive = Range90fm;
end

if( length(Range90fmPositive) ~= size(echogramiq90fm.(myfield),2) )
    %% Force size of Range array to match echogram
    %   Range90fm = Range90fm(1: size( echogramiq90fm.(myfield) ,2) );  
    range = Range90fmPositive(1: size(echogramiq90fm.(myfield),2) );
else
    range = Range90fmPositive;
end

%%
figure('Color',[0.7 1 1], 'Position',[100 100 1200 700]);

echogramraw    = echogramiq90fm.(myfield);
echogrambinned = echogramiq90fmBinned.(myfield);

MSUB=1;
NSUB=8;
subi=0;

%%
subi=subi+1;
subplot(MSUB,NSUB,subi)
imagesc( pcLog' );
title( 'pcLog' );
%
subi=subi+1;
subplot(MSUB,NSUB,subi)
imagesc( echogramraw' );
title( myfield );
%
subi=subi+1;
subplot(MSUB,NSUB,subi)
imagesc( echogrambinned' );
title( 'echogrambinned' );
%%
subi=subi+1;
subplot(MSUB,NSUB,subi)
plot( max(pcLog,[],1), [ 1 : size(pcLog,2)], '.-r');
title('max(pcLog)');
ylim([ 1 , size(pcLog,2)]);
set (gca,'YDir','reverse')
%
subi=subi+1;
subplot(MSUB,NSUB,subi)
plot( max(pcLog,[],1), rangePC, '.-r');
title(['max(pcLog) vs rangePC']);
ylabel('range (m)');
set (gca,'YDir','reverse')
ylim([min(rangePC), max(rangePC)]);
%
subi=subi+1;
subplot(MSUB,NSUB,subi)
plot( max(echogramraw,[],1), [ 1 : size(echogramraw,2)], '.-k');
title('max(echogram)');
ylim([ 1 , size(echogramraw,2)]);
set (gca,'YDir','reverse')
%
subi=subi+1;
subplot(MSUB,NSUB,subi)
plot( max(echogramraw,[],1), range, '.-k');
title(['max(echo) vs RangeGT0']);
ylabel('range (m)');
set (gca,'YDir','reverse')
ylim([min(range), max(range)]);
%
subi=subi+1;
subplot(MSUB,NSUB,subi)
plot( max(echogrambinned,[],1), Range90fmBinned, '.-k');
title(['max(ebinned) vs RangeBinned']);
ylabel('Range90fmBinned (m)');
set (gca,'YDir','reverse')
% ylim([min(Range90fmBinned), max(Range90fmBinned)]);
ylim([min(range), max(range)]);
