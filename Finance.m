classdef (Sealed) Finance < matlab.mixin.SetGetExactNames
    
    properties (Dependent, AbortSet)
        % Value of gross (pre-tax) income in GBP.
        GrossIncome (1, 1) double
    end % properties (Dependent, AbortSet)
    
    properties (Dependent, SetAccess = private)
        % Value of net (post-tax) income in GBP.
        NetIncome
        % Value of taxes.
        Tax
        % Value of National Insurance.
        NationalInsurance
        % Value of pension.
        Pension
    end % properties (Dependent, SetAccess = private)
    
    properties (AbortSet, SetObservable)
        % Logical denoting whether pension has been added.
        DeductPension (1, 1) logical = false
        % Value of pre-tax pension contribution.
        PensionContribution (1, 1) double {mustBeNonnegative, ...
            mustBeLessThanOrEqual(PensionContribution, 100)} = 0
        % Value describing how to divide income.
        Recurrence (1, 1) categorical {mustBeRecurrence} = "Yearly"
        % Value describing default currency.
        Currency (1, 1) categorical {mustBeCurrency} = "GBP"
        % Number of work days per week.
        WeeklyWorkDays (1, 1) double {mustBePositive, mustBeInteger, ...
            mustBeLessThanOrEqual(WeeklyWorkDays, 7)} = 5
        % Number of work hours per day.
        DailyWorkHours (1, 1) double {mustBePositive, ...
            mustBeLessThanOrEqual(DailyWorkHours, 24)} = 7.5
    end % properties (AbortSet, SetObservable)
    
    properties (SetAccess = private)
        % Table of voluntary pre-tax deductions.
        PreTax table = getEmptyDeductionTable()
        % Table of post-tax deductions.
        PostTax table = getEmptyDeductionTable()
        % Conversion from GBP to EUR.
        EUR2GBP double = 0.85
        % Conversion from GBP to USD.
        USD2GBP double = 0.75
    end % properties (SetAccess = private)
    
    properties (Dependent, SetAccess = private)
        % Value of minimum income of tabulated data.
        MinIncome
        % Value of maximum income of tabulated data.
        MaxIncome
    end % properties (Dependent, SetAccess = private)
    
    properties (Dependent, SetAccess = private, GetAccess = ?element.Component)
        % Combined values of tax and National Insurance as deduction table.
        TaxNITable
        % Combined values of all deductions.
        Deductions
    end % properties (Dependent, SetAccess = private, GetAccess = ?element.Component)
    
    properties (Access = private)
        % Private value of gross income.
        YearlyGrossIncome double = 100000
        % Value of minimum yearly income of tabulated data.
        MinYearlyIncome double
        % Value of maximum yearly income of tabulated data.
        MaxYearlyIncome double
        % Private value of net income.
        YearlyNetIncome double
        % Private value of tax and National Insurance.
        YearlyTaxNI double
        % Matrix containing tax and National Insurance values as a function
        % of gross income.
        TaxNIMatrix double
    end % properties (Access = private)
    
    properties (Access = ?element.hybrid.SettingsViewController)
        % Date denoting last time the tax and National Insurance
        % information was updated.
        TaxNIUpdate datetime
    end % properties (Access = ?element.hybrid.SettingsViewController)
    
    properties (Constant)
        % Values of allowed currencies.
        AllowedCurrencies = ["GBP", "EUR", "USD"]
        % Values of allowed recurrence.
        AllowedRecurrence = ["Yearly", "Monthly", "Weekly", "Daily", "Hourly"]
        % Inflection points in gross income for tax and National Insurance.
        InflectionValues = [0, 12500, 50000, 150000, 200000]
        % Name of MAT file containing currency conversion values.
        CurrencyFile = getCurrencyFile()
        % Name of MAT file containing UK tax and National Insurance values.
        TaxNIFile = getTaxNIFile()
    end % properties (Constant)
    
    properties (Constant, Access = private)
        % Name of MAT file where current session is saved.
        Session = getSessionFile()
    end % properties (Constant, Access = private)
    
    events
        % Event notifying update of finance model.
        Update
    end % events
    
    methods
        
        function obj = Finance(varargin)
            % Set tax-NI information.
            obj.loadTaxNIInformation();
            
            % Load previous session.
            obj.load();
            
            % Create listeners for 'SetObservable' properties.
            obj.addSetObservableListeners();
            
            % Set data.
            set(obj, varargin{:})
            
            % Update finances.
            obj.update();
        end % constructor
        
        function delete(obj)
            % Save current session.
            obj.save();
        end % destructor
        
        function set.GrossIncome(obj, value)
            % Convert value to yearly recurrence.
            yearlyIncome = obj.convertTo(obj.Currency, obj.Recurrence, value);
            
            % Check that value of gross income is between minumum and
            % maximum of tabulated values.
            assert(yearlyIncome >= obj.MinYearlyIncome, "Finance:GrossIncome:LowerBound", ...
                "Value of yearly gross income must be larger or equal to %d.", obj.MinYearlyIncome)
            assert(yearlyIncome <= obj.MaxYearlyIncome, "Finance:GrossIncome:UpperBound", ...
                "Value of yearly gross income must be lower or equal to %d.", obj.MaxYearlyIncome)
            
            % Store value.
            obj.YearlyGrossIncome = yearlyIncome;
            
            % Update finances.
            obj.update();
        end % set.GrossIncome
        
        function value = get.GrossIncome(obj)
            value = obj.convertFrom(obj.Currency, obj.Recurrence, obj.YearlyGrossIncome);
        end % get.GrossIncome
        
        function set.NetIncome(obj, value)
            obj.YearlyNetIncome = obj.convertTo(obj.Currency, obj.Recurrence, value);
        end % set.NetIncome
        
        function value = get.NetIncome(obj)
            value = obj.convertFrom(obj.Currency, obj.Recurrence, obj.YearlyNetIncome);
        end % get.NetIncome
        
        function value = get.Tax(obj)
            value = obj.convertFrom(obj.Currency, obj.Recurrence, obj.YearlyTaxNI(1));
        end % get.Tax
        
        function value = get.NationalInsurance(obj)
            value = obj.convertFrom(obj.Currency, obj.Recurrence, obj.YearlyTaxNI(2));
        end % get.NationalInsurance
        
        function value = get.Pension(obj)
            % Check if pension deduction is toggled.
            if obj.DeductPension
                value = obj.convertFrom(obj.Currency, obj.Recurrence, ...
                    obj.YearlyGrossIncome * obj.PensionContribution / 100);
            else
                value = 0;
            end
        end % get.Pension
        
        function value = get.MinIncome(obj)
            value = obj.convertFrom(obj.Currency, obj.Recurrence, obj.MinYearlyIncome);
        end % get.MinIncome
        
        function value = get.MaxIncome(obj)
            value = obj.convertFrom(obj.Currency, obj.Recurrence, obj.MaxYearlyIncome);
        end % get.MaxIncome
        
        function value = get.TaxNITable(obj)
            % Get empty deduction table.
            value = getEmptyDeductionTable();
            
            % Add tax and National Insurance values.
            value(end+1, :) = {"Tax", obj.Tax, obj.Recurrence, "GBP"};
            
            value(end+1, :) = {"National Insurance", obj.NationalInsurance, ...
                obj.Recurrence, "GBP"};
            
            % Add pension.
            if obj.DeductPension
                value(end+1, :) = {"Pension", obj.Pension, obj.Recurrence, "GBP"};
            end
        end % get.TaxNITable
        
        function value = get.Deductions(obj)
            % Sum pre-tax voluntary contributions.
            value(1) = obj.convertFrom(obj.Currency, obj.Recurrence, ...
                sum(arrayfun(@(i) obj.convertTo(obj.PreTax.Currency(i), obj.PreTax.Recurrence(i), ...
                obj.PreTax.Deduction(i)), 1:size(obj.PreTax, 1))));
            
            % Sum pre-tax compulsory contributions.
            value(2) = obj.convertFrom(obj.Currency, obj.Recurrence, sum(obj.YearlyTaxNI)) + obj.Pension;
            
            % Sum post-tax contributions.
            value(3) = obj.convertFrom(obj.Currency, obj.Recurrence, ...
                sum(arrayfun(@(i) obj.convertTo(obj.PostTax.Currency(i), obj.PostTax.Recurrence(i), ...
                obj.PostTax.Deduction(i)), 1:size(obj.PostTax, 1))));
        end % get.Deductions
        
    end % methods
    
    methods (Access = public)
        
        function addPreTaxDeduction(obj, name, deduction, currency, recurrence)
            % ADDPRETAXDEDUCTION Add one pre-tax deduction by specifying
            % name, deduction value, currency and recurrence. This
            % deduction will be subtracted from the pre-tax income value,
            % before the computation of tax and National Insurance.
            
            % Check data.
            narginchk(5, 5)
            assert(isstring(name), "Finance:PreTax:InvalidName", "Name must be of type string.")
            assert(isnumeric(deduction), "Finance:PreTax:InvalidDeduction", "Deduction must be of type numeric.")
            try mustBeCurrency(currency); catch
                error("Finance:PreTax:InvalidCurrency", ...
                    "Currency must be member of: %s.", strjoin(obj.AllowedCurrencies, ", "))
            end
            try mustBeRecurrence(recurrence); catch
                error("Finance:PreTax:InvalidRecurrence", ...
                    "Recurrence must be member of: %s.", strjoin(obj.AllowedRecurrence, ", "))
            end
            
            % Add data to pre-tax table.
            obj.PreTax(end+1, :) = {name, deduction, currency, recurrence};
            
            % Update finances.
            obj.update();
        end % addPreTaxDeduction
        
        function addPostTaxDeduction(obj, name, deduction, currency, recurrence)
            % ADDPOSTTAXDEDUCTION Add one post-tax deduction by specifying
            % name, deduction value, currency and recurrence. This
            % deduction will be subtracted from the post-tax income value.
            
            % Check data.
            narginchk(5, 5)
            assert(isstring(name), "Finance:PostTax:InvalidName", "Name must be of type string.")
            assert(isnumeric(deduction), "Finance:PostTax:InvalidDeduction", "Deduction must be of type numeric.")
            try mustBeCurrency(currency); catch
                error("Finance:PostTax:InvalidCurrency", ...
                    "Currency must be member of: %s.", strjoin(obj.AllowedCurrencies, ", "))
            end
            try mustBeRecurrence(recurrence); catch
                error("Finance:PostTax:InvalidRecurrence", ...
                    "Recurrence must be member of: %s.", strjoin(obj.AllowedRecurrence, ", "))
            end
            
            % Add data to post-tax table.
            obj.PostTax(end+1, :) = {name, deduction, currency, recurrence};
            
            % Update finances.
            obj.update();
        end % addPostTaxDeduction
        
        function removePreTaxDeduction(obj, rowNumbers)
            % REMOVEPRETAXDEDUCTION Remove one or more pre-tax deductions
            % by specifying the row value. This deduction will be removed
            % from the pre-tax list.
            
            % Check data.
            narginchk(2, 2)
            assert(isnumeric(rowNumbers), "Finance:PreTax:InvalidRow", "Row values must be numeric.")
            assert(all(rowNumbers > 0), "Finance:PreTax:InvalidRow", "Row number must be positive.")
            assert(all(rowNumbers <= size(obj.PreTax, 1)), "Finance:PreTax:InvalidRow", ...
                "Row specified does not exist. Maximum value is %d.", size(obj.PreTax, 1))
            
            % Remove data from pre-tax table.
            obj.PreTax(rowNumbers, :) = [];
            
            % Update finances.
            obj.update();
        end % removePreTaxDeduction
        
        function removePostTaxDeduction(obj, rowNumbers)
            % REMOVEPOSTTAXDEDUCTION Remove one or more post-tax deductions
            % by specifying the row value. This deduction will be removed
            % from the post-tax list.
            
            % Check data.
            narginchk(2, 2)
            assert(isnumeric(rowNumbers), "Finance:PostTax:InvalidRow", "Row values must be numeric.")
            assert(all(rowNumbers > 0), "Finance:PostTax:InvalidRow", "Row number must be positive.")
            assert(all(rowNumbers <= size(obj.PostTax, 1)), "Finance:PostTax:InvalidRow", ...
                "Row specified does not exist. Maximum value is %d.", size(obj.PostTax, 1))
            
            % Remove data from post-tax table.
            obj.PostTax(rowNumbers, :) = [];
            
            % Update finances.
            obj.update();
        end % removePostTaxDeduction
        
        function deletePreTaxDeductions(obj)
            % DELETEPRETAXDEDUCTIONS Delete all pre-tax voluntary
            % deductions.
            
            % Empty table of pre-tax deductions.
            obj.PreTax = getEmptyDeductionTable();
            
            % Update finances.
            obj.update();
        end % deletePreTaxDeductions
        
        function deletePostTaxDeductions(obj)
            % DELETEPOSTTAXDEDUCTIONS Delete all post-tax voluntary
            % deductions.
            
            % Empty table of post-tax deductions.
            obj.PostTax = getEmptyDeductionTable();
            
            % Update finances.
            obj.update();
        end % deletePostTaxDeductions
        
    end % methods (Access = public)
    
    methods (Access = ?element.hybrid.SettingsViewController)
        
        function setFromImport(obj, grossIncome, preTaxDeductions, postTaxDeductions)
            % SETFROMIMPORT Function to set values of yearly gross income,
            % and pre-tax and post-tax deductions from MAT file.
            
            % Store values.
            obj.YearlyGrossIncome = grossIncome;
            obj.PreTax = preTaxDeductions;
            obj.PostTax = postTaxDeductions;
        end % setFromImport
        
        function [grossIncome, preTaxDeductions, postTaxDeductions] = getForExport(obj)
            % GETFOREXPORT Function to get values of yearly gross income,
            % and pre-tax and post-tax deductions for export to MAT file.
            
            % Store values.
            grossIncome = obj.YearlyGrossIncome;
            preTaxDeductions = obj.PreTax;
            postTaxDeductions = obj.PostTax;
        end % setFromImport
        
        function setCurrencyConversion(obj, EUR2GBP, USD2GBP)
            % SETCURRENCYCONVERSION Function to set values of conversion
            % for currencies (EUR and USD) to GBP.
            
            % Store values.
            obj.EUR2GBP = EUR2GBP;
            obj.USD2GBP = USD2GBP;
            
            % Update finance.
            obj.update();
        end
        
        function loadTaxNIInformation(obj)
            % LOADTAXNIINFORMATION Function to load tax and National
            % Insurance information from MAT file.
            
            % Load MAT file.
            load(obj.TaxNIFile, "taxNIMatrix", "updateDate");
            
            % Store values.
            obj.TaxNIMatrix = taxNIMatrix;
            obj.TaxNIUpdate = updateDate;
            
            % Determine values of minumum and maximum of tabulated values.
            obj.MinYearlyIncome = min(obj.TaxNIMatrix(:, 1));
            obj.MaxYearlyIncome = max(obj.TaxNIMatrix(:, 1));
            
            % Update finance.
            obj.update();
        end % loadTaxNIInformation
        
    end % methods (Access = ?element.hybrid.SettingsViewController)
    
    methods (Access = private)
        
        function addSetObservableListeners(obj)
            % ADDSETOBSERVABLELISTENERS Internal function to add listeners
            % to properties with 'SetObservable' attribute. The callback
            % function is 'update' by default.
            
            % Extract list of properties with 'SetObservable' attribute.
            meta = ?Finance;
            props = string(arrayfun(@(x) x.Name, meta.PropertyList, 'UniformOutput', false));
            setObs = arrayfun(@(x) x.SetObservable, meta.PropertyList);
            
            % Loop over properties and add listener.
            for p = props(setObs)'
                addlistener(obj, p, "PostSet", @(~, ~) update(obj));
            end
        end % addSetObservableListeners
        
        function load(obj)
            % LOAD Internal function to load previous session of app. The
            % app loads a MAT file containing the gross income value and
            % the voluntary pre-tax and post-tax deductions.
            
            % Check that MAT file exists.
            if exist(obj.Session, "file")
                % Load MAT file.
                load(obj.Session, "grossIncome", "preTaxDeductions", "postTaxDeductions", ...
                    "deductPension", "pensionContribution");
                
                % Store values.
                obj.setFromImport(grossIncome, preTaxDeductions, postTaxDeductions);
                obj.DeductPension = deductPension;
                obj.PensionContribution = pensionContribution;
            end
        end % load
        
        function save(obj)
            % SAVE Internal function to save current session of app. The
            % app saves a MAT file containing the gross income value and
            % the voluntary pre-tax and post-tax deductions.
            
            % Check that persistent folder exists.
            if ~(ismcc || isdeployed) && ~exist(fileparts(obj.Session), "dir")
                mkdir(fileparts(obj.Session))
            end
            
            % Retrieve values.
            grossIncome = obj.YearlyGrossIncome;
            preTaxDeductions = obj.PreTax;
            postTaxDeductions = obj.PostTax;
            deductPension = obj.DeductPension;
            pensionContribution = obj.PensionContribution;
            
            % Save MAT file.
            save(obj.Session, "grossIncome", "preTaxDeductions", "postTaxDeductions", ...
                "deductPension", "pensionContribution");
        end % save
        
        function update(obj)
            % UPDATE Internal function to update values of income based
            % tabulated tax and National Insurance, and on input pre-tax
            % and post-tax deductions.
            
            % Initial value;
            netIncome = obj.YearlyGrossIncome;
            
            % Subtract pre-tax voluntary and compulsory deductions.
            netIncome = obj.deductPreTax(netIncome);
            
            % Subtract post-tax deductions.
            netIncome = obj.deductPostTax(netIncome);
            
            % Save net income.
            obj.YearlyNetIncome = netIncome;
            
            % Notify listeners of update.
            obj.notify("Update");
        end % update
        
        function netIncome = deductPreTax(obj, netIncome)
            % DEDUCTPRETAX Internal function to subtract voluntary pre-tax
            % deductions. Voluntary pre-tax deductions are added with the
            % public method 'addPreTaxDeduction'.
            
            % Subtract pension.
            if obj.DeductPension
                netIncome = netIncome - netIncome * obj.PensionContribution / 100;
            end
            
            % For each entry, subtract from income.
            for d = 1:size(obj.PreTax, 1)
                % Convert to yearly.
                yearlyDeduction = obj.convertTo(obj.PreTax.Currency(d), ...
                    obj.PreTax.Recurrence(d), obj.PreTax.Deduction(d));
                
                % Subtract from income.
                netIncome = netIncome - yearlyDeduction;
            end
            
            % Retrieve tax-NI information for current gross income.
            obj.YearlyTaxNI = interp1(obj.TaxNIMatrix(:, 1), obj.TaxNIMatrix(:, 2:3), netIncome, "linear", NaN);
            
            % Subtract tax and National Insurance, as last pre-tax deductions.
            netIncome = netIncome - sum(obj.YearlyTaxNI);
        end % deductPreTax
        
        function netIncome = deductPostTax(obj, netIncome)
            % DEDUCTPOSTTAX Internal function to subtract voluntary
            % post-tax deductions. Post-tax deductions are added with the
            % public method 'addPostTaxDeduction'.
            
            % For each entry, subtract from income.
            for d = 1:size(obj.PostTax, 1)
                % Convert to yearly.
                yearlyDeduction = obj.convertTo(obj.PostTax.Currency(d), ...
                    obj.PostTax.Recurrence(d), obj.PostTax.Deduction(d));
                
                % Subtract from income.
                netIncome = netIncome - yearlyDeduction;
            end
        end % deductPostTax
        
        function value = convertTo(obj, currency, recurrence, value)
            % CONVERTTO Internal function to convert value to GBP and
            % yearly recurrence from speficied currency and recurrence.
            
            % Convert to GBP from specified currency.
            value = obj.convertCurrency(@times, currency, value, obj.EUR2GBP, obj.USD2GBP);
            
            % Convert to yearly from specified recurrence.
            value = obj.convertRecurrence(@times, recurrence, value, obj.WeeklyWorkDays, obj.DailyWorkHours);
        end % convertTo
        
        function value = convertFrom(obj, currency, recurrence, value)
            % CONVERTFROM Internal function to convert value from GBP and
            % yearly recurrence to speficied currency and recurrence.
            
            % Convert from GBP to specified currency.
            value = obj.convertCurrency(@rdivide, currency, value, obj.EUR2GBP, obj.USD2GBP);
            
            % Convert from yearly to specified recurrence.
            value = obj.convertRecurrence(@rdivide, recurrence, value, obj.WeeklyWorkDays, obj.DailyWorkHours);
        end % convertFrom
        
    end % methods (Access = private)
    
    methods (Static, Access = private)
        
        function value = convertCurrency(operator, currency, value, EUR2GBP, USD2GBP)
            % CONVERTCURRENCY Convert currency with respect to GBP, based
            % on input operator.
            
            % Convert based on currency.
            switch currency
                case "GBP"
                    % Do nothing.
                case "EUR"
                    value = operator(value, EUR2GBP);
                case "USD"
                    value = operator(value, USD2GBP);
                otherwise
                    error("Finance:Currency:UnknownInput", ...
                        "Currency '%s' is unknown and unsupported.", recurrence)
            end
        end
        
        function value = convertRecurrence(operator, recurrence, value, workDays, workHours)
            % CONVERTRECURRENCE Convert recurrence with respect to yearly,
            % based on input operator.
            
            % Convert based on time recurrence.
            switch recurrence
                case "Yearly"
                    % Do nothing.
                case "Monthly"
                    value = operator(value, 12);
                case "Weekly"
                    value = operator(value, 12 * 4);
                case "Daily"
                    value = operator(value, 12 * 4 * workDays);
                case "Hourly"
                    value = operator(value, 12 * 4 * workDays * workHours);
                otherwise
                    error("Finance:Recurrence:UnknownInput", ...
                        "Recurrence '%s' is unknown and unsupported.", recurrence)
            end
        end % convertRecurrence
        
    end % methods (Static, Access = private)
    
end

function mustBeCurrency(property)
% MUSTBECURRENCY Determine whether input value is part of the allowed
% currencies: GBP, EUR, or USD.

% Invoke internal function for member validation.
mustBeMember(property, categorical(Finance.AllowedCurrencies))

end % mustBeCurrency

function mustBeRecurrence(property)
% MUSTBERECURRENCE Determine whether input value is part of the allowed
% recurrence: Yearly, Monthly, Weekly, Daily, or Hourly.

% Invoke internal function for member validation.
mustBeMember(property, categorical(Finance.AllowedRecurrence))

end % mustBeRecurrence

function t = getEmptyDeductionTable()
% GETEMPTYDEDUCTIONSTABLE Function to return an empty deductions table to
% be used as visualization purposes.

% Create empty table with deductions properties.
t = table('Size', [0, 4], 'VariableTypes', ["string", "double", "categorical", "categorical"], ...
    'VariableNames', ["Name", "Deduction", "Currency", "Recurrence"]);
t.Currency = setcats(t.Currency, Finance.AllowedCurrencies);
t.Recurrence = setcats(t.Recurrence, Finance.AllowedRecurrence);

end % getEmptyDeductionTable

function sessionFile = getSessionFile()
% GETSESSIONFILE Function to return the name of the file to load previous
% session and store current one.

% Hard-code file based on execution.
if ismcc || isdeployed
    sessionFile = which("deductions.mat");
else
    sessionFile = fullfile("persistent", "deductions.mat");
end

end % getSessionFile

function taxNIFile = getTaxNIFile()
% GETTAXNIMATRIX Function to return the tax-NI file downloaded using
% income-tax.co.uk APIs.

% Get tax-NI information.
if ismcc || isdeployed
    taxNIFile = which("taxNIInfo.mat");
else
    taxNIFile = fullfile("persistent", "taxNIInfo.mat");
end

end % getTaxNIMatrix

function currencyFile = getCurrencyFile()
% GETCURRENCYFILE Function to return the file where the currency API key
% for fixer.io is stored.

% Get currency information.
if ismcc || isdeployed
    currencyFile = which("currencyAPI.mat");
else
    currencyFile = fullfile("persistent", "currencyAPI.mat");
end

end % getCurrencyFile