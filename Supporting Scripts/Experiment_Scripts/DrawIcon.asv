% Called by Experiment, Introduction, RunTrial and subscripts within those.
% Function that draws an icon      
% Input: 
%   - Pars      Pointer to the experiment parameters
%   - Icon_Name File name for the icon
%   - Rect      A specification of where the image shall be placed
%   - Rotation  The rotation at which the icon will be drawn
% Output: None
function DrawIcon(Pars, Icon_Name, Rect, Rotation)
    % If we don't have any dimensions for the picture
    if ~exist('Rect', 'var') || ~isRect(Rect); Rect = [0,0,250,250]; end
    
    % If we don't have a rotation value
    if ~exist('Rotation', 'var'); Rotation = 0; end
    
    Screen('BlendFunction', Pars.screen.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % Load the PNG image with transparency
    [image, ~, alpha] = imread(Icon_Name);
    image(:,:,4) = alpha;

    % Make the texture
    texture = Screen('MakeTexture', Pars.screen.window, image);
    clear image alpha;
    
    % Draw the texture to the Pars.screen.window
    Screen('DrawTexture', Pars.screen.window, texture,[],Rect, Rotation);
end

%% HELPER FUNCTION
% isRect - Determine if a rect is in fact a rect    
% Input
%   - Rect (The rect)
% Output
%   - output (The decision of the function)
function output = isRect(Rect)
   output = isnumeric(Rect);
   output = output && height(Rect) == 1;
   output = output && width(Rect) == 4;
end