classdef (Sealed) DeductionsView < element.ComponentWithListener
    
    properties
        % String defining the name of the tracked property of the model.
        TrackedProperty string = string.empty()
    end % properties
    
    properties (Dependent)
        % Array defining whether table columns are editable.
        ColumnEditable (1, :) logical
        % Array defining whether table columns are sortable.
        ColumnSortable (1, :) logical
    end % properties (Dependent)
    
    methods
        
        function obj = DeductionsView(model, varargin)
            % Call superclass constructor.
            obj@element.ComponentWithListener(model)
            
            % Set UI table to default and set parent to grid.
            % Main - Table showing finance deductions.
            obj.Main = getEmptyDeductionUITable();
            
            % Set properties.
            set(obj, varargin{:})
            
            % Show data.
            obj.onUpdate();
        end % constructor
        
        function set.TrackedProperty(obj, value)
            % Check that the property is acutally part of the model.
            if ~isempty(value)
                assert(isprop(obj.Model, value), "DeductionsView:TrackedProperty:InvalidInput", ...
                    "Name of tracked property must valid.")
            end
            
            % Set value.
            obj.TrackedProperty = value;
        end % set.TrackedProperty
        
        function set.ColumnEditable(obj, value)
            obj.Main.ColumnEditable = value;
        end % set.ColumnEditable
        
        function value = get.ColumnEditable(obj)
            value = obj.Main.ColumnEditable;
        end % set.ColumnEditable
        
        function set.ColumnSortable(obj, value)
            obj.Main.ColumnSortable = value;
        end % set.ColumnSortable
        
        function value = get.ColumnSortable(obj)
            value = obj.Main.ColumnSortable;
        end % set.ColumnSortable
        
    end % methods
    
    methods (Access = protected)
        
        function onUpdate(obj, ~, ~)
            % ONUPDATE Internal function to update the deductions table
            % with new model data. This function is triggered by a listener
            % on the Finance object 'Update' event.
            
            % Check that 'TrackedProperty' is not empty.
            if ~isempty(obj.TrackedProperty)
                % Update table data with the value of the tracked property.
                obj.Main.Data = obj.Model.(obj.TrackedProperty);
            else
                obj.Main.Data = getEmptyDeductionTable(); % TODO: geck it
            end
        end % onUpdate
        
    end % methods (Access = protected)
    
end

function t = getEmptyDeductionTable()
% GETEMPTYDEDUCTIONSTABLE Function to return an empty deductions table to
% be used as visualization purposes.

% Create empty table with deductions properties.
t = table('Size', [0, 4], 'VariableTypes', ["string", "double", "categorical", "categorical"], ...
    'VariableNames', ["Name", "Deduction", "Currency", "Recurrence"]);
t.Currency = setcats(t.Currency, Finance.AllowedCurrencies);
t.Recurrence = setcats(t.Recurrence, Finance.AllowedRecurrence);

end % getEmptyDeductionTable

function u = getEmptyDeductionUITable()
% GETEMPTYDEDUCTIONSUITABLE Function to return an empty deductions UI table
% to be used as visualization purposes.

% Create empty table with deduction properties.
t = getEmptyDeductionTable();

% Create UI table based on empty table.
f = uifigure("Visible", "off", "HandleVisibility", "off");
u = uitable("Parent", f, "Data", t);
u.Parent = [];

end