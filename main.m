% Central Function and point of origin for the program
% It is the function that needs to be called to start the experiment and the one that ends with the experiment  
% The program allows the user to insert variables. This happens in 'InsertParams.m' 

function main(Patient_Name)
    % Add all the directories in the path just in case
    cur_script = mfilename('fullpath');
    cur_dir = cur_script(1:end-length(mfilename));
    cd(cur_dir);
    addpath(genpath(cur_dir));
   
    parameters = StartUp(Patient_Name);
    
    Experiment(parameters);
    
    KbStrokeWait();
    sca;  

    ShutDown(parameters);

    % Remove all the directories from the path
    % rmpath(genpath(cur_dir));
end 