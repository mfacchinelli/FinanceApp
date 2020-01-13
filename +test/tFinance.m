classdef tFinance < matlab.unittest.TestCase
    
    properties
        % Variable for Finance model.
        Model Finance
        % Deduction value.
        Deduction = struct("Name", "MATLAB", "Deduction", 100, ...
            "Currency", "GBP", "Recurrence", "Monthly");
    end % properties
    
    properties (TestParameter)
        % Values of valid income.
        ValidIncome = {0, 25000, 75000, 150000, 200000};
        % Values of invalid income.
        InvalidIncome = {-10000, 250000};
        % Values of known tax for valid incomes.
        KnownTax = {0, 2500, 17500, 52500, 72500};
        % Values of known national insurance for valid income.
        KnownNationalInsurance = {0, 1964, 5464, 6964, 7964};
        % Values of valid currency.
        ValidCurrency = cellstr(Finance.AllowedCurrencies);
        % Values of invalid currency.
        InvalidCurrency = {"JPY"};
        % Values of valid recurrence.
        ValidRecurrence = cellstr(Finance.AllowedRecurrence);
        % Values of invalid recurrence.
        InvalidRecurrence = {"Secondly"};
    end % properties (TestParameter)
    
    methods (TestMethodSetup)
        
        function deleteMATFiles(~)
%             warning("off", "MATLAB:DELETE:FileNotFound")
            
            % Delete currency file.
            delete(Finance.CurrencyFile);
            
            % Delete tax-NI file.
            delete(Finance.TaxNIFile);
            
            % Delete deductions history.
            delete(Finance.Session);
            
%             warning("on", "MATLAB:DELETE:FileNotFound")
        end % deleteMATFiles
        
        function createModel(obj)
            % Create Finance model.
            obj.Model = Finance();
        end % createModel
        
    end % methods (TestMethodSetup)
    
    methods (Test, ParameterCombination = "sequential")
        % Test set methods for class properties.
        
        function setValidIncome(obj, ValidIncome)
            % Set gross income.
            obj.Model.GrossIncome = ValidIncome;
            
            % Check value.
            obj.fatalAssertEqual(ValidIncome, obj.Model.GrossIncome)
        end % setValidIncome
        
        function setInvalidIncome(obj, InvalidIncome)
            % Set gross income and check error.
            if InvalidIncome < 0
                obj.fatalAssertError(@() set(obj.Model, "GrossIncome", InvalidIncome), ...
                    "Finance:GrossIncome:LowerBound");
            else
                obj.fatalAssertError(@() set(obj.Model, "GrossIncome", InvalidIncome), ...
                    "Finance:GrossIncome:UpperBound");
            end
        end % setInvalidIncome
        
        function setValidCurrency(obj, ValidCurrency)
            % Set currency.
            obj.Model.Currency = string(ValidCurrency);
        end % setValidCurrency
        
        function setInvalidCurrency(obj, InvalidCurrency)
            % Set currency.
            obj.fatalAssertError(@() set(obj.Model, "Currency", string(InvalidCurrency)), ...
                "MATLAB:validators:mustBeMemberGenericText");
        end % setInvalidCurrency
        
        function setValidRecurrence(obj, ValidRecurrence)
            % Set recurrence.
            obj.Model.Recurrence = string(ValidRecurrence);
        end % setValidRecurrence
        
        function setInvalidRecurrence(obj, InvalidRecurrence)
            % Set currency.
            obj.fatalAssertError(@() set(obj.Model, "Recurrence", string(InvalidRecurrence)), ...
                "MATLAB:validators:mustBeMemberGenericText");
        end % setInvalidRecurrence
        
    end % methods (Test, ParameterCombination = "sequential")
    
    methods (Test, ParameterCombination = "sequential")
        % Test get methods for class properties.
        
        function getNetIncome(obj, ValidIncome, KnownTax, KnownNationalInsurance)
            % Set income to specific values.
            obj.Model.GrossIncome = ValidIncome;
            
            % Check values.
            obj.fatalAssertEqual(obj.Model.Tax, KnownTax);
            obj.fatalAssertEqual(obj.Model.NationalInsurance, KnownNationalInsurance);
            obj.fatalAssertEqual(obj.Model.NetIncome, ValidIncome - KnownTax - KnownNationalInsurance);
        end % getNetIncome
        
    end % methods (Test, ParameterCombination = "sequential")
    
    methods (Test)
        % Test addition and removal of deductions.
        
        function addPreTaxVoluntaryDeductions(obj)
            % Add pre-tax voluntary deduction.
            obj.Model.addPreTaxVoluntaryDeduction(obj.Deduction.Name, obj.Deduction.Deduction, ...
                obj.Deduction.Currency, obj.Deduction.Recurrence);
            
            % Check value.
            obj.fatalAssertEqual(struct2table(obj.Deduction), obj.Model.PreTaxVoluntary);
        end % addPreTaxVoluntaryDeductions
        
        function addPostTaxDeductions(obj)
            % Add post-tax voluntary deduction.
            obj.Model.addPostTaxDeduction(obj.Deduction.Name, obj.Deduction.Deduction, ...
                obj.Deduction.Currency, obj.Deduction.Recurrence);
            
            % Check value.
            obj.fatalAssertEqual(struct2table(obj.Deduction), obj.Model.PostTax);
        end % addPostTaxDeductions
        
        function removeSpecificPreTaxVoluntaryDeductions(obj)
            % Add pre-tax voluntary deductions.
            obj.Model.addPreTaxVoluntaryDeduction(obj.Deduction.Name, obj.Deduction.Deduction, ...
                obj.Deduction.Currency, obj.Deduction.Recurrence);
            obj.Model.addPreTaxVoluntaryDeduction(obj.Deduction.Name, obj.Deduction.Deduction, ...
                obj.Deduction.Currency, obj.Deduction.Recurrence);
            
            % Remove first deduction.
            obj.Model.removePreTaxVoluntaryDeduction(1);
            
            % Check value.
            obj.fatalAssertEqual(struct2table(obj.Deduction), obj.Model.PreTaxVoluntary);
        end % removeSpecificPreTaxVoluntaryDeductions
        
        function removeSpecificPostTaxDeductions(obj)
            % Add post-tax voluntary deductions.
            obj.Model.addPostTaxDeduction(obj.Deduction.Name, obj.Deduction.Deduction, ...
                obj.Deduction.Currency, obj.Deduction.Recurrence);
            obj.Model.addPostTaxDeduction(obj.Deduction.Name, obj.Deduction.Deduction, ...
                obj.Deduction.Currency, obj.Deduction.Recurrence);
            
            % Remove all deductions.
            obj.Model.removePostTaxDeduction(1);
            
            % Check value.
            obj.fatalAssertEqual(struct2table(obj.Deduction), obj.Model.PostTax);
        end % removeSpecificPostTaxDeductions
        
        function removeAllPreTaxVoluntaryDeductions(obj)
            % Add pre-tax voluntary deduction.
            obj.Model.addPreTaxVoluntaryDeduction(obj.Deduction.Name, obj.Deduction.Deduction, ...
                obj.Deduction.Currency, obj.Deduction.Recurrence);
            
            % Remove all deductions.
            obj.Model.deletePreTaxVoluntaryDeductions();
            
            % Check value.
            obj.fatalAssertEmpty(obj.Model.PreTaxVoluntary);
        end % removeAllPreTaxVoluntaryDeductions
        
        function removeAllPostTaxDeductions(obj)
            % Add post-tax voluntary deduction.
            obj.Model.addPostTaxDeduction(obj.Deduction.Name, obj.Deduction.Deduction, ...
                obj.Deduction.Currency, obj.Deduction.Recurrence);
            
            % Remove all deductions.
            obj.Model.deletePostTaxDeductions();
            
            % Check value.
            obj.fatalAssertEmpty(obj.Model.PostTax);
        end % removeAllPostTaxDeductions
        
    end % methods (Test)
    
end