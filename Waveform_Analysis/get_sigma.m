%% GET SIGMA
% ------------------------------------------------------------------------
% DESCRIPTION: this function computes the amount of variability of a given
% set of curves, according to what proposed in [1]. 
% ------------------------------------------------------------------------
% INPUT: 
%     - x (T x p): Data for which variability will be computed. T is the
%     number of samples, whereas p is the number of signals. Remember that
%     T must be equal for all the analyzed signals (i.e. signals must be
%     time-normalized (consider using "ScaleTime" function to do that).
% ------------------------------------------------------------------------
% OUTPUT:
%     - sigma_source (scalar): Variability for the analyzed kinematic
%     variable as in [1].
% ------------------------------------------------------------------------
% AUTHOR: Guido Mascia, PhD student at University of Rome "Foro Italico" 
% EMAIL: g.mascia@studenti.uniroma4.it -- mascia.guido@gmail.com
% CREATED: 18.03.2022
% LAST MODIFIED: 18.03.2022
% ------------------------------------------------------------------------
% REFERENCES:
% [1] Schwartz, M. H., Trost, J. P., & Wervey, R. A. (2004). Measurement 
% and management of errors in quantitative gait data. In Gait & Posture 
% (Vol. 20, Issue 2, pp. 196–203). Elsevier BV. 
% https://doi.org/10.1016/j.gaitpost.2003.09.011
% ------------------------------------------------------------------------

function sigma_source = get_sigma(x)
    T = size(x, 1); % Number of samples
    p = size(x, 2); % Number of trials
    x_mean = mean(x,2); % Compute the mean curve among the selected p
        
    for j = 1 : p
        
        num = 0;
        
        % Sum of Square differences from the mean curve
        for i = 1 : T
            num = num + (x_mean(i) - x(i,j))^2;
        end
        
        % Mean Sum of Square differences from the mean curve
        y_sq(j) = num / T;
        
    end
    
    % Eq. 2.4 of [1]
    sigma_source = sqrt( sum(y_sq) / (p - 1) );     
end