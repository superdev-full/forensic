%display_synthetic

length_ysound = length(ysound);

figure(synthplot)
plot([fromedge_10, fromedge_10], [-1, 1], 'k')
hold on
fromend = length_ysound - fromedge_10;
plot([fromend, fromend], [-1, 1], 'k')

max_ysound = max([max(ysound), max(-ysound)]);
plot(ysound/max_ysound,'b')

max_synsound = max([max(synsound), max(-synsound)]);
plot(synsound/max_synsound,'r')
axis tight
ylim([-1, 1]);

x_ticks = get(gca, 'XTick');
x_ticks = [fromedge_10, fromedge_10 + x_ticks];
if x_ticks(end) > length_ysound, x_ticks(end) = []; end
set(gca, 'XTick', x_ticks);
x_labels = str2num(get(gca, 'XTickLabel'));
x_labels = (x_labels - fromedge_10) / Fs_10 *1000;
set(gca, 'XTickLabel', num2str(x_labels, '%0.0f'));
hold off

