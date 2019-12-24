classdef (Sealed, Hidden) DeductionDlg < matlab.mixin.SetGetExactNames
    
    properties (Dependent, SetAccess = private)
        % Access value of edit field.
        EditFieldValue
    end % properties (Dependent, SetAccess = private)
    
    properties (Access = private)
        % UI figure for app.
        UIFigure matlab.ui.Figure
        % Grid layout for app.
        GridLayout matlab.ui.container.GridLayout
        % Label to show custom text.
        Label matlab.ui.control.Label
        % Edit field to capture own text.
        EditField matlab.ui.control.EditField
        % Button to return edit field value to main app.
        OKButton matlab.ui.control.Button
        % Button to cancel transaction and delete app.
        CancelButton matlab.ui.control.Button
    end % properties (Access = private)
    
    properties (Constant)
        % Values of allowed modes.
        AllowedModes = ["addDeduction", "removeDeduction"]
    end % properties (Constant)
    
    events
        % Event broadcasting 'OK' button pushed.
        OKPushed
        % Event broadcasting 'Cancel' button pushed.
        CancelPushed
    end % events
    
    methods
        
        function app = DeductionDlg(mode, position)
            arguments
                mode (1, 1) string {mustBeMode}
                position (1, 2) double {mustBeNonnegative}
            end
            
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
                
                % Create strings for components.
                [name, labelText, editFieldText] = app.selectMode(mode);
                
                % Create UIFigure and components.
                app.createComponents(position, name, labelText, editFieldText)
                
                % Clear variable if no output is needed.
                if nargout == 0
                    clear app
                end
            else
                % Delete app.
                app.delete();
            end
        end % constructor
        
        function delete(app)
            % Set dialog open to false.
            global DialogOpen
            DialogOpen = false;
            
            % Delete app.
            delete(app.UIFigure)
        end % destructor
        
        function value = get.EditFieldValue(app)
            value = app.EditField.Value;
        end % get.EditFieldValue
        
    end % methods
    
    methods (Access = private)
        
        function createComponents(app, position, name, labelText, editFieldText)
            % CREATECOMPONENTS Internal function to create UIFigure for app
            % and its components - text box and edit field - based on the
            % input text strings.
            
            % Create UIFigure and hide until all components are created.
            app.UIFigure = uifigure("Visible", "off");
            app.UIFigure.Position = [position, 315, 120];
            app.UIFigure.Name = name;
            
            % Create GridLayout.
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = ["1x", "1x", "1x"];
            app.GridLayout.RowHeight = ["1x", "1x", "1x"];
            
            % Create Label.
            app.Label = uilabel(app.GridLayout);
            app.Label.Text = labelText;
            app.Label.HorizontalAlignment = "left";
            app.Label.VerticalAlignment = "center";
            app.Label.Layout.Row = 1;
            app.Label.Layout.Column = [1, 3];
            
            % Create EditField.
            app.EditField = uieditfield(app.GridLayout, "text");
            app.EditField.Value = editFieldText;
            app.EditField.Layout.Row = 2;
            app.EditField.Layout.Column = [1, 3];
            
            % Create OKButton.
            app.OKButton = uibutton(app.GridLayout, "push");
            app.OKButton.Layout.Row = 3;
            app.OKButton.Layout.Column = 2;
            app.OKButton.Text = "OK";
            app.OKButton.ButtonPushedFcn = @app.onOKPushed;
            
            % Create CancelButton.
            app.CancelButton = uibutton(app.GridLayout, "push");
            app.CancelButton.Layout.Row = 3;
            app.CancelButton.Layout.Column = 3;
            app.CancelButton.Text = "Cancel";
            app.CancelButton.ButtonPushedFcn = @app.onCancelPushed;
            
            % Show the figure after all components are created.
            app.UIFigure.Visible = "on";
        end % createComponents
        
        function onOKPushed(app, ~, ~)
            % ONOKPUSHED Internal function to notify listeners of
            % 'OKPushed' event and deleting app.
            
            % Broadcast event.
            app.notify("OKPushed");
            
            % Delete app.
            app.delete();
        end % onOKPushed
        
        function onCancelPushed(app, ~, ~)
            % ONOKPUSHED Internal function to notify listeners of
            % 'CancelPushed' event and deleting app.
            
            % Broadcast event.
            app.notify("CancelPushed");
            
            % Delete app.
            app.delete();
        end % onCancelPushed
        
    end % methods (Access = private)
    
    methods (Static, Access = private)
        
        function [name, labelText, editFieldText] = selectMode(mode)
            % SELECTMODE Internal function to select figure title and
            % variables based on input mode.
            
            % Select text based on mode.
            switch mode
                case "addDeduction"
                    name = "Add Deduction";
                    labelText = ["Please enter new deduction information (name, value, ", ...
                        "currency, and recurrence) separated by semicolons."];
                    editFieldText = "MATLAB; 100; GBP; Monthly";
                case "removeDeduction"
                    name = "Remove Deduction";
                    labelText = ["Please enter row number(s) to delete. Multiple ", ...
                        "row numbers must be separated by semicolons."];
                    editFieldText = "1; 3";
                otherwise
                    error("DeductionDlg:Mode:UnknownInput", ...
                        "Mode '%s' is unknown and unsupported.", mode)
            end
        end % selectMode
        
    end % methods (Static, Access = private)
    
end

function mustBeMode(property)
% MUSTBEMODE Determine whether input value is part of the allowed modes:
% addDeduction, removeDeduction.

% Invoke internal function for member validation.
mustBeMember(property, window.DeductionDlg.AllowedModes)

end