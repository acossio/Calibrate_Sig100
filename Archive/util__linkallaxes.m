% util__linkallaxes
% % link all axes in figure (for zooming in on same region in subplots)
allAxesInFigure = findall(gcf,'type','axes');
linkaxes( allAxesInFigure, 'xy');