classdef (Sealed) Finance < matlab.mixin.SetGetExactNames
    
    properties (Dependent)
        % Value of gross (pre-tax) income in GBP.
        GrossIncome (1, 1) double
    end % properties (Dependent)
    
    properties (Dependent, SetAccess = private)
        % Value of net (post-tax) income in GBP.
        NetIncome
        % Value of taxes.
        Tax
        % Value of National Insurance.
        NationalInsurance
    end % properties (Dependent, SetAccess = private)
    
    properties (Dependent)
        % Value describing how to divide income.
        Recurrence (1, 1) categorical {mustBeRecurrence}
        % Value describing default currency.
        Currency (1, 1) categorical {mustBeCurrency}
    end
    
    properties (SetAccess = private)
        % Table of voluntary pre-tax deductions.
        PreTax = getEmptyDeductionTable()
        % Table of post-tax deductions.
        PostTax = getEmptyDeductionTable()
    end % properties (Dependent, SetAccess = private)
    
    properties (Access = private)
        % Private value of gross income.
        YearlyGrossIncome = 100000
        % Private value of net income.
        YearlyNetIncome
        % Private value of tax and National Insurance.
        YearlyTaxNI
        % Private value of recurrence.
        Recurrence_ = "Yearly"
        % Valye describing default currency.
        Currency_ = "GBP"
    end % properties (Access = private)
    
    properties (Dependent)
        % Value of minimum income of tabulated data.
        MinIncome
        % Value of maximum income of tabulated data.
        MaxIncome
    end
    
    properties
        % Number of work days per week.
        WeeklyWorkDays (1, 1) double {mustBePositive, mustBeInteger, ...
            mustBeLessThanOrEqual(WeeklyWorkDays, 7)} = 5
        % Number of work hours per day.
        DailyWorkHours (1, 1) double {mustBePositive, ...
            mustBeLessThanOrEqual(DailyWorkHours, 24)} = 7.5
    end
    
    properties (SetAccess = immutable, GetAccess = private)
        % Value of minimum yearly income of tabulated data.
        MinYearlyIncome
        % Value of maximum yearly income of tabulated data.
        MaxYearlyIncome
    end
    
    properties (Dependent, SetAccess = private, GetAccess = ?component.Component)
        % Combined values of tax and National Insurance as deduction table.
        TaxNITable
        % Combined values of all deductions.
        Deductions
    end % properties (Hidden, Dependent, SetAccess = private)
    
    properties (Constant)
        % Values of allowed currencies.
        AllowedCurrencies = ["GBP"]%, "EUR", "USD"]
        % Values of allowed recurrence.
        AllowedRecurrence = ["Yearly", "Monthly", "Weekly", "Daily", "Hourly"]
    end
    
    properties (Constant, Access = private)
        % Name of MAT file where current session is saved.
        Session = getSessionFile()
        % UK tax and National Insurance matrix as a function of gross income.
        TaxNIMatrix = getTaxNIMatrix()
    end
    
    events
        % Event notifying update of finance model.
        Update
    end % events
    
    methods
        
        function obj = Finance(varargin)
            % Determine values of minumum and maximum of tabulated values.
            obj.MinYearlyIncome = min(obj.TaxNIMatrix(:, 1));
            obj.MaxYearlyIncome = max(obj.TaxNIMatrix(:, 1));
            
            % Load previous session.
            obj.load();
            
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
            yearlyIncome = obj.convertTo(obj.Recurrence, value);
            
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
            value = obj.convertFrom(obj.Recurrence, obj.YearlyGrossIncome);
        end % get.GrossIncome
        
        function set.NetIncome(obj, value)
            obj.YearlyNetIncome = obj.convertTo(obj.Recurrence, value);
        end % set.NetIncome
        
        function value = get.NetIncome(obj)
            value = obj.convertFrom(obj.Recurrence, obj.YearlyNetIncome);
        end % get.NetIncome
        
        function value = get.Tax(obj)
            value = obj.convertFrom(obj.Recurrence, obj.YearlyTaxNI(1));
        end % get.Tax
        
        function value = get.NationalInsurance(obj)
            value = obj.convertFrom(obj.Recurrence, obj.YearlyTaxNI(2));
        end % get.NationalInsurance
        
        function set.Recurrence(obj, value)
            % Set value.
            obj.Recurrence_ = value;
            
            % Update finances.
            obj.update();
        end % set.Recurrence
        
        function value = get.Recurrence(obj)
            value = obj.Recurrence_;
        end % get.Recurrence
        
        function set.Currency(obj, value)
            % Set value.
            obj.Currency_ = value;
            
            % Update finances.
            obj.update();
        end % set.Currency
        
        function value = get.Currency(obj)
            value = obj.Currency_;
        end % get.Currency
        
        function value = get.MinIncome(obj)
            value = obj.convertFrom(obj.Recurrence, obj.MinYearlyIncome);
        end % get.MinIncome
        
        function value = get.MaxIncome(obj)
            value = obj.convertFrom(obj.Recurrence, obj.MaxYearlyIncome);
        end % get.MaxIncome
        
        function value = get.TaxNITable(obj)
            % Get empty deduction table.
            value = getEmptyDeductionTable();
            
            % Add tax and National Insurance values.
            value(end+1, :) = {"Tax", obj.Tax, obj.Recurrence, "GBP"};
            
            value(end+1, :) = {"National Insurance", obj.NationalInsurance, ...
                obj.Recurrence, "GBP"};
        end % get.TaxNITable
        
        function value = get.Deductions(obj)
            % Sum and combine all deductions.
            value(1) = obj.convertFrom(obj.Recurrence, ...
                sum(arrayfun(@(i) obj.convertTo(obj.PreTax.Recurrence(i), obj.PreTax.Deduction(i)), ...
                1:size(obj.PreTax, 1))));
            value(2) = obj.convertFrom(obj.Recurrence, sum(obj.YearlyTaxNI));
            value(3) = obj.convertFrom(obj.Recurrence, ...
                sum(arrayfun(@(i) obj.convertTo(obj.PostTax.Recurrence(i), obj.PostTax.Deduction(i)), ...
                1:size(obj.PostTax, 1))));
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
    
    methods (Access = private)
        
        function load(obj)
            % LOAD Internal function to load previous session of app. The
            % app loads a MAT file containing the gross income value and
            % the voluntary pre-tax and post-tax deductions.
            
            % Check that MAT file exists.
            if exist(obj.Session, "file")
                % Load MAT file.
                load(obj.Session, "grossIncome", "preTaxDeductions", "postTaxDeductions");
                
                % Store values.
                obj.YearlyGrossIncome = grossIncome;
                obj.PreTax = preTaxDeductions;
                obj.PostTax = postTaxDeductions;
            end
        end % load
        
        function save(obj)
            % SAVE Internal function to save current session of app. The
            % app saves a MAT file containing the gross income value and
            % the voluntary pre-tax and post-tax deductions.
            
            % Check that persistent folder exists.
            if ~exist(fileparts(obj.Session), "dir")
                mkdir(fileparts(obj.Session))
            end
            
            % Retrieve values.
            grossIncome = obj.YearlyGrossIncome;
            preTaxDeductions = obj.PreTax;
            postTaxDeductions = obj.PostTax;
            
            % Save MAT file.
            save(obj.Session, "grossIncome", "preTaxDeductions", "postTaxDeductions");
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
            
            % For each entry, subtract from income.
            for d = 1:size(obj.PreTax, 1)
                % Convert to yearly.
                yearlyDeduction = obj.convertTo( ...
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
                yearlyDeduction = obj.convertTo( ...
                    obj.PostTax.Recurrence(d), obj.PostTax.Deduction(d));
                
                % Subtract from income.
                netIncome = netIncome - yearlyDeduction;
            end
        end % deductPostTax
        
        function value = convertTo(obj, recurrence, value)
            % CONVERTTOYEARLY Internal function to convert value to yearly
            % recurrence from speficied recurrence.
            
            % Convert to yearly value based on time recurrence.
            value = obj.convertRecurrence(@times, recurrence, value);
        end % convertTo
        
        function value = convertFrom(obj, recurrence, value)
            % CONVERTFROMYEARLY Internal function to convert value from
            % yearly recurrence to speficied recurrence.
            
            % Convert from yearly value based on time recurrence.
            value = obj.convertRecurrence(@rdivide, recurrence, value);
        end % convertFrom
        
        function value = convertRecurrence(obj, operator, recurrence, value)
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
                    value = operator(value, 12 * 4 * obj.WeeklyWorkDays);
                case "Hourly"
                    value = operator(value, 12 * 4 * obj.WeeklyWorkDays * obj.DailyWorkHours);
                otherwise
                    error("Finance:Recurrence:UnknownInput", ...
                        "Recurrence '%s' is unknown and unsupported.", recurrence)
            end
        end % convertRecurrence
        
    end % methods (Access = private)
    
end

function mustBeCurrency(property)
% MUSTBECURRENCY Determine whether input value is part of the allowed
% currencies: GBP, EUR, or USD.

% Invoke internal function for member validation.
mustBeMember(property, categorical(Finance.AllowedCurrencies))

end

function mustBeRecurrence(property)
% MUSTBERECURRENCE Determine whether input value is part of the allowed
% recurrence: Yearly, Monthly, Weekly, Daily, or Hourly.

% Invoke internal function for member validation.
mustBeMember(property, categorical(Finance.AllowedRecurrence))

end

function t = getEmptyDeductionTable()
% GETEMPTYDEDUCTIONSTABLE Function to return an empty deductions table to
% be used as visualization purposes.

% Create empty table with deductions properties.
t = cell2table(cell(0,4), "VariableNames", ["Name", "Deduction", "Currency", "Recurrence"]);

t.Name = string.empty();

t.Currency = categorical.empty();
t.Currency = setcats(t.Currency, Finance.AllowedCurrencies);

t.Recurrence = categorical.empty();
t.Recurrence = setcats(t.Recurrence, Finance.AllowedRecurrence);

end % getEmptyDeductionTable

function sessionFile = getSessionFile()
% GETSESSIONFILE Function to return the name of the file to load previous
% session and store current one.

% Hard-code file based on execution.
if isdeployed
    sessionFile = which("deductions.mat");
else
    sessionFile = fullfile("persistent", "deductions.mat");
end

end

function taxNIMatrix = getTaxNIMatrix()
% GETTAXNIMATRIX Function to return the tax-NI matrix downloaded using
% income-tax.co.uk APIs.

% Get tax-NI information.
if isdeployed
    taxNIFile = which("taxNIInfo.mat");
else
    taxNIFile = fullfile("persistent", "taxNIInfo.mat");
end
load(taxNIFile, "taxNIMatrix")

end % getTaxBrackets