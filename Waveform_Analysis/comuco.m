% % This function caluclates the CMC for a set of wavefroms. 
% % Wavefrom must be time normalized and stored in a matrix where each row correspond to a wavefrom. 


function [cmc]=comuco(A)
Num = 0;
    Den = 0;
    Num1 = 0; 
    Den1 = 0;
    Num2 = 0;
    Den2 = 0;
    Yswf = A;
    Ysf= mean(A);
    Ys = mean2(A);
    for z= 1 : size(Yswf,1)
         for F = 1:size(Yswf,2)
             Temp1= ((Yswf(z,F)-Ysf(1,F))^2);
             Num1 = Num1+Temp1;
             Temp2= ((Yswf(z,F)-Ys)^2);
             Num2 = Num2+Temp2;
         end 
    end
    Den1 = size(Yswf,2)*(size(Yswf,1)-1);
    Den2 = size(Yswf,1)* size(Yswf,2)-1;
    Num = Num1/Den1;
    Den = Num2/Den2;
    cmc = sqrt(1-(Num/Den));

end