clear

root_path = '/run/media/maskul/Ardisco/FAN 2021/';
%root_path = './';
day = 'Multi_FAN_15_01/Functional_Ankle/';
subjects = {'S1', 'S2', 'S3', 'S4'};
sessions = {'FAN', 'TASK'}; 

files = dir([root_path, day, subjects{2}, '/', sessions{1}, '/*.c3d']);

for i = 1 %: length(files)
    current_file = files(i).name;
    H = btkReadAcquisition([root_path, day, subjects{2}, '/', sessions{1}, '/' current_file]);
    D = btkGetMarkers(H);
    
end