% Main script or function where the CPU choice and scoring are handled
behavior_mode=5;
choice_list=['Y', 'B', 'A', 'X'];
next_choice=[];
epsilon=[];
% Create an instance of CpuPlayerT3 (example initialization)
Cpu = CpuPlayerT3(behavior_mode, choice_list, next_choice, epsilon);

% Initialize totals (example initialization)
Totals.cpu = 0;

button_scores = GetScores(4, .05, true);

cpu_choice = Cpu.getResponse(button_scores);
score_idx = choice_list == cpu_choice;
cpu_score = button_scores(score_idx);
Cpu.changeBehavior(cpu_score);

all_choices = [];
for i = 1:10000
    cpu_choice = Cpu.getResponse(button_scores);
    score_idx = choice_list == cpu_choice;
    cpu_score = button_scores(score_idx);
    Cpu.changeBehavior(cpu_score);
    all_choices = [all_choices, cpu_choice];
end
disp(sprintf("A:%d ,B:%d, X:%d, Y:%d",sum(all_choices == 'A'), sum(all_choices == 'B'),...
                              sum(all_choices == 'X'), sum(all_choices == 'Y')));
