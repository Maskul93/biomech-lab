% % This function campares set of waveforms to their mean. In this case look at SD_a1 and SD_a0;(Ref2)
% % Wavefroms must be time nomalized.
% % Waveforms must be stored in a matrix where each row correspond to a waveform; (usable both for intra and inter subject consistency)
% % R^2 = R2 = strength of linear relationship ( if R^2 > 0.5 the assumption of linearity can be considered valid) (Ref 1&2)
% % SD_a0 = offset variability
% % SD_a1 = amplitude scaling factor variability
% % m_a0 = mean offset
% % m_01 = mean amplitude scaling factor
% % Ref1 = Assessment of Waveform Similarity in Clinical Gait Data:The Linear Fit Method (Iosa, 2014)
% % Ref2 = How to choose and interpret similarity indices to quantify the variability in gait joint kinematics (Di Marco, 2018)


function [R2,SD_a1,SD_a0,m_a1,m_a0]= linfit2mean(A)
Num = 0;
Den = 0;
Num1 = 0;
Den1 = 0;

Pref = mean(A);
M_Pref = mean(Pref);
for z = 1:length(A(:,1))
    Pa = A(z,:);
    M_Pa = mean(Pa);
    for g = 1:length(A(1,:))
    TempNum = (Pref(g)-M_Pref)*(Pa(g)- M_Pa);
    Num = Num + TempNum;
    TempDen = (Pref(g)- M_Pref)^2;
    Den = Den + TempDen;
    end
    Temp_a1(z,1) = Num/Den;
    Temp_a0(z,1) = M_Pa - Temp_a1(z,1) * M_Pref;
end
for z = 1:length(A(:,1))
    Pa = A(z,:);
    M_Pa = mean(Pa);    
    for g = 1:length(A(1,:))
        TempNum1 = (Temp_a0(z,1) + Temp_a1(z,1)*Pref(g) - M_Pa)^2;
        Num1 = Num1+TempNum1;
        TempDen1 = (Pa(g) - M_Pa)^2;
        Den1 = Den1+TempDen1;
    end
        Temp_R2(z,1) = Num1/Den1;
end 
    R2 = mean(Temp_R2);
    SD_a0 = std(Temp_a0);
    SD_a1 = std(Temp_a1);
    m_a0 = mean(Temp_a0);
    m_a1 = mean(Temp_a1);
end
