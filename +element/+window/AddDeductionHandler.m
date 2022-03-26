classdef (Sealed) AddDeductionHandler < element.InputHandler
    
    properties (Dependent, SetAccess = private)
        % Access value of input.
        InputValue
    end % properties (Dependent, SetAccess = private)
    
    properties (Dependent)
        % Default value of deduction name.
        DefaultName
        % Default value of deduction value.
        DefaultValue
        % Allowed values of currency.
        AllowedCurrencies
        % Default value of currency.
        DefaultCurrency
        % Allowed values of recurrence.
        AllowedRecurrence
        % Default value of currency.
        DefaultRecurrence
    end % properties (Dependent, SetAccess = private)
    
    properties (Access = private)
        % Edit field to capture name of deduction.
        EditField matlab.ui.control.EditField
        % Spinner to capture deduction value.
        Spinner matlab.ui.control.Spinner
        % Drop down to capture deduction currency.
        CurrencyDropDown matlab.ui.control.DropDown
        % Drop down to capture deduction recurrence.
        RecurrenceDropDown matlab.ui.control.DropDown
    end % properties (Access = private)
    
    methods
        
        function obj = AddDeductionHandler(varargin)
            % Set label values.
            obj.UIFigure.Name = "Add Deduction";
            obj.Label.Text = ["Please enter new deduction information (name, value, ", ...
                "currency, and recurrence) separated by semicolons."];
            
            % Set properties.
            set(obj, varargin{:})
            
            % Show figure after all components are created.
            obj.UIFigure.Visible = "on";
        end % constructor
        
        function value = get.InputValue(obj)
            % Retrieve inputs.
            name = obj.EditField.Value;
            deduction = num2str(obj.Spinner.Value);
            currency = obj.CurrencyDropDown.Value;
            recurrence = obj.RecurrenceDropDown.Value;
            
            % Combine values.
            value = strjoin({name, deduction, currency, recurrence}, "; ");
        end % get.InputValue
        
        function set.DefaultName(obj, value)
            obj.EditField.Value = value;
        end % get.DefaultName
        
        function value = get.DefaultName(obj)
            value = obj.EditField.Value;
        end % get.DefaultName
        
        function set.DefaultValue(obj, value)
            obj.Spinner.Value = value;
        end % get.DefaultValue
        
        function value = get.DefaultValue(obj)
            value = obj.Spinner.Value;
        end % get.DefaultValue
        
        function set.AllowedCurrencies(obj, value)
            obj.CurrencyDropDown.Items = value;
        end % get.AllowedCurrencies
        
        function value = get.AllowedCurrencies(obj)
            value = obj.CurrencyDropDown.Items;
        end % get.AllowedCurrencies
        
        function set.DefaultCurrency(obj, value)
            obj.CurrencyDropDown.Value = string(value);
        end % get.DefaultCurrency
        
        function value = get.DefaultCurrency(obj)
            value = obj.CurrencyDropDown.Value;
        end % get.DefaultCurrency
        
        function set.AllowedRecurrence(obj, value)
            obj.RecurrenceDropDown.Items = string(value);
        end % get.AllowedRecurrence
        
        function value = get.AllowedRecurrence(obj)
            value = obj.RecurrenceDropDown.Items;
        end % get.AllowedRecurrence
        
        function set.DefaultRecurrence(obj, value)
            obj.RecurrenceDropDown.Value = string(value);
        end % get.DefaultRecurrence
        
        function value = get.DefaultRecurrence(obj)
            value = obj.RecurrenceDropDown.Value;
        end % get.DefaultRecurrence
        
    end % methods
    
    methods (Access = protected)
        
        function createBasicComponents(obj)
            % CREATEBASICCOMPONENTS Internal function to create app
            % components, i.e., text box and edit field.
            
            % Call superclass method.
            obj.createBasicComponents@element.InputHandler()
            
            % Create EditField.
            obj.EditField = uieditfield(obj.Grid, "text", ...
                "Value", "MATLAB");
            
            % Create Spinner.
            obj.Spinner = uispinner(obj.Grid, ...
                "Step", 1, ...
                "Limits", [0, Inf], ...
                "Value", 100);
            
            % Create currency DropDown.
            obj.CurrencyDropDown = uidropdown(obj.Grid);
            
            % Create recurrence DropDown.
            obj.RecurrenceDropDown = uidropdown(obj.Grid);
        end % createComponents
        
    end % methods (Access = protected)
    
    methods (Access = protected)
        
        function setLayout(obj)
            % SETLAYOUT Internal function to specify position of
            % components.
            
            % Set grid layout.
            obj.Grid.ColumnWidth = ["1x", "1x", "1x", "1x"];
            obj.Grid.RowHeight = ["1x", "1x", "1x"];
            
            % Set Label position.
            obj.Label.Layout.Row = 1;
            obj.Label.Layout.Column = [1, 4];
            
            % Set EditField position.
            obj.EditField.Layout.Row = 2;
            obj.EditField.Layout.Column = 1;
            
            % Set Spinner position.
            obj.Spinner.Layout.Row = 2;
            obj.Spinner.Layout.Column = 2;
            
            % Set DropDown positions.
            obj.CurrencyDropDown.Layout.Row = 2;
            obj.CurrencyDropDown.Layout.Column = 3;
            obj.RecurrenceDropDown.Layout.Row = 2;
            obj.RecurrenceDropDown.Layout.Column = 4;
            
            % Set OKButton position.
            obj.OKButton.Layout.Row = 3;
            obj.OKButton.Layout.Column = [2, 3];
            
            % Set CancelButton position.
            obj.CancelButton.Layout.Row = 3;
            obj.CancelButton.Layout.Column = 4;
        end % createComponents
        
    end % methods (Access = protected)
    
end