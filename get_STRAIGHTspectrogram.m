function [I, alpha, duration] = get_STRAIGHTspectrogram(STRAIGHT_input)
% Usage: plot_STRAIGHTspectrogram(STRAIGHT_input)
% Example: plot_STRAIGHTspectrogram(bb)
%
% last modified 03-09-17
% apj

x               = STRAIGHT_input.synthStructure.synthesisOut;
x = downsample(x,2);
window          = 512*1.5; % blackmanharris(512*2);
noverlap        = 400*1.5; % 256*1.75;
nfft            = 512*1.5; % 1024;
fs              = STRAIGHT_input.synthStructure.samplingFrequency/2;
[~, ~, ~, P]    = spectrogram(x, window, noverlap , nfft, fs, 'yaxis');
col_lims        = [-80 -30];
duration        = length(x)/fs;

figure('visible','off');
imagesc(10*log10(P),col_lims)
colormap(hot)
cmap = colormap;
set(gca,'Ydir','Normal', 'YLim', [0 100])
% set(gca, 'Position', get(gca, 'Position').*[1 1 1.05 1.25])

% keep only bottom quarter of freq. range (y-axis)
M = getimage;
M = flipud(M(1:round(length(M(:,1,1))*.5),:));
close(gcf)

M = imresize(M,[332,366]);

% find bottom 33% of color axis and make transparent
% thresh = min(M(:))+(diff([min(M(:)) max(M(:))])/3);
thresh = min(col_lims);
alpha = zeros(size(M));
alpha(M>thresh) = 1;

I = mat2im(M,cmap,col_lims);
% h = imshow(I);
% set(h, 'AlphaData', alpha);
end