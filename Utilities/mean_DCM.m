function R2 = mean_DCM(R)

    for column = 1 : 3
        
        R_cl = unit( mean(R(:,column,:),3) );
        R2(:,column) = R_cl;
        
    end
end