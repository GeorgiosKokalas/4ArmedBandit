buttons = ['Y', 'B','A','X'];

scores = GetScores(length(buttons), 0.05, true);
cpu = CpuPlayerT2(1, 'YBX', [], 0.1);

for idx = 1:1000
    choice = cpu.getResponse();
    choice_idx = find(buttons == choice);
    reward = scores(choice_idx);
    cpu.changeBehavior(reward);

    disp(sprintf("Trial %d", idx));
    disp(scores);
    disp(sprintf("Choice: %s  |  Reward: %d", choice, reward));

    scores = GetScores(length(buttons), 0.05,false);
    disp("");
end
