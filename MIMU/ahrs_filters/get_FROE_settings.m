
function settings = get_FROE_settings()

% Default Values -----------------------------------------------------------------------
settings.T = 1 / 100;                                % Default: Fs = 100 Hz
settings.init_q_nb = [1 0 0 0];                      % Default: 0 degrees on all axes
settings.sigmaAcc = 0.002254 * ones(3,1);            % Default: Blue-Trident interim specs
settings.sigmaGyr = 0.000261 * ones(3,1);            % Default: Blue-Trident interim specs
settings.sigmaMag = 0.01 * ones(3,1);                % Default: From FROE paper
settings.g = [0; -9.82; 0];                          % Default: Gravity on Y axis
settings.estGyrBias = 0;                             % Default: Does not estimate Gyroscope Bias
settings.estimateMagneticField = 0;                  % Default: Does not estimate Magnetic Field
settings.DipAngle = 58;                              % Default: Rome Dip Angle
settings.mn = [cos(settings.DipAngle), ...           % Default: Rome Magnetic Field
    0, -sin(settings.DipAngle)];
% ---------------------------------------------------------------------------------------

end
