%% Plot DCM
function plot_DCM(R)

figure
array_plot(R(:,1), 'b', 1.2);
hold;
array_plot(R(:,2), 'r', 1.2);
array_plot(R(:,3), 'k', 1.2);

legend('X', 'Y', 'Z');
title('DCM 3D-plot');

end