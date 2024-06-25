function DrawIcon(Window, Icon_Name, Rect)
    % If we don't have any dimensions for the picture
    if ~exist('Rect', 'var') || ~IsRect(Rect); Rect = [0,0,250,250]; end

    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % Load the PNG image with transparency
    [image, ~, alpha] = imread(Icon_Name);
    image(:,:,4) = alpha;

    % Make the texture
    texture = Screen('MakeTexture', Window, image);
    
    % Draw the texture to the window
    Screen('DrawTexture', Window, texture,[],Rect);
end

function Output = IsRect(Rect)
   Output = isnumeric(Rect);
   Output = Output && height(Rect) == 1;
   Output = Output && width(Rect) == 4;
end