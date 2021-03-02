function D = get_trial(file)

    x = readtable(file);
    D.RS.acc = x{:,1:3};
    D.RS.gyr = x{:,4:6};
    D.RS.mag = x{:,7:9};
    
    D.RF.acc = x{:,10:12};
    D.RF.gyr = x{:,13:15};
    D.RF.mag = x{:,16:18};
    
    D.LS.acc = x{:,19:21};
    D.LS.gyr = x{:,22:24};
    D.LS.mag = x{:,25:27};
        
    D.LF.acc = x{:,28:30};
    D.LF.gyr = x{:,31:33};
    D.LF.mag = x{:,34:36};

end
