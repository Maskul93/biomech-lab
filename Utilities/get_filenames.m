function files = get_filenames(path)
%% GET FILENAMES
% This function gets a cell array containing the list of files in the
% selected directory. 
% -------------------------------------------------------------------------
%   · INPUT:
%       - path = 1 x N (string), i.e. the directory one wats to know the
%       files within.
%   · OUTPUT:
%       - files = 1 x M (cell), i.e. the filenames within the directory.
% -------------------------------------------------------------------------
% - AUTHOR: Guido Mascia, MSc, PhD student at University of Rome "Foro
% Italico", g.mascia@studenti.uniroma4.it
% - CREATION DATE: 20/12/2020
% - LAST MODIFIED: 08/01/2021
% -------------------------------------------------------------------------
    x = dir(path);
    
    for i = 1 : length(x) - 2
        files{i} = x(i+2).name;
    end

end