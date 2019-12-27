function obj = getRootFigure(obj)
% GETROOTFIGURE Retrieve root figure by iterating over parents of graphics
% object.

% Iterate over parents until reaching with a figure object.
while ~isa(obj, "matlab.ui.Figure")
    % Retireve parent.
    obj = obj.Parent;
    
    % Check that graphics root is not reached.
    if isa(obj, "matlab.ui.Root") || isa(obj, "matlab.graphics.GraphicsPlaceholder")
        error("RootFigure:NoFigure", "No figure was found.")
    end
end

end