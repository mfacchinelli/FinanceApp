classdef (Sealed) SettingsViewController < component.ComponentWithListenerPanel
    
    properties (Access = private)
        % Grid for deductions panel.
        DeductionsGrid matlab.ui.container.GridLayout
        % Grid for tax-National Insurance panel.
        TaxNIGrid matlab.ui.container.GridLayout
        % Check box for pension toggling.
        PensionCheckBox matlab.ui.control.CheckBox
        % Spinner for pension deduction specification.
        PensionSpinner matlab.ui.control.Spinner
        % Spinner for work days.
        WorkDaysSpinner matlab.ui.control.Spinner
        % Spinner for work hours.
        WorkHoursSpinner matlab.ui.control.Spinner
        % Button for import of deductions file.
        ImportButton matlab.ui.control.Button
        % Button for export of deductions file.
        ExportButton matlab.ui.control.Button
        % Edit field for tax-NI last update.
        TaxNIEditField matlab.ui.control.EditField
        % Button for tax-NI update.
        TaxNIButton matlab.ui.control.Button
    end
    
    properties (Constant, Access = private)
        % Array of variables for import and export of MAT file.
        ImportExportVariables = ["grossIncome", "preTaxDeductions", ...
            "postTaxDeductions", "deductPension", "pensionContribution"]
    end % properties (Constant, Access = private)
    
    methods
        
        function obj = SettingsViewController(model, varargin)
            % Call superclass constructors.
            obj@component.ComponentWithListenerPanel(model)
            obj.Main.BorderType = "none";
            
            % Create grid.
            obj.Grid = uigridlayout(obj.Main, [1, 2], ...
                "ColumnWidth", "1x", ...
                "RowHeight", ["2x", "1x"]);
            
            % Create panels for main objects.
            deductionsPanel = uipanel(obj.Grid, ...
                "Title", "Deductions", ...
                "FontWeight", "bold");
            deductionsPanel.Layout.Row = 1;
            deductionsPanel.Layout.Column = 1;
            
            taxNIPanel = uipanel(obj.Grid, ...
                "Title", "Tax and National Insurance", ...
                "FontWeight", "bold");
            taxNIPanel.Layout.Row = 2;
            taxNIPanel.Layout.Column = 1;
            
            % Create layouts for main objects.
            obj.DeductionsGrid = uigridlayout(deductionsPanel);
            obj.DeductionsGrid.ColumnWidth = ["2x", "1x", "2x", "1x"];
            obj.DeductionsGrid.RowHeight = ["1x", "1x", "1x"];
            
            obj.TaxNIGrid = uigridlayout(taxNIPanel);
            obj.TaxNIGrid.ColumnWidth = ["1x", "1x", "1x"];
            obj.TaxNIGrid.RowHeight = "1x";
            
            % Create all objects.
            obj.createComponents();
            
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
            
            % Update all viewers.
            obj.PensionCheckBox.Value = obj.Model.DeductPension;
            if obj.PensionCheckBox.Value
                obj.PensionSpinner.Enable = "on";
            else
                obj.PensionSpinner.Enable = "off";
            end
            obj.PensionSpinner.Value = obj.Model.PensionContribution;
            obj.WorkDaysSpinner.Value = obj.Model.WeeklyWorkDays;
            obj.WorkHoursSpinner.Value = obj.Model.DailyWorkHours;
        end % onUpdate
        
    end % methods (Access = protected)
    
    methods (Access = private)
        
        function createComponents(obj)
            % CREATECOMPONENTS Internal function to create all components
            % needed for the settings.
            
            % Create pension check box.
            obj.PensionCheckBox = uicheckbox(obj.DeductionsGrid, ...
                "Text", "Add Penstion to Pre-Tax");
            obj.PensionCheckBox.Layout.Row = 1;
            obj.PensionCheckBox.Layout.Column = 1;
            obj.PensionCheckBox.ValueChangedFcn = @obj.onPensionCheck;
            
            % Create label for pension contribution spinner.
            pensionLabel = uilabel(obj.DeductionsGrid, ...
                "Text", "Pension contribution:", ...
                "HorizontalAlignment", "right");
            pensionLabel.Layout.Row = 2;
            pensionLabel.Layout.Column = 1;
            
            % Create pension contribution spinner.
            obj.PensionSpinner = uispinner(obj.DeductionsGrid, ...
                "Step", 0.5, ...
                "Limits", [0, 100], ...
                "Enable", "off");
            obj.PensionSpinner.Layout.Row = 2;
            obj.PensionSpinner.Layout.Column = 2;
            obj.PensionSpinner.ValueChangedFcn = ...
                @(src, ~) set(obj.Model, "PensionContribution", src.Value);
            
            % Create label for work days spinner.
            workDaysLabel = uilabel(obj.DeductionsGrid, ...
                "Text", "Working days per week:", ...
                "HorizontalAlignment", "right");
            workDaysLabel.Layout.Row = 1;
            workDaysLabel.Layout.Column = 3;
            
            % Create work days spinner.
            obj.WorkDaysSpinner = uispinner(obj.DeductionsGrid, ...
                "Step", 1, ...
                "Limits", [1, 7], ...
                "Editable", "off");
            obj.WorkDaysSpinner.Layout.Row = 1;
            obj.WorkDaysSpinner.Layout.Column = 4;
            obj.WorkDaysSpinner.ValueChangedFcn = ...
                @(src, ~) set(obj.Model, "WeeklyWorkDays", src.Value);
            
            % Create label for work hours spinner.
            workHoursLabel = uilabel(obj.DeductionsGrid, ...
                "Text", "Working hours per day:", ...
                "HorizontalAlignment", "right");
            workHoursLabel.Layout.Row = 2;
            workHoursLabel.Layout.Column = 3;
            
            % Create work hours spinner.
            obj.WorkHoursSpinner = uispinner(obj.DeductionsGrid, ...
                "Step", 0.25, ...
                "Limits", [0.25, 24]);
            obj.WorkHoursSpinner.Layout.Row = 2;
            obj.WorkHoursSpinner.Layout.Column = 4;
            obj.WorkHoursSpinner.ValueChangedFcn = ...
                @(src, ~) set(obj.Model, "DailyWorkHours", src.Value);
            
            % Create import button.
            obj.ImportButton = uibutton(obj.DeductionsGrid, "push", ...
                "Text", "Import Deductions MAT");
            obj.ImportButton.Layout.Row = 3;
            obj.ImportButton.Layout.Column = [1, 2];
            obj.ImportButton.ButtonPushedFcn = @(~, ~) onImport(obj);
            
            % Create export button.s
            obj.ExportButton = uibutton(obj.DeductionsGrid, "push", ...
                "Text", "Export Deductions MAT");
            obj.ExportButton.Layout.Row = 3;
            obj.ExportButton.Layout.Column = [3, 4];
            obj.ExportButton.ButtonPushedFcn = @(~, ~) onExport(obj);
            
            % Create label for tax-NI edit field.
            taxNILabel = uilabel(obj.TaxNIGrid, ...
                "Text", "Last tax-NI data update:", ...
                "HorizontalAlignment", "right");
            taxNILabel.Layout.Row = 1;
            taxNILabel.Layout.Column = 1;
            
            % Create tax-NI edit field.
            obj.TaxNIEditField = uieditfield(obj.TaxNIGrid, "text", ...
                "Value", "NaT", ...
                "Editable", "off");
            obj.TaxNIEditField.Layout.Row = 1;
            obj.TaxNIEditField.Layout.Column = 2;
            
            % Create update button.
            obj.TaxNIButton = uibutton(obj.TaxNIGrid, "push", ...
                "Text", "Update", ...
                "Enable", "off");
            obj.TaxNIButton.Layout.Row = 1;
            obj.TaxNIButton.Layout.Column = 3;
        end % createComponents
        
        function onPensionCheck(obj, src, ~)
            % ONPENSIONCHECK Internal function to set the value of the
            % pension deduction logical value.
            
            % Set model pension deduction.
            obj.Model.DeductPension = src.Value;
            
            % Enable/disable pension spinner.
            if src.Value
                obj.PensionSpinner.Enable = "on";
            else
                obj.PensionSpinner.Enable = "off";
            end
        end % onPensionCheck
        
        function onImport(obj, ~, ~)
            % ONIMPORT Internal function to set deductions based on an
            % external MAT file.
            
            % Open dialog for import.
            [fileName, pathName] = uigetfile("*.mat", "Select a MAT-files for Import");
            
            % Check that a file has been selected.
            if ~isequal(fileName, 0) && ~isequal(pathName, 0)
                % Load file.
                load(fullfile(pathName, fileName), obj.ImportExportVariables{:});
                
                % Make sure that variables are not empty.
                checkExistence = arrayfun(@(i) evalin("caller", sprintf("exist('%s', 'var')", ...
                    obj.ImportExportVariables(i))), 1:numel(obj.ImportExportVariables));
                if all(checkExistence)
                    % Set variables in model.
                    obj.Model.YearlyGrossIncome = grossIncome;
                    obj.Model.PreTax = preTaxDeductions;
                    obj.Model.PostTax = postTaxDeductions;
                    obj.Model.DeductPension = deductPension;
                    obj.Model.PensionContribution = pensionContribution;
                else
                    uialert(getRootFigure(obj.Parent), sprintf("MAT file for import must include the following variables: %s.", ...
                        strjoin(obj.ImportExportVariables, ", ")), "Invalid MAT File");
                end
            end
        end % onImport
        
        function onExport(obj, ~, ~)
            % ONEXPORT Internal function to export deductions to a MAT
            % file.
            
            % Open dialog for export.
            [fileName, pathName] = uiputfile("*.mat", "Select a MAT-files for Export");
            
            % Check that a file has been selected.
            if ~isequal(fileName, 0) && ~isequal(pathName, 0)
                % Get variables from model.
                grossIncome = obj.Model.YearlyGrossIncome; %#ok<NASGU>
                preTaxDeductions = obj.Model.PreTax; %#ok<NASGU>
                postTaxDeductions = obj.Model.PostTax; %#ok<NASGU>
                deductPension = obj.Model.DeductPension; %#ok<NASGU>
                pensionContribution = obj.Model.PensionContribution; %#ok<NASGU>
                
                % Save variables to file.
                save(fullfile(pathName, fileName), obj.ImportExportVariables{:});
            end
        end % onExport
        
    end % methods (Access = private)
    
end