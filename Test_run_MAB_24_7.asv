function run_MAB_24_7(taskRunNum,BR_connect)
%run_MAB_24_7(1,1)

%taskrunNum is number of times this participant has run art nav.
%BR_connect is whether to start a blackrock recording


if nargin==1
    BR_connect = 1;
end

addpath(genpath('C:\Users\EMU - Behavior\Documents\MATLAB\Behavioral Tasks\BH\4MAB'))
taskDir = 'C:\Users\EMU - Behavior\Documents\MATLAB\Behavioral Tasks\BH\4MAB';
cd(taskDir)

computerMaxVolume()


%start blackrock
if BR_connect
    [emuRunNum,sub_label] = getNextLogEntry();
    savefname = sprintf('EMU-%04d_subj-%s_task-4MAB_run-%02d',emuRunNum,sub_label,taskRunNum);
    TaskComment('start',savefname);
    
else
    sub_label = 'TEST';
end


%% This is where you call the function to run the task
%run task OR maybe you can directly call on the main function
main(sub_label)
%Move Files to PatientData Folder
moveFilesToPatientData(sub_label,taskRunNum)

if BR_connect
    TaskComment('stop',savefname); 
end

%Maybe code up some escape key that allows you to stop the game? OR maybe
%it doesn't matter
%if BR_connect
%TaskComment(savefname,'kill')
%end

%disp('Dont forget to move files to subject directory!! also update the code so this happens automatically')
rmpath(genpath('C:\Users\EMU - Behavior\Documents\MATLAB\Behavioral Tasks\BH\4MAB'))
end


%run 4mab block, could also be practice
% function Run_4ArmedBandit() 
% main
% end

% function moveFilesToPatientData(sub_label,taskRunNum)
% desktopDir = 'C:\\Users\EMU - Behavior\Desktop\';
% saveDir = fullfile(userpath,'PatientData',sub_label,'ArtNav',['session_',num2str(taskRunNum)]);
% if ~exist(saveDir,'dir')
%     mkdir(saveDir)
% end
% 
% positionFilesDir = dir(pwd);
% positionFilesIdx = contains({positionFilesDir.name},'Position');
% positionFiles = {positionFilesDir(positionFilesIdx).name};
% for i = 1:length(positionFiles)
%     movefile(fullfile(pwd,positionFiles{i}), fullfile(saveDir,positionFiles{i}));
% end
% 
% rotationFilesDir = dir(pwd);
% rotationFilesIdx = contains({rotationFilesDir.name},'Rotation');
% rotationFiles = {rotationFilesDir(rotationFilesIdx).name};
% for i = 1:length(rotationFiles)
%     movefile(fullfile(pwd,rotationFiles{i}), fullfile(saveDir,rotationFiles{i}));
% end
% 
% keyPressFilesDir = dir(desktopDir);
% keyPressFilesIdx = contains({keyPressFilesDir.name},'KeyPress');
% keyPressFiles = {keyPressFilesDir(keyPressFilesIdx).name};
% for i = 1:length(keyPressFiles)
%     movefile(fullfile(desktopDir,keyPressFiles{i}), fullfile(saveDir,keyPressFiles{i}));
% end
% 
% SoundsFilesDir = dir(desktopDir);
% SoundsFilesIdx = contains({SoundsFilesDir.name},'soundlog');
% SoundsFiles = {SoundsFilesDir(SoundsFilesIdx).name};
% for i = 1:length(SoundsFiles)
%     movefile(fullfile(desktopDir,SoundsFiles{i}), fullfile(saveDir,SoundsFiles{i}));
% end
% 
% end