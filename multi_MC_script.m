addpath(genpath('\\engnas.bu.edu\users\s\s\sshayk\My Documents\MATLAB\SpikeTriggeredPlots'))
mc_file = '\\engnas.bu.edu\users\s\s\sshayk\My Documents\MATLAB\analyze_voltage\MC_file.txt';
L = readlines(mc_file);

for n = 1:length(L)
    curstr = L{n};
    k = strfind(curstr,'\');
    k = k(end);
    MC_and_extract(curstr(1:(k-1)),curstr((k+1):end))
end
