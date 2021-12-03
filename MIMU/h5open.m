function MIMU = h5open(f_name)
%% H5OPEN: open a .h5 file acquired with the OPAL system and store all the 
% relevant information into a struct.
% NOTE: It works with v5 .h5 files only, as this function was developed for
% the DIADORA Project.
% ----------------------------------------------------------------------- %
% INPUT: f_name (character/string) --> Path to .h5 file to be processed
% OUTPUT: MIMU (struct) --> Structure containing all the sensors data (see
% LEGEND)
% ----------------------------------------------------------------------- %
% Author: Guido Mascia, MSc, PhD student at University of Rome "Foro
% Italico" -- g.mascia@studenti.uniroma4.it
% Created: 03/12/2021
% Last modified: 03/12/2021
% ----------------------------------------------------------------------- %

% -- LEGEND -- %
% % Sensor Name : 	Sensors/XXXXX/Configuration/ --> Label 0
% % Acc         :	Sensors/XXXXX/Accelerometer
% % Gyr         :	Sensors/XXXXX/Gyroscope
% % Mag         :	Sensors/XXXXX/Magnetometer
% % Bar         :	Sensors/XXXXX/Barometer
% % Quat	    :	Processed/XXXXX/Orientation
% % Fs          :	Sensors/XXXXX/Configuration/ --> Sample Rate
% % Timestamp   :	Sensors/XXXXX/Time
% -----------------------------------------------------------------------%

%% -- Get Sensors IDs -- %%
sensors = h5info(f_name, '/Sensors');
sensors_IDs = {sensors.Groups(:).Name};
% ----------------------- %

for mn = 1 : length(sensors_IDs)
    %% -- Store Fields -- %%
    Acc = h5read(f_name, [char(sensors_IDs(mn)) '/Accelerometer'])';
    Gyr = h5read(f_name, [char(sensors_IDs(mn)) '/Gyroscope'])';
    Mag = h5read(f_name, [char(sensors_IDs(mn)) '/Magnetometer'])';
    Bar = h5read(f_name, [char(sensors_IDs(mn)) '/Barometer']);
    Timestamp = h5read(f_name, [char(sensors_IDs(mn)) '/Time']);
    Fs = h5readatt(f_name, [char(sensors_IDs(mn)), '/Configuration/'], 'Sample Rate');

    % Quat is in a different field (Processed/XXXXXX)
    tmp_ID = strsplit(char(sensors_IDs(mn)), '/');
    ID = tmp_ID(end);
    Quat = h5read(f_name, ['/Processed/', char(ID), '/Orientation'])';
    % ----------------------------------------------- %

    %% -- Get sensor label -- %%
    mon_name = h5readatt(f_name, [sensors.Groups(mn).Name '/Configuration'], 'Label 0');

    % Correct for bad naming
    label = [];
    cmp = mon_name(end);
    for k = 1 : length(mon_name)
        if mon_name(k) ~= cmp
            label = [label, mon_name(k)];
        end
    end
    % Remove spacings
    label(label == ' ') = [];

    %% Store into a structure with the label of each sensor -- %%
    MIMU.(label).Fs = Fs;
    MIMU.(label).Acc = Acc;
    MIMU.(label).Gyr = Gyr;
    MIMU.(label).Mag = Mag;
    MIMU.(label).Bar = Bar;
    MIMU.(label).Quat = Quat;
    MIMU.(label).Timestamp = Timestamp;
end

