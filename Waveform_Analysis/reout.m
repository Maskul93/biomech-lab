% This function caluclates the functional median distance depth (FMD), the
% median distance depth (MAD) and the Robust score (Rscore). 
% FMD is used to find the most representative curve amogn the dataset: the
% waveform with the smallest FMD. 
% MAD is used, together with the FMD, to calculate the Rscore that is used 
% to detect outliers. Waveforms with Rscore exceeding a fixed cut-off value
% (usally between 2 and 3.5) are outliers. 
% Waveforms to be analyzed must be time normalized and stored in a matrix
% where each row correspond to a waveform. 
%%REF : A simple method to choose the most representative stride and detect
%%outliers. Morgan Sangeux,Julia Polak 2014

function [FMD, MAD, Rscore]= reout(A)

median_A = median (A);
den = length(A(1,:));
FMD=[];
for i = 1 : length(A(:,1))
    ass1 = abs(median_A-A(i,:));
    FMD(i,:)= trapz(ass1)/(den-1);
end 


median_FMD = median(FMD);
ass2=[];
for i = 1 : length(FMD)
  ass2(i) = abs(FMD(i)- median_FMD);
end
  MAD = 1.483*median(ass2);
for i = 1 : length(FMD)
  Rscore(i) = (FMD(i) - median_FMD)/MAD;
end 
end 