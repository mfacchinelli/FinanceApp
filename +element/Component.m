classdef (Abstract, Hidden) Component < element.Element
    
    properties (Dependent)
        % Parent of main component.
        Parent
        % Layout of main component.
        Layout
        % Context menu of main component.
        ContextMenu
    end % properties (Dependent)
    
    properties (Access = protected)
        % Main component.
        Main
        % Grid containing object.
        Grid matlab.ui.container.GridLayout
    end % properties (Access = protected)
    
    methods
        
        function set.Parent(obj, value)
            obj.Main.Parent = value;
        end % set.Parent
        
        function value = get.Parent(obj)
            value = obj.Main.Parent;
        end % set.Parent
        
        function set.Layout(obj, value)
            obj.Main.Layout = value;
        end % set.Layout
        
        function value = get.Layout(obj)
            value = obj.Main.Layout;
        end % set.Layout
        
        function set.ContextMenu(obj, value)
            obj.Main.ContextMenu = value;
        end % set.ContextMenu
        
        function value = get.ContextMenu(obj)
            value = obj.Main.ContextMenu;
        end % set.ContextMenu
        
    end % methods
    
    methods (Static, Access = protected)
        
        function evalErrorHandler(command, type, rootFigure)
            % EVALERRORHANDER Evaluate command in caller workspace and
            % handle eventual errors.
            
            % Check inputs.
            narginchk(2, 3)
            
            % Select error types.
            switch type
                case "class"
                    identifier = "MATLAB:undefinedVarOrClass";
                    message = "Selected window type does not exist.";
                case "method"
                    identifier = "MATLAB:noSuchMethodOrField";
                    message = "Selected class method does not exist.";
                case "api"
                    identifier = "MATLAB:webservices:ContentTypeReaderError";
                    message = "Input API key is not valid.";
                otherwise
                    error("MATLAB:EvalErrorHandler:InvalidType", ...
                        "Selected type '%s' does not exist.", type)
            end
            
            % Try calling function.
            try
                evalin("caller", command);
            catch exception
                if strcmp(exception.identifier, identifier)
                    if nargin == 3
                        uialert(rootFigure, message, sprintf("Caught Exception - %s", identifier));
                    else
                        error("MATLAB:EvalErrorHandler:InvalidCommand", message)
                    end
                else
                    if nargin == 3
                        uialert(rootFigure, exception.message, ...
                            sprintf("Caught Exception - %s", exception.identifier));
                    else
                        rethrow(exception)
                    end
                end
            end
        end % evalErrorHandler
        
    end % methods (Static, Access = protected)
    
end