function [G_R_FOOT, G_R_SHAN, G_R_TABL] = markers2dcmPOST(filename)

%filename = './nexus_csv/S5/POST/S5_FAN_POST1.csv';

x1 = readtable(filename);
x1 = x1(5:end,:);
x = table2array(x1); 

markers.Table1 = [-x(:,3:4) x(:,5)];
markers.Table2 = [-x(:,6:7) x(:,8)];
markers.Table3 = [-x(:,9:10) x(:,11)];
markers.Table4 = [-x(:,12:13) x(:,14)];

markers.Shank1 = [-x(:,15:16) x(:,17)];
markers.Shank2 = [-x(:,18:19) x(:,20)];
markers.Shank3 = [-x(:,21:22) x(:,23)];
markers.Shank4 = [-x(:,24:25) x(:,26)];

markers.Foot1 = [-x(:,27:28) x(:,29)];
markers.Foot2 = [-x(:,30:31) x(:,32)];
markers.Foot3 = [-x(:,33:34) x(:,35)];
markers.Foot4 = [-x(:,36:37) x(:,38)];

G_R_FOOT = markers2dcm(markers, 'Foot');
G_R_SHAN = markers2dcm(markers, 'Shank');
G_R_TABL = markers2dcm(markers, 'Table');

end