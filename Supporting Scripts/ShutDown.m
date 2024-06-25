% Function called by: main.m
% Role of function is to terminate anything lingering, since this is the end of the experiment 
% Parameters: parameters (to look for things to end)
% Return Values: None

function ShutDown(parameters)
    % PsychPortAudio('Close', parameters.audio.handle);
    close all;
end

