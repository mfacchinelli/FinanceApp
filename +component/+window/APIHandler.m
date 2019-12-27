classdef (Sealed, Hidden) APIHandler < component.InputHandler
    
    methods
        
        function obj = APIHandler(varargin)
            % Call superclass constructor.
            obj@component.InputHandler();
            
            % Set figure properties.
            obj.Parent.Name = "Set API Key";
            obj.Label.Text = ["Please enter the API key to download new tax and", ...
                        "National Insurance information, available from:"];
            obj.EditField.Value = "https://www.income-tax.co.uk/tax-calculator-api/";
            
            % Set properties.
            set(obj, varargin{:})
            
            % Show figure after all components are created.
            obj.Parent.Visible = "on";
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