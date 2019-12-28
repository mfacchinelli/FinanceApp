classdef (Sealed) SummaryView < element.ComponentWithListenerPanel
    
    properties (Access = private)
        % Edit box showing the pre-tax voluntary deductions.
        PreTaxVoluntaryDeductionField (1, 1)
        % Edit box showing the pre-tax compulsory deductions.
        PreTaxCompulsoryDeductionField (1, 1)
        % Edit box showing the post-tax deductions.
        PostTaxDeductionField (1, 1)
    end
    
    methods
        
        function obj = SummaryView(model, varargin)
            % Call superclass constructors.
            obj@element.ComponentWithListenerPanel(model)
            
            % Create grid.
            obj.Grid = uigridlayout(obj.Main, [4, 2]);
            
            % Retrieve deduction summary values.
            deductions = obj.Model.Deductions;
            
            % Create edit fields.
            obj.PreTaxVoluntaryDeductionField = uieditfield("numeric", ...
                "Parent", obj.Grid, ...
                "ValueDisplayFormat", "£ %.2f", ...
                "Value", deductions(1), ...
                "FontSize", 20, ...
                "Editable", "off");
            obj.PreTaxVoluntaryDeductionField.Layout.Row = 2;
            obj.PreTaxVoluntaryDeductionField.Layout.Column = 2;
            
            obj.PreTaxCompulsoryDeductionField = uieditfield("numeric", ...
                "Parent", obj.Grid, ...
                "ValueDisplayFormat", "£ %.2f", ...
                "Value", deductions(2), ...
                "FontSize", 20, ...
                "Editable", "off");
            obj.PreTaxCompulsoryDeductionField.Layout.Row = 3;
            obj.PreTaxCompulsoryDeductionField.Layout.Column = 2;
            
            obj.PostTaxDeductionField = uieditfield("numeric", ...
                "Parent", obj.Grid, ...
                "ValueDisplayFormat", "£ %.2f", ...
                "Value", deductions(3), ...
                "FontSize", 20, ...
                "Editable", "off");
            obj.PostTaxDeductionField.Layout.Row = 4;
            obj.PostTaxDeductionField.Layout.Column = 2;
            
            % Create all labels.
            label = uilabel(obj.Grid, ...
                "Text", ["Use this app to compute your net income based on your recurring deductions. You can add pre-tax and", ...
                "post-tax deductions. The values of National Insurance and tax will be computed based on the gross", ...
                "income, after pre-tax and optional pension deductions have been subtracted."], ...
                "FontSize", 12, ...
                "HorizontalAlignment", "left", ...
                "VerticalAlignment", "top");
            label.Layout.Row = 1;
            label.Layout.Column = [1, 2];
            
            label = uilabel(obj.Grid, ...
                "Text", "Pre-Tax Voluntary Deductions:", ...
                "FontSize", 15, ...
                "HorizontalAlignment", "right", ...
                "VerticalAlignment", "center");
            label.Layout.Row = 2;
            label.Layout.Column = 1;
            
            label = uilabel(obj.Grid, ...
                "Text", "Pre-Tax Compulsory Deductions:", ...
                "FontSize", 15, ...
                "HorizontalAlignment", "right", ...
                "VerticalAlignment", "center");
            label.Layout.Row = 3;
            label.Layout.Column = 1;
            
            label = uilabel(obj.Grid, ...
                "Text", "Post-Tax Deductions:", ...
                "FontSize", 15, ...
                "HorizontalAlignment", "right", ...
                "VerticalAlignment", "center");
            label.Layout.Row = 4;
            label.Layout.Column = 1;
            
            % Set properties.
            set(obj, varargin{:})
            
            % Show data.
            obj.onUpdate();
        end % constructor
        
    end % methods
    
    methods (Access = protected)
        
        function onUpdate(obj, ~, ~)
            % ONUPDATE Internal function to update the deductions values
            % with new model data. This function is triggered by a listener
            % on the Finance object 'Update' event.
            
            % Retrieve deduction summary values.
            deductions = obj.Model.Deductions;
            
            % Update edit boxes.
            obj.PreTaxVoluntaryDeductionField.Value = deductions(1);
            obj.PreTaxCompulsoryDeductionField.Value = deductions(2);
            obj.PostTaxDeductionField.Value = deductions(3);
        end % onUpdate
        
    end % methods (Access = protected)
    
end