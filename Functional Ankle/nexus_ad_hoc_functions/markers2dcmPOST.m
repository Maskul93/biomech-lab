function [G_R_FOOT, G_R_SHAN, G_R_TABL] = markers2dcmPOST(filename)

%filename = './nexus_csv/S5/POST/S5_FAN_POST1.csv';

x1 = readtable(filename);
x1 = x1(5:end,:);
x = table2array(x1); 
mark_names = x1.Properties.VariableNames;

markers.Table1 = x(:,3:5);
markers.Table2 = x(:,6:8);
markers.Table3 = x(:,9:11);
markers.Table4 = x(:,12:14);

markers.Shank1 = x(:,15:17);
markers.Shank2 = x(:,18:20);
markers.Shank3 = x(:,21:23);
markers.Shank4 = x(:,24:26);

markers.Foot1 = x(:,27:29);
markers.Foot2 = x(:,30:32);
markers.Foot3 = x(:,33:35);
markers.Foot4 = x(:,36:38);

G_R_FOOT = markers2dcm(markers, 'Foot');
G_R_SHAN = markers2dcm(markers, 'Shank');
G_R_TABL = markers2dcm(markers, 'Table');

end