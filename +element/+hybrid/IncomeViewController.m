classdef (Sealed) IncomeViewController < element.ComponentWithListenerPanel
    
    properties (Access = private)
        % Edit box showing the gross income value.
        GrossIncomeField (1, 1)
        % Edit box showing the net income value.
        NetIncomeField (1, 1)
    end
    
    methods
        
        function obj = IncomeViewController(model, varargin)
            % Call superclass constructors.
            obj@element.ComponentWithListenerPanel(model)
            
            % Create grid.
            obj.Grid = uigridlayout(obj.Main, [1, 2]);
            
            % Create edit fields.
            obj.GrossIncomeField = uieditfield("numeric", ...
                "Parent", obj.Grid, ...
                "ValueDisplayFormat", "£ %.2f", ...
                "Value", obj.Model.GrossIncome, ...
                "FontWeight", "bold", ...
                "FontSize", 26, ...
                "Editable", "on", ...
                "Limits", [obj.Model.MinIncome, obj.Model.MaxIncome], ...
                "LowerLimitInclusive", "on",...
                "UpperLimitInclusive", "on",...
                "ValueChangedFcn", @obj.onChangedIncome);
            
            obj.NetIncomeField = uieditfield("numeric", ...
                "Parent", obj.Grid, ...
                "ValueDisplayFormat", "£ %.2f", ...
                "Value", obj.Model.NetIncome, ...
                "FontWeight", "bold", ...
                "FontSize", 26, ...
                "Editable", "off");
            
            % Set properties.
            set(obj, varargin{:})
            
            % Show data.
            obj.onUpdate();
        end % constructor
        
    end % methods
    
    methods (Access = protected)
        
        function onUpdate(obj, ~, ~)
            % ONUPDATE Internal function to update the income values with
            % new model data. This function is triggered by a listener on
            % the Finance object 'Update' event.
            
            % Update edit field limits.
            obj.GrossIncomeField.Limits = [obj.Model.MinIncome, obj.Model.MaxIncome];
            
            % Update edit boxes.
            obj.GrossIncomeField.Value = obj.Model.GrossIncome;
            obj.NetIncomeField.Value = obj.Model.NetIncome;
        end % onUpdate
        
    end % methods (Access = protected)
    
    methods (Access = private)
        
        function onChangedIncome(obj, field, ~)
            % ONCHANGEDINCOME Internal function to change the gross income
            % value of the model. This function is triggered whenever the
            % gross income value is changed in the edit field.
            
            % Change model value.
            obj.Model.GrossIncome = field.Value;
        end % onChangedIncome
        
    end % methods (Access = private)
    
end