 % Function called by StartUp.m
% Role of function is to initialize PsychAudio and set up the audio handle for the experiment 
% Parameters: audio_pars (parameters for the audio)
% Return Values: audio_pars (updated parameters for the audio)

function audio_pars = SetUpAudio(audio_pars)
    % Initialize the Sound driver
    InitializePsychSound();

    % Create the handle
    audio_pars.handle = PsychPortAudio('Open');

    % Set configure the audio handle
    PsychPortAudio('Volume', audio_pars.handle, 1); % Ensure PTB Volume matches that of Speaker
    PsychPortAudio('Verbosity',0);                  % Turn off warnings to prevent useless print output
    % PsychPortAudio('SuppressAllWarnings', 1);       % Gets rid of all Warnings
end
