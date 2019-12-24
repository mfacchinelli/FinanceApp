classdef (Sealed) IncomeViewController < component.ComponentWithListener
    
    properties (Access = private)
        % Edit box showing the gross income value.
        GrossIncomeField (1, 1)
        % Edit box showing the net income value.
        NetIncomeField (1, 1)
    end
    
    methods
        
        function obj = IncomeViewController(model, varargin)
            % Call superclass constructors.
            obj@component.ComponentWithListener(model)
            
            % Create panel.
            % Main - Panel containing elements.
            % Set parent to invisible uifigure, to make sure web graphics
            % are used as default.
            f = uifigure("Visible", "off", "HandleVisibility", "off");
            obj.Main = uipanel("Parent", f);
            obj.Main.Parent = [];
            f.delete();
            
            % Create grid.
            obj.Grid = uigridlayout(obj.Main, [1, 2]);
            
            % Create edit fields.
            obj.GrossIncomeField = uieditfield("numeric", ...
                "Parent", obj.Grid, ...
                "ValueDisplayFormat", "£ %.2f", ...
                "Value", obj.Model.GrossIncome, ...
                "Editable", "on", ...
                "Limits", [obj.Model.MinIncome, obj.Model.MaxIncome], ...
                "LowerLimitInclusive", "on",...
                "UpperLimitInclusive", "on",...
                "ValueChangedFcn", @obj.onChangedIncome, ...
                "FontWeight", "bold", ...
                "FontSize", 24);
            
            obj.NetIncomeField = uieditfield("numeric", ...
                "Parent", obj.Grid, ...
                "ValueDisplayFormat", "£ %.2f", ...
                "Value", obj.Model.NetIncome, ...
                "Editable", "off", ...
                "FontWeight", "bold", ...
                "FontSize", 24);
            
            % Set properties.
            set(obj, varargin{:})
            
            % Show data.
            obj.onUpdate();
        end
        
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