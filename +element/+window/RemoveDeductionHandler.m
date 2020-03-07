classdef (Sealed) RemoveDeductionHandler < element.EditFieldHandler
    
    methods
        
        function obj = RemoveDeductionHandler(varargin)
            % Call superclass constructor.
            obj@element.EditFieldHandler()
            
            % Set label values.
            obj.UIFigure.Name = "Remove Deduction";
            obj.Label.Text = ["Please enter row number(s) to delete. Multiple ", ...
                "row numbers must be separated by semicolons."];
            obj.EditField.Value = "1; 3";
            
            % Set properties.
            set(obj, varargin{:})
            
            % Show figure after all components are created.
            obj.UIFigure.Visible = "on";
        end % constructor
        
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
    
end