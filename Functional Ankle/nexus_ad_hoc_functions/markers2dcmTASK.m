function [G_R_FOOT, G_R_SHAN] = markers2dcmTASK(filename)

%filename = './nexus_csv/S5/TASK/S5_GAIT1.csv';

x1 = readtable(filename);
x = table2array(x1); 

markers.Shank1 = x(:,3:5);
markers.Shank2 = x(:,6:8);
markers.Shank3 = x(:,9:11);
markers.Shank4 = x(:,12:14);

markers.Foot1 = x(:,15:17);
markers.Foot2 = x(:,18:20);
markers.Foot3 = x(:,21:23);
markers.Foot4 = x(:,24:26);

G_R_FOOT = markers2dcm(markers, 'Foot');
G_R_SHAN = markers2dcm(markers, 'Shank');

end