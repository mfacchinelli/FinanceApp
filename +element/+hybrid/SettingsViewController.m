classdef (Sealed) SettingsViewController < element.ComponentWithListenerPanel & element.DialogHandler
    
    properties (Access = private)
        % Grid for deductions panel.
        DeductionsGrid matlab.ui.container.GridLayout
        % Grid for currency panel.
        CurrencyGrid matlab.ui.container.GridLayout
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
        % Edit field for currency conversion last update.
        CurrencyEditField matlab.ui.control.EditField
        % Button for currency conversion update.
        CurrencyButton matlab.ui.control.Button
        % Edit field for tax-NI last update.
        TaxNIEditField matlab.ui.control.EditField
        % Button for tax-NI update.
        TaxNIButton matlab.ui.control.Button
    end % properties (Access = private)
    
    methods
        
        function obj = SettingsViewController(model, varargin)
            % Call superclass constructors.
            obj@element.ComponentWithListenerPanel(model)
            obj.Main.BorderType = "none";
            
            % Create grid.
            obj.Grid = uigridlayout(obj.Main, [1, 3], ...
                "ColumnWidth", "1x", ...
                "RowHeight", ["2x", "1x", "1x"]);
            
            % Create panels for main objects.
            deductionsPanel = uipanel(obj.Grid, ...
                "Title", "Deductions", ...
                "FontWeight", "bold");
            deductionsPanel.Layout.Row = 1;
            deductionsPanel.Layout.Column = 1;
            
            currencyPanel = uipanel(obj.Grid, ...
                "Title", "Currency Conversion", ...
                "FontWeight", "bold");
            currencyPanel.Layout.Row = 2;
            currencyPanel.Layout.Column = 1;
            
            taxNIPanel = uipanel(obj.Grid, ...
                "Title", "Tax and National Insurance", ...
                "FontWeight", "bold");
            taxNIPanel.Layout.Row = 3;
            taxNIPanel.Layout.Column = 1;
            
            % Create layouts for main objects.
            obj.DeductionsGrid = uigridlayout(deductionsPanel, ...
                "ColumnWidth", ["2x", "1x", "2x", "1x"], ...
                "RowHeight", ["1x", "1x", "1x"]);
            
            obj.CurrencyGrid = uigridlayout(currencyPanel, ...
                "ColumnWidth", ["1x", "1x", "1x"], ...
                "RowHeight", "1x");
            
            obj.TaxNIGrid = uigridlayout(taxNIPanel, ...
                "ColumnWidth", ["1x", "1x", "1x"], ...
                "RowHeight", "1x");
            
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
            
            % Update all views.
            obj.PensionCheckBox.Value = obj.Model.DeductPension;
            if obj.PensionCheckBox.Value
                obj.PensionSpinner.Enable = "on";
            else
                obj.PensionSpinner.Enable = "off";
            end
            
            obj.PensionSpinner.Value = obj.Model.PensionContribution;
            obj.WorkDaysSpinner.Value = obj.Model.WeeklyWorkDays;
            obj.WorkHoursSpinner.Value = obj.Model.DailyWorkHours;
            
            if isnat(obj.Model.CurrencyUpdate)
                obj.CurrencyEditField.Value = "NaT";
            else
                obj.CurrencyEditField.Value = datestr(obj.Model.CurrencyUpdate, "dd mmmm yyyy");
            end
            if isnat(obj.Model.TaxNIUpdate)
                obj.TaxNIEditField.Value = "NaT";
            else
                obj.TaxNIEditField.Value = datestr(obj.Model.TaxNIUpdate, "dd mmmm yyyy");
            end
        end % onUpdate
        
    end % methods (Access = protected)
    
    methods (Access = private)
        
        function createComponents(obj)
            % CREATECOMPONENTS Internal function to create all components
            % needed for the settings.
            
            % Create pension check box.
            obj.PensionCheckBox = uicheckbox(obj.DeductionsGrid, ...
                "Text", "Add Penstion to Pre-Tax", ...
                "ValueChangedFcn", @obj.onPensionCheck);
            obj.PensionCheckBox.Layout.Row = 1;
            obj.PensionCheckBox.Layout.Column = 1;
            
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
                "Enable", "off", ...
                "ValueChangedFcn", @(src, ~) set(obj.Model, "PensionContribution", src.Value));
            obj.PensionSpinner.Layout.Row = 2;
            obj.PensionSpinner.Layout.Column = 2;
            
            % Create label for work days spinner.
            workDaysLabel = uilabel(obj.DeductionsGrid, ...
                "Text", "Work days per week:", ...
                "HorizontalAlignment", "right");
            workDaysLabel.Layout.Row = 1;
            workDaysLabel.Layout.Column = 3;
            
            % Create work days spinner.
            obj.WorkDaysSpinner = uispinner(obj.DeductionsGrid, ...
                "Step", 1, ...
                "Limits", [1, 7], ...
                "Editable", "off", ...
                "ValueChangedFcn", @(src, ~) set(obj.Model, "WeeklyWorkDays", src.Value));
            obj.WorkDaysSpinner.Layout.Row = 1;
            obj.WorkDaysSpinner.Layout.Column = 4;
            
            % Create label for work hours spinner.
            workHoursLabel = uilabel(obj.DeductionsGrid, ...
                "Text", "Work hours per day:", ...
                "HorizontalAlignment", "right");
            workHoursLabel.Layout.Row = 2;
            workHoursLabel.Layout.Column = 3;
            
            % Create work hours spinner.
            obj.WorkHoursSpinner = uispinner(obj.DeductionsGrid, ...
                "Step", 0.25, ...
                "Limits", [0.25, 24], ...
                "ValueChangedFcn", @(src, ~) set(obj.Model, "DailyWorkHours", src.Value));
            obj.WorkHoursSpinner.Layout.Row = 2;
            obj.WorkHoursSpinner.Layout.Column = 4;
            
            % Create import button.
            obj.ImportButton = uibutton(obj.DeductionsGrid, "push", ...
                "Text", "Import Deductions MAT", ...
                "ButtonPushedFcn", @obj.onImport);
            obj.ImportButton.Layout.Row = 3;
            obj.ImportButton.Layout.Column = [1, 2];
            
            % Create export button.
            obj.ExportButton = uibutton(obj.DeductionsGrid, "push", ...
                "Text", "Export Deductions MAT", ...
                "ButtonPushedFcn", @obj.onExport);
            obj.ExportButton.Layout.Row = 3;
            obj.ExportButton.Layout.Column = [3, 4];
            
            % Create label for currency edit field.
            currencyLabel = uilabel(obj.CurrencyGrid, ...
                "Text", "Last currency data update:", ...
                "HorizontalAlignment", "right");
            currencyLabel.Layout.Row = 1;
            currencyLabel.Layout.Column = 1;
            
            % Create currency edit field.
            obj.CurrencyEditField = uieditfield(obj.CurrencyGrid, "text", ...
                "Value", "NaT", ...
                "Editable", "off");
            obj.CurrencyEditField.Layout.Row = 1;
            obj.CurrencyEditField.Layout.Column = 2;
            
            % Create currency button.
            obj.CurrencyButton = uibutton(obj.CurrencyGrid, "push", ...
                "Text", "Update", ...
                "ButtonPushedFcn", @obj.onCurrencyUpdate);
            obj.CurrencyButton.Layout.Row = 1;
            obj.CurrencyButton.Layout.Column = 3;
            
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
                "ButtonPushedFcn", @obj.onTaxNIUpdate);
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
                load(fullfile(pathName, fileName), obj.Model.ImportExportVariables{:});
                
                % Make sure that variables are not empty.
                checkExistence = arrayfun(@(i) evalin("caller", sprintf("exist('%s', 'var')", ...
                    obj.Model.ImportExportVariables(i))), 1:numel(obj.Model.ImportExportVariables));
                if all(checkExistence)
                    % Set variables in model.
                    obj.Model.setFromImport(YearlyGrossIncome, PreTaxVoluntary, PostTax);
                    obj.Model.DeductPension = DeductPension;
                    obj.Model.PensionContribution = PensionContribution;
                else
                    uialert(getRootFigure(obj), ...
                        sprintf("MAT file for import must include the following variables: %s.", ...
                        strjoin(obj.Model.ImportExportVariables, ", ")), "Invalid MAT File");
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
                [YearlyGrossIncome, PreTaxVoluntary, PostTax] = obj.Model.getForExport(); %#ok<ASGLU>
                DeductPension = obj.Model.DeductPension; %#ok<NASGU>
                PensionContribution = obj.Model.PensionContribution; %#ok<NASGU>
                
                % Save variables to file.
                save(fullfile(pathName, fileName), obj.Model.ImportExportVariables{:});
            end
        end % onExport
        
        function onCurrencyUpdate(obj, ~, ~)
            % ONCURRENCYUPDATE Internal function to download currency
            % conversion information from fixer.io.
            
            % Check if API key is empty.
            if isempty(obj.Model.CurrencyAPI)
                % Call UI dialog app.
                obj.createDialog(getRootFigure(obj), ...
                    "element.window.CurrencyAPIHandler", ...
                    "ParentPosition", getRootFigure(obj).Position, ...
                    "OKFcn", @obj.onCurrencyOK);
            else
                % Try downloading updated currency conversions.
                obj.evalErrorHandler("obj.Model.downloadCurrencyConversion(obj.Model.CurrencyAPI);", ...
                    "api", getRootFigure(obj));
            end
        end % onCurrencyUpdate
        
        function onTaxNIUpdate(obj, ~, ~)
            % ONTAXNIUPDATE Internal function to update the tax-National
            % Insurance information based on the income-tax.co.uk APIs.
            
            % Call UI dialog app.
            obj.createDialog(getRootFigure(obj), ...
                "element.window.TaxAPIHandler", ...
                "ParentPosition", getRootFigure(obj).Position, ...
                "OKFcn", @obj.onTaxNIOK);
        end % onTaxNIUpdate
        
    end % methods (Access = private)
    
    methods (Access = private)
        
        function onCurrencyOK(obj, ~, ~)
            % ONCURRENCYOK Internal function to store API key to MAT file.
            
            % Retrieve value.
            APIKey = obj.Dialog.InputValue; %#ok<NASGU>
            
            % Try downloading updated currency conversions.
            obj.evalErrorHandler("obj.Model.downloadCurrencyConversion(APIKey);", ...
                "api", getRootFigure(obj));
        end % onCurrencyOK
        
        function onTaxNIOK(obj, ~, ~)
            % ONTAXNIOK Internal function to download new tax and
            % National Insurance information based on input API key.
            
            % Retrieve edit field value.
            APIKey = obj.Dialog.InputValue; %#ok<NASGU>
            
            % Try downloading new tax and National Insurance information.
            obj.evalErrorHandler("obj.Model.downloadTaxNationalInsurance(APIKey);", ...
                "api", getRootFigure(obj));
        end % onTaxNIOK
        
    end % methods (Access = private)
    
end