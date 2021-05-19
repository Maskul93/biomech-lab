function [G_R_FOOT, G_R_SHAN, G_R_STEP] = markers2dcmSTEP(filename)



x1 = readtable(filename);
%x1 = x1(5:end,:);
x = table2array(x1); 
mark_names = x1.Properties.VariableNames;

markers.Step1 = [x(1:100,2:3) x(1:100,4)];
markers.Step2 = [x(1:100,5:6) x(1:100,7)];
markers.Step3 = [x(1:100,8:9) x(1:100,10)];

markers.Shank1 = [x(1:100,11:12) x(1:100,13)];
markers.Shank2 = [x(1:100,14:15) x(1:100,16)];
markers.Shank3 = [x(1:100,17:18) x(1:100,19)];
markers.Shank4 = [x(1:100,20:21) x(1:100,22)];

markers.Foot1 = [x(1:100,23:24) x(1:100,25)];
markers.Foot2 = [x(1:100,26:27) x(1:100,28)];
markers.Foot3 = [x(1:100,29:30) x(1:100,31)];
markers.Foot4 = [x(1:100,32:33) x(1:100,34)];

G_R_FOOT = markers2dcm(markers, 'Foot');
G_R_SHAN = markers2dcm(markers, 'Shank');
G_R_STEP = markers2dcm(markers, 'Step');

end