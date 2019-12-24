classdef (Sealed, Hidden) DeductionsHandler < component.Handler
    
    properties (Dependent, SetAccess = private)
        % Access value of edit field.
        EditFieldValue
    end % properties (Dependent, SetAccess = private)
    
    properties (Dependent, GetAccess = private)
        % String specifying selected mode.
        Mode (1, 1) string {mustBeMode}
        % Array specifying figure position.
        Position (1, 2) double {mustBeNonnegative}
        % Callback for OK button pushed.
        OKCallback (1, 1) function_handle
        % Callback for Cancel button pushed.
        CancelCallback (1, 1) function_handle
    end
    
    properties (Access = private)
        % Label to show custom text.
        Label matlab.ui.control.Label
        % Edit field to capture own text.
        EditField matlab.ui.control.EditField
        % Button to return edit field value to main obj.
        OKButton matlab.ui.control.Button
        % Button to cancel transaction and delete obj.
        CancelButton matlab.ui.control.Button
    end % properties (Access = private)
    
    properties (Constant)
        % Values of allowed modes.
        AllowedModes = ["add", "remove"]
    end % properties (Constant)
    
    methods
        
        function obj = DeductionsHandler(varargin)
            % Create persistent variable to prevent multiple dialogs from
            % being open at the same time.
            global DialogOpen
            if isempty(DialogOpen)
                DialogOpen = false;
            end
            
            % Check that a dialog does not exist already.
            if ~DialogOpen
                % Set dialog open to true.
                DialogOpen = true;
                
                % Create UIFigure and components.
                obj.createComponents();
                
                % Set properties.
                set(obj, varargin{:})
                
                % Clear variable if no output is needed.
                if nargout == 0
                    clear obj
                end
            else
                % Delete obj.
                obj.delete();
            end
        end % constructor
        
        function delete(obj)
            % Set dialog open to false.
            global DialogOpen
            DialogOpen = false;
            
            % Delete obj.
            delete(obj.UIFigure)
        end % destructor
        
        function value = get.EditFieldValue(obj)
            value = obj.EditField.Value;
        end % get.EditFieldValue
        
        function set.Mode(obj, value)
            % Get values for mode.
            [name, labelText, editFieldText] = obj.selectMode(value);
            
            % Set values.
            obj.UIFigure.Name = name;
            obj.Label.Text = labelText;
            obj.EditField.Value = editFieldText;
        end % set.Mode
        
        function set.Position(obj, value)
            obj.UIFigure.Position = [value, 315, 120];
        end % set.Position
        
        function set.OKCallback(obj, value)
            obj.OKButton.ButtonPushedFcn = value;
        end % set.OKCallback
        
        function set.CancelCallback(obj, value)
            obj.CancelButton.ButtonPushedFcn = value;
        end % set.CancelCallback
        
    end % methods
    
    methods (Access = protected)
        
        function createComponents(obj)
            % CREATECOMPONENTS Internal function to create app components,
            % i.e., text box and edit field.
            
            % Create components.
            obj.createComponents@component.Handler()
            
            % Set GridLayout dimensions.
            obj.GridLayout.ColumnWidth = ["1x", "1x", "1x"];
            obj.GridLayout.RowHeight = ["1x", "1x", "1x"];
            
            % Create Label.
            obj.Label = uilabel(obj.GridLayout);
            obj.Label.HorizontalAlignment = "left";
            obj.Label.VerticalAlignment = "center";
            obj.Label.Layout.Row = 1;
            obj.Label.Layout.Column = [1, 3];
            
            % Create EditField.
            obj.EditField = uieditfield(obj.GridLayout, "text");
            obj.EditField.Layout.Row = 2;
            obj.EditField.Layout.Column = [1, 3];
            
            % Create OKButton.
            obj.OKButton = uibutton(obj.GridLayout, "push");
            obj.OKButton.Layout.Row = 3;
            obj.OKButton.Layout.Column = 2;
            obj.OKButton.Text = "OK";
            
            % Create CancelButton.
            obj.CancelButton = uibutton(obj.GridLayout, "push");
            obj.CancelButton.Layout.Row = 3;
            obj.CancelButton.Layout.Column = 3;
            obj.CancelButton.Text = "Cancel";
            
            % Show the figure after all components are created.
            obj.UIFigure.Visible = "on";
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