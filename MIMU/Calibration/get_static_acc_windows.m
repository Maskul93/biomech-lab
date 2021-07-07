% ## ---- get_static_acc_windows ---- ## %
% To get the boundaries of each static portion
function x = get_static_acc_windows(acc)
    N = length(acc);
    x = [];
    figure('units','normalized','position', [0.1 0.1 0.8 0.8]);
    plot(acc);
    title ('Select by clicking on interval beginning and end all the available static conditions. Double click to exit...')
    xlabel('sample'); ylabel('Acceleration, g (MEMO convert if it is)')
    while 1
        [x1,y] = ginput(2);
        if x1(1)==x1(2)
            break
        end
        x1 = round(x1);
        x = [x x1];
    end
    close
end