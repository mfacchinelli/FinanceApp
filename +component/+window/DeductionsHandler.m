classdef (Sealed, Hidden) DeductionsHandler < component.InputHandler
    
    properties (Dependent, GetAccess = private)
        % String specifying selected mode.
        Mode (1, 1) string {mustBeMode}
    end % properties (Dependent, GetAccess = private)
    
    properties (Constant)
        % Values of allowed modes.
        AllowedModes = ["add", "remove"]
    end % properties (Constant)
    
    methods
        
        function obj = DeductionsHandler(varargin)
            % Call superclass constructor.
            obj@component.InputHandler();
            
            % Set properties.
            set(obj, varargin{:})
        end % constructor
        
        function set.Mode(obj, value)
            % Get values for mode.
            [name, labelText, editFieldText] = obj.selectMode(value);
            
            % Set values.
            obj.Parent.Name = name;
            obj.Label.Text = labelText;
            obj.EditField.Value = editFieldText;
        end % set.Mode
        
    end % methods
    
    methods (Access = protected)
        
        function setLayout(obj)
            % SETLAYOUT Internal function to specify position of
            % components.
            
            % Set grid layout.
            obj.Grid.ColumnWidth = ["1x", "1x", "1x"];
            obj.Grid.RowHeight = ["1x", "1x", "1x"];
            
            % Set Label position.
            obj.Label.Layout.Row = 1;
            obj.Label.Layout.Column = [1, 3];
            
            % Set EditField position.
            obj.EditField.Layout.Row = 2;
            obj.EditField.Layout.Column = [1, 3];
            
            % Set OKButton position.
            obj.OKButton.Layout.Row = 3;
            obj.OKButton.Layout.Column = 2;
            
            % Set CancelButton position.
            obj.CancelButton.Layout.Row = 3;
            obj.CancelButton.Layout.Column = 3;
        end % createComponents
        
    end % methods (Access = protected)
    
    methods (Static, Access = private)
        
        function [name, labelText, editFieldText] = selectMode(mode)
            % SELECTMODE Internal function to select figure title and
            % variables based on input mode.
            
            % Select text based on mode.
            switch mode
                case "add"
                    name = "Add Deduction";
                    labelText = ["Please enter new deduction information (name, value, ", ...
                        "currency, and recurrence) separated by semicolons."];
                    editFieldText = "MATLAB; 100; GBP; Monthly";
                case "remove"
                    name = "Remove Deduction";
                    labelText = ["Please enter row number(s) to delete. Multiple ", ...
                        "row numbers must be separated by semicolons."];
                    editFieldText = "1; 3";
                otherwise
                    error("DeductionsHandler:Mode:UnknownInput", ...
                        "Mode '%s' is unknown and unsupported.", mode)
            end
        end % selectMode
        
    end % methods (Static, Access = private)
    
end

function mustBeMode(property)
% MUSTBEMODE Determine whether input value is part of the allowed modes:
% addDeduction, removeDeduction.

% Invoke internal function for member validation.
mustBeMember(property, component.window.DeductionsHandler.AllowedModes)

end