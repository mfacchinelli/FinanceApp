classdef (Sealed) RecurrenceController < element.Component
    
    properties (Dependent, GetAccess = private)
        % Figure size.
        Width (1, 1) double {mustBeGreaterThan(Width, 0)}
    end % properties (Dependent, GetAccess = private)
    
    properties (Access = private)
        % Array of buttons for recurrence control.
        Buttons (1, :) matlab.ui.control.ToggleButton = matlab.ui.control.ToggleButton.empty()
        % Private value of width.
        Width_ = 500
    end % properties (Access = private)
    
    methods
        
        function obj = RecurrenceController(model, varargin)
            % Call superclass constructor.
            obj@element.Component(model)
            
            % Create button group.
            % Main - Group for all buttons.
            obj.Main = uibuttongroup("Parent", [], ...
                "SelectionChangedFcn", @obj.onSelection);
            
            % Create grid.
            obj.Grid = uigridlayout(obj.Main, size(obj.Model.AllowedRecurrence));
            
            % Loop over allowed recurrences.
            for r = 1:numel(obj.Model.AllowedRecurrence)
                % Create and store button.
                obj.Buttons(r) = uitogglebutton(obj.Main, ...
                    "Text", obj.Model.AllowedRecurrence(r), ...
                    "Value", strcmp(obj.Model.Recurrence, obj.Model.AllowedRecurrence(r)));
                
                % Set position based on panel.
                obj.Buttons(r).Position(1) = r * obj.Width_ / numel(obj.Model.AllowedRecurrence) - ...
                    obj.Buttons(r).Position(3);
            end
            
            % Set properties.
            set(obj, varargin{:})
        end % constructor
        
        function set.Width(obj, value)
            % Set value.
            obj.Width_ = value;
            
            % Scale button positions.
            for r = 1:numel(obj.Model.AllowedRecurrence)
                obj.Buttons(r).Position(1) = r * obj.Width_ / numel(obj.Model.AllowedRecurrence) - ...
                    obj.Buttons(r).Position(3);
            end
        end % set.Width
        
    end % methods
    
    methods (Access = private)
        
        function onSelection(obj, ~, selection)
            % ONSELECTION Internal function to change the recurrence value
            % of the model. This function is triggered whenever a button is
            % pressed in the figure.
            
            % Change recurrence for model.
            obj.Model.Recurrence = string(selection.NewValue.Text);
        end % onSelection
        
    end % methods (Access = private)
    
end