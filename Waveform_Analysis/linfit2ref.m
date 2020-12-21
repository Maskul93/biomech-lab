% % This function campares set of waveforms or a single wavefrom to a reference waveform. In this case look at a1 and a0;(Ref2)
% % Wavefroms must be time nomalized.
% % (A)Waveforms must be stored in a matrix where each row correspond to a waveform. if single wavefrom = row vector
% % (B)Reference wavefrom is a row vector
% % R^2 = R2 = strength of linear relationship ( if R^2 > 0.5 the assumption of linearity can be considered valid) (Ref 1&2)
% % SD_a0 = offset variability
% % SD_a1 = amplitude scaling factor variability
% % a0 = mean offset
% % a1 = mean amplitude scaling factor
% % Ref1 = Assessment of Waveform Similarity in Clinical Gait Data:The Linear Fit Method (Iosa, 2014)
% % Ref2 = How to choose and interpret similarity indices to quantify the variability in gait joint kinematics (Di Marco, 2018)

function [R2,a1,a0,SD_a1,SD_a0]= linfit2ref(A,B)
Num = 0;
Den = 0;
Num1 = 0;
Den1 = 0;

if length(A(:,1))>1
Pref = B;
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
    a0 = mean(Temp_a0);
    a1 = mean(Temp_a1);
else
    Pref = B;
    M_Pref = mean(Pref);
    Pa = A;
    M_Pa = mean(Pa);
    for g = 1:length(A(1,:))
        TempNum = (Pref(g)-M_Pref)*(Pa(g)- M_Pa);
        Num = Num + TempNum;
        TempDen = (Pref(g)- M_Pref)^2;
        Den = Den + TempDen;
    end
    a1 = Num/Den;
    a0 = M_Pa - a1 * M_Pref;
    for g = 1:length(A(1,:))
        TempNum1 = (a0 + a1*Pref(g) - M_Pa)^2;
        Num1 = Num1+TempNum1;
        TempDen1 = (Pa(g) - M_Pa)^2;
        Den1 = Den1+TempDen1;
    end
        R2 = Num1/Den1;
end