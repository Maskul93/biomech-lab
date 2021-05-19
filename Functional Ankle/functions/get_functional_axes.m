function a_F = get_functional_axes(D, Fs)
%% GET-FUNCTIONAL AXES
% Compute the main Ankle functional axis starting from functional
% calibration gyroscope measurements. 

% INPUT:    
%   · D (struct): structure containing the foot structure during the 
%     functional calibration trial.
%   · Fs (scalar): MIMU sampling frequency.
% OUTPUT:   
%   · a_F = Ankle main plantar-dorsiflexion axis computed as the unitary 
%   mean angular velocity vector;
%   
% ------------------------------------------------------------------------
% AUTHOR: Guido Mascia, MSc, PhD student at Univeristy of Rome "Foro
% Italico" (g.mascia@studenti.uniroma4.it)
% CREATED: 26/02/2020
% LAST MODIFIED: 19/03/2021
% ------------------------------------------------------------------------

% Filtering Parameters
[b,a] = butter(4,2/(Fs/2), 'low');

% Filtered Foot Signal
FootGyroFilt = filtfilt(b,a,D.gyr);

% Threshold computation as the maximum of maxima
GyroSel_ft = FootGyroFilt;
threshold = max(max(GyroSel_ft));
threshold = threshold/2.5;

% Check which is the main functional axis
maximum = max(GyroSel_ft);
[maximum2, column] = max(maximum);

% Select the the angular velocity frames above the threshold only
selected = GyroSel_ft(:,column) > threshold;
GyroSel2_ft = GyroSel_ft(selected,:);

GyroSel2_norm_ft = zeros(size(GyroSel2_ft));

for i = 1 : 3
    GyroSel2_norm_ft(:,i) = GyroSel2_ft(:,i)./magna(GyroSel2_ft);
end

a_F = unit(mean(GyroSel2_norm_ft));

end