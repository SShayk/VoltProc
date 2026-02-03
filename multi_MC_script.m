mc_file = '\\engnas.bu.edu\users\s\s\sshayk\My Documents\MATLAB\analyze_voltage\MC_file.txt';
if exist(mc_file,'file')
    addpath(genpath('\\engnas.bu.edu\users\s\s\sshayk\My Documents\MATLAB\SpikeTriggeredPlots'))
else
   mc_file =  '/net/engnas/Users/s/s/sshayk/My Documents/MATLAB/analyze_voltage/MC_file.txt';
   addpath(genpath('/net/engnas/Users/s/s/sshayk/My Documents/MATLAB/SpikeTriggeredPlots'))
end

L = readlines(mc_file);

for n = 1:length(L)
    curstr = L{n};
    k = strfind(curstr,'\');cars
    if isempty(k)
        k = strfind(curstr,'/');
    end
    k = k(end);
    MC_and_extract(curstr(1:(k-1)),curstr((k+1):end))
end
