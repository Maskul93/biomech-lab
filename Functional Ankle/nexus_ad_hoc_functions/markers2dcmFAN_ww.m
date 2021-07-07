function [G_R_FOOT, G_R_SHAN] = markers2dcmFAN_ww(filename)

x1 = readtable(filename);
x = table2array(x1); 

markers.Shank1 = [-x(:,3:4) x(:,5)];
markers.Shank2 = [-x(:,6:7) x(:,8)];
markers.Shank3 = [-x(:,9:10) x(:,11)];
markers.Shank4 = [-x(:,12:13) x(:,14)];

markers.Foot1 = [-x(:,15:16) x(:,17)];
markers.Foot2 = [-x(:,18:19) x(:,20)];
markers.Foot3 = [-x(:,21:22) x(:,23)];
markers.Foot4 = [-x(:,24:25) x(:,26)];

G_R_FOOT = markers2dcm(markers, 'Foot');
G_R_SHAN = markers2dcm(markers, 'Shank');

end