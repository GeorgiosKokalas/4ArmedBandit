% Function called by: main.m
% Role of function is to begin the program, initiate parameters, start the Screen and Audio  
% Returns all the parameters that might be needed for the program to run the trials  
% Parameters: 
%   - Patient_Name
% Return Values: 
%   - parameters (paramters to be used for the experiment)

function parameters = StartUp(Patient_Name)
    % Clear the workspace and the screen
    sca;
    close all;
    clc;
    
    % Generate the parameters that will be used in the experiment
    parameters = InsertParams(Patient_Name);
    
    % The saving Directory probably does not exist, so create it.
    disp(parameters.output_dir);
    if ~exist(parameters.output_dir, "dir"); mkdir(parameters.output_dir); end
    
    % Initialize the Screen
    parameters.screen = SetUpScreen(parameters.screen, parameters.text.font);

    % Initialize the Sound
    % parameters.audio = struct;
    % parameters.audio = SetUpAudio(parameters.audio);
end