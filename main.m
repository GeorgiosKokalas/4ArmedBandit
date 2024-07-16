% Central Function and point of origin for the program
% It is the function that needs to be called to start the experiment and the one that ends with the experiment  
% The program allows the user to insert variables. This happens in 'InsertParams.m' 

function main(Patient_Name)
    if ~exist("Patient_Name","var"); Patient_Name = 'TEST'; end

    % Add all the directories in the path just in case
    cur_script = mfilename('fullpath');
    cur_dir = cur_script(1:end-length(mfilename));
    cd(cur_dir);
    addpath(genpath(cur_dir));
    
    % Call the task Start Event 
     CreateEvent("taskStart");
    
    % Store the task Start Event

    % Start up the experiment and provide the parameters that will be used in the experiment       
    parameters = StartUp(Patient_Name);
    
    % Run the experiment
    Experiment(parameters);
    
    KbStrokeWait();
    sca;  
    
    % Store the saves
    CreateEvent("taskEnd")

    pool = gcp('nocreate');
    if ~isempty(pool); delete(pool); end

    ShutDown(parameters);
    

    % Remove all the directories from the path
    % rmpath(genpath(cur_dir));
end 