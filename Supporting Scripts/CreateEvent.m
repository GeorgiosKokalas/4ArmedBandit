% Function called by Experiment.m,  Introduction.m, RunTrial.m
% Function creates an event, and is called in parallel
function event_cell = CreateEvent(Type, Block_Idx, Trial_Idx, Cpu)
    % Apply the appropriate event message based on the type of the event
    event_msg = '';
    switch string(Type)
        case "taskStart"
            event_msg = "Task Start";
        case "taskStop"
            event_msg = "Task Ended Successfully";
        case "taskPaused"
            event_msg = sprintf("Block %d, Trial %d: Task Paused", Block_Idx, Trial_Idx);
        case "taskResume"
            event_msg = sprintf("Block %d, Trial %d: Task Resumed", Block_Idx, Trial_Idx);
        case "taskAbort"
            event_msg = sprintf("Block %d, Trial %d: Task Aborted", Block_Idx, Trial_Idx);
        case "intro1"
            event_msg = "Task Intro 1: Title print";
        case "intro2"
            event_msg = "Task Intro 2: Character Selection";
        case "intro3"
            event_msg = "Task Intro 3: Input Familiarization";
        case "blockStart"
            event_msg = sprintf("Starting Block %d - CPU %d Score Mode %s", Block_Idx, Cpu.Behavior_Mode, Cpu.Score_Mode);
        case "blockEnd"
            event_msg = sprintf("Ending Block %d", Block_Idx);
        case "trialStart"
            event_msg = sprintf("Trial %d starting at Block %d", Trial_Idx, Block_Idx);
        case "trialEnd"
            event_msg = sprintf("Trial %d ending at Block %d", Trial_Idx, Block_Idx);
        case "playerTurnStart"
            event_msg = sprintf("Block %d, Trial %d: Player Turn Start", Block_Idx, Trial_Idx);
        case "playerDecisionMade"
            event_msg = sprintf("Block %d, Trial %d: Player Made Decision", Block_Idx, Trial_Idx);
        case "playerTurnEnd"
            event_msg = sprintf("Block %d, Trial %d: Player Turn Ended", Block_Idx, Trial_Idx);
        case "cpuTurnStart"
            event_msg = sprintf("Block %d, Trial %d: CPU Turn Start", Block_Idx, Trial_Idx);
        case "cpuDecisionMade"
            event_msg = sprintf("Block %d, Trial %d: CPU Made Decision", Block_Idx, Trial_Idx);
        case "cpuTurnEnd"
            event_msg = sprintf("Block %d, Trial %d: CPU Turn Ended", Block_Idx, Trial_Idx);
        otherwise
            event_cell = {"Error", GetSecs()};
            disp("Event Call not recognized. Aborting...")
            return;
    end
    event_msg = char(event_msg);
    
    % Create the return value to be a cell with the event and the current
    try
        event_cell = {event_msg, GetSecs()};
    catch ME
        disp("Event cell failed to create")
        event_cell = {ME.message, GetSecs()+40000000000};
    end

    % Try to send a BlackRock comment twice for good measure
    for i = 1:2
        try
            cbmex('comment',16711680,0,event_msg,'instance',i-1);
        catch
            disp("BlackRock did not receive the event");
        end
    end
end