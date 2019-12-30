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
        % Button for update of API key for fixer.io.
        CurrencyAPIButton matlab.ui.control.Button
        % Button for currency conversion update.
        CurrencyUpdateButton matlab.ui.control.Button
        % Edit field for tax-NI last update.
        TaxNIEditField matlab.ui.control.EditField
        % Button for tax-NI update.
        TaxNIButton matlab.ui.control.Button
    end % properties (Access = private)
    
    properties (Constant, Access = private)
        % Array of variables for import and export of MAT file.
        ImportExportVariables = ["grossIncome", "preTaxDeductions", ...
            "postTaxDeductions", "deductPension", "pensionContribution"]
    end % properties (Constant, Access = private)
    
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
                "ColumnWidth", ["1x", "1x"], ...
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
            obj.TaxNIEditField.Value = datestr(obj.Model.TaxNIUpdate, "dd mmmm yyyy");
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
                "ButtonPushedFcn", @(~, ~) onImport(obj));
            obj.ImportButton.Layout.Row = 3;
            obj.ImportButton.Layout.Column = [1, 2];
            
            % Create export button.
            obj.ExportButton = uibutton(obj.DeductionsGrid, "push", ...
                "Text", "Export Deductions MAT", ...
                "ButtonPushedFcn", @(~, ~) onExport(obj));
            obj.ExportButton.Layout.Row = 3;
            obj.ExportButton.Layout.Column = [3, 4];
            
            % Create import button.
            obj.CurrencyAPIButton = uibutton(obj.CurrencyGrid, "push", ...
                "Text", "Set API for fixer.io", ...
                "ButtonPushedFcn", @(~, ~) onCurrencyAPI(obj));
            obj.CurrencyAPIButton.Layout.Row = 1;
            obj.CurrencyAPIButton.Layout.Column = 1;
            
            % Create export button.
            obj.CurrencyUpdateButton = uibutton(obj.CurrencyGrid, "push", ...
                "Text", "Update", ...
                "ButtonPushedFcn", @(~, ~) onCurrencyUpdate(obj));
            obj.CurrencyUpdateButton.Layout.Row = 1;
            obj.CurrencyUpdateButton.Layout.Column = 2;
            
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
                "ButtonPushedFcn", @(~, ~) onTaxNIUpdate(obj));
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
                    obj.Model.setFromImport(grossIncome, preTaxDeductions, postTaxDeductions);
                    obj.Model.DeductPension = deductPension;
                    obj.Model.PensionContribution = pensionContribution;
                else
                    uialert(getRootFigure(obj), ...
                        sprintf("MAT file for import must include the following variables: %s.", ...
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
                [grossIncome, preTaxDeductions, postTaxDeductions] = obj.Model.getForExport(); %#ok<ASGLU>
                deductPension = obj.Model.DeductPension; %#ok<NASGU>
                pensionContribution = obj.Model.PensionContribution; %#ok<NASGU>
                
                % Save variables to file.
                save(fullfile(pathName, fileName), obj.ImportExportVariables{:});
            end
        end % onExport
        
        function onCurrencyAPI(obj)
            % ONCURRENCYAPI Internal function to ask user for API key to
            % fixer.io. Free account is required.
            
            % Call UI dialog app.
            obj.createDialog(getRootFigure(obj), ...
                "element.window.CurrencyAPIHandler", ...
                "ParentPosition", getRootFigure(obj).Position, ...
                "OKFcn", @obj.onCurrencyOK);
        end % onCurrencyAPI
        
        function onCurrencyUpdate(obj)
            % ONCURRENCYUPDATE Internal function to download currency
            % conversion information from fixer.io.
            
            % Check for MAT file containing currency API key.
            if exist(obj.Model.CurrencyFile, "file")
                % Load API key.
                load(obj.Model.CurrencyFile, "APIKey");
                
                % Check that API key is not empty and valid.
                if isempty(APIKey) || ~(isstring(APIKey) || ischar(APIKey))
                    % Delete any previous window.
                    obj.Dialog.delete();
                    
                    % Reset API key.
                    obj.onCurrencyAPI();
                else
                    % Try downloading data.
                    try
                        % Download conversions.
                        [EUR2GBP, USD2GBP] = currency.downloadConversions(APIKey);
                        
                        % Store values.
                        obj.Model.setCurrencyConversion(EUR2GBP, USD2GBP);
                    catch exception
                        if strcmp(exception.identifier, "MATLAB:webservices:ContentTypeReaderError")
                            uialert(getRootFigure(obj), ...
                                ["Input API key is not valid. Please download the current one from: ", ...
                                "https://www.income-tax.co.uk/tax-calculator-api/"], ...
                                "Invalid API Key");
                        else
                            uialert(getRootFigure(obj), exception.message, ...
                                sprintf("Caught Exception - %s", exception.identifier));
                        end
                    end
                end
            else
                % Set API key.
                obj.onCurrencyAPI();
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
            APIKey = obj.Dialog.EditFieldValue;
            
            % Save value to MAT file.
            save(obj.Model.CurrencyFile, "APIKey");
            
            % Call function to download currency conversions.
            obj.onCurrencyUpdate();
        end % onCurrencyOK
        
        function onTaxNIOK(obj, ~, ~)
            % ONTAXNIOK Internal function to download new tax and
            % National Insurance information based on input API key.
            
            % Retrieve edit field value.
            APIKey = obj.Dialog.EditFieldValue;
            
            % Try downloading new data.
            try
                % Download new tax and National Insurance information.
                [taxNIMatrix, updateDate] = taxni.downloadTaxNI(APIKey, obj.Model.InflectionValues);
                
                % Save values to MAT file.
                save(obj.Model.TaxNIFile, "taxNIMatrix", "updateDate");
                
                % Invoke load function for MAT file.
                obj.Model.loadTaxNIInformation();
            catch exception
                if strcmp(exception.identifier, "MATLAB:webservices:ContentTypeReaderError")
                    uialert(getRootFigure(obj), ...
                        ["Input API key is not valid. Please download the current one from: ", ...
                        "https://www.income-tax.co.uk/tax-calculator-api/"], ...
                        "Invalid API Key");
                else
                    uialert(getRootFigure(obj), exception.message, ...
                        sprintf("Caught Exception - %s", exception.identifier));
                end
            end
        end % onTaxNIOK
        
    end % methods (Access = private)
    
end