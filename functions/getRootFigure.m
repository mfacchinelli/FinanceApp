function obj = getRootFigure(obj)
% GETROOTFIGURE Retrieve root figure by iterating over parents of graphics
% object.

% Check input.
narginchk(1, 1)

% Call built-in ancestor function.
obj = ancestor(obj, 'figure', 'toplevel');

end