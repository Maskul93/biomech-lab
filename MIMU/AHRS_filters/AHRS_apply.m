function q = AHRS_apply(D, type, Fs, q0)

% Load Data
acc = D.acc;
gyr = D.gyr;
mag = D.mag;

% Global Variables
N = length(acc);
q = zeros(N, 4);

switch type
    
    case 'JustaAHRSPure'
        AHRS = JustaAHRSPure();
        AHRS.SamplePeriod = 1 / Fs;
        
    case 'JustaAHRSPureFast'
        AHRS = JustaAHRSPureFast();
        AHRS.SamplePeriod = 1 / Fs;
        
    case 'JustaAHRSPureFastConstantCorr'
        AHRS = JustaAHRSPureFastConstantCorr();
        AHRS.SamplePeriod = 1 / Fs;
        
    case 'JustaAHRSPureFastLinearCorr'
        AHRS = JustaAHRSPureFastLinearCorr();
        AHRS.SamplePeriod = 1 / Fs;
        
    case 'MadgwickAHRS'
        AHRS = MadgwickAHRS();
        AHRS.SamplePeriod = 1 / Fs;
        
    case 'MadgwickAHRSclanek'
        AHRS = MadgwickAHRSclanek();
        AHRS.SamplePeriod = 1 / Fs;
        
    case 'Valenti_AHRS'
        AHRS = Valenti_AHRS();
        AHRS.SamplePeriod = 1 / Fs;
        
    case 'Wilson_Madgwick_AHRS'
        AHRS = Wilson_Madgwick_AHRS();
        AHRS.SamplePeriod = 1 / Fs;
        
    case 'YoungSooSuh_AHRS'
        AHRS = YoungSooSuh_AHRS();
        AHRS.SamplePeriod = 1 / Fs;
        
    case 'AdmirallWilsonAHRS'
        AHRS = AdmirallWilsonAHRS();
        AHRS.SamplePeriod = 1 / Fs;
        
    case 'JinWuKF_AHRSreal2'
        AHRS = JinWuKF_AHRSreal2();
        AHRS.SamplePeriod = 1 / Fs;
    
    case 'Madgwick2010'
        AHRS = MadgwickAHRS();
        AHRS.SamplePeriod = 1 / Fs;   
             
end

% If required, get initial quaternion using TRIAD
if q0 == 1
    AHRS.Quaternion = get_q0(acc, mag);
end

% Attitude-Heading Estimation

for t = 1:N
    
    gyr_t = gyr(t,:);
    mag_t = mag(t,:);
    acc_t = acc(t,:);
    
    if mean(mag_t) == 0
        AHRS.UpdateIMU(gyr_t,acc_t);
    else
        AHRS.Update(gyr_t,acc_t,mag_t);
    end
    
    q(t, :) = AHRS.Quaternion;
    
end

end