function BlockSwitch(Win, Trial_Idx, Trial_Num)
    if Trial_Idx == Trial_Num; return; end

    text = sprintf('Block %d Complete! %d more to go!\n\n\n', Trial_Idx, Trial_Num-Trial_Idx);
    text = sprintf('%sPress any button to continue.', text);

    DrawFormattedText(Win, text, 'center', 'center', 252:255);
    
    Screen('Flip', Win);

    start = GetSecs();
    while GetSecs()-start < 2
        if KbCheck() || GetXBox().AnyButton; break; end
    end
    WaitSecs(0.3);
end

