classdef (Sealed) Finance < matlab.mixin.SetGetExactNames

    properties (Dependent, AbortSet)
        % Value of gross (pre-tax) income in GBP.
        GrossIncome (1, 1) double
    end

    properties (Dependent, SetAccess = private)
        % Value of net (post-tax) income in GBP.
        NetIncome
        % Value of taxes.
        Tax
        % Value of National Insurance.
        NationalInsurance
        % Value of pension.
        Pension
    end

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
    end

    properties (Dependent, SetAccess = private)
        % Combined values of all deductions.
        Deductions
        % Combined values of tax and National Insurance as deduction table.
        PreTaxCompulsory
    end

    properties (SetAccess = private)
        % Table of voluntary pre-tax deductions.
        PreTaxVoluntary table = getEmptyDeductionTable()
        % Table of post-tax deductions.
        PostTax table = getEmptyDeductionTable()
        % API key to download currency conversion information from
        % fixer.io.
        CurrencyAPI string = string.empty()
        % Conversion from GBP to EUR.
        EUR2GBP double = 0.85
        % Conversion from GBP to USD.
        USD2GBP double = 0.75
        % Date denoting last time the currency information was updated.
        CurrencyUpdate datetime = NaT
        % Matrix containing tax and National Insurance values as a function
        % of gross income.
        TaxNIMatrix double = getTaxNIDefaults()
        % Date denoting last time the tax and National Insurance
        % information was updated.
        TaxNIUpdate datetime = NaT
    end

    properties (Dependent, SetAccess = private)
        % Value of minimum income of tabulated data.
        MinIncome
        % Value of maximum income of tabulated data.
        MaxIncome
    end

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
    end

    properties (Constant)
        % Values of allowed currencies.
        AllowedCurrencies = ["GBP", "EUR", "USD"]
        % Values of allowed recurrence.
        AllowedRecurrence = ["Yearly", "Quarterly", "Monthly", "Weekly", "Daily", "Hourly"]
        % Inflection points in gross income for tax and National Insurance.
        InflectionValues = [0, 12500, 50000, 100000, 125000, 150000, 200000]
        % Name of MAT file where current session is saved.
        Session = getSessionFile()
        % Name of MAT file containing currency conversion values.
        CurrencyFile = getCurrencyFile()
        % Name of MAT file containing UK tax and National Insurance values.
        TaxNIFile = getTaxNIFile()
    end

    properties (Constant, Access = ?element.hybrid.SettingsViewController)
        % Array of variables for import and export of MAT file.
        ImportExportVariables = ["YearlyGrossIncome", "PreTaxVoluntary", ...
            "PostTax", "DeductPension", "PensionContribution"]
    end

    events
        % Event notifying update of finance model.
        Update
    end

    methods

        function obj = Finance(varargin)

            % Load previous session.
            obj.load();

            % Create listeners for 'SetObservable' properties.
            obj.addSetObservableListeners();

            % Set data.
            if ~isempty(varargin)
                set(obj, varargin{:});
            end

            % Update finances.
            obj.update();
        end

        function delete(obj)

            % Save current session.
            obj.cache();
        end

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
        end

        function value = get.GrossIncome(obj)
            value = obj.convertFrom(obj.Currency, obj.Recurrence, obj.YearlyGrossIncome);
        end

        function set.NetIncome(obj, value)
            obj.YearlyNetIncome = obj.convertTo(obj.Currency, obj.Recurrence, value);
        end

        function value = get.NetIncome(obj)
            value = obj.convertFrom(obj.Currency, obj.Recurrence, obj.YearlyNetIncome);
        end

        function value = get.Tax(obj)
            value = obj.convertFrom(obj.Currency, obj.Recurrence, obj.YearlyTaxNI(1));
        end

        function value = get.NationalInsurance(obj)
            value = obj.convertFrom(obj.Currency, obj.Recurrence, obj.YearlyTaxNI(2));
        end

        function value = get.Pension(obj)

            % Check if pension deduction is toggled.
            if obj.DeductPension
                value = obj.convertFrom(obj.Currency, obj.Recurrence, ...
                    obj.YearlyGrossIncome * obj.PensionContribution / 100);
            else
                value = 0;
            end
        end

        function value = get.MinIncome(obj)
            value = obj.convertFrom(obj.Currency, obj.Recurrence, obj.MinYearlyIncome);
        end

        function value = get.MaxIncome(obj)
            value = obj.convertFrom(obj.Currency, obj.Recurrence, obj.MaxYearlyIncome);
        end

        function value = get.PreTaxCompulsory(obj)

            % Get empty deduction table.
            value = getEmptyDeductionTable();

            % Add tax and National Insurance values.
            value(end+1, :) = {"Tax", obj.Tax, "GBP", obj.Recurrence};
            value(end+1, :) = {"National Insurance", obj.NationalInsurance, ...
                "GBP", obj.Recurrence};

            % Add pension.
            if obj.DeductPension
                value(end+1, :) = {"Pension", obj.Pension, "GBP", obj.Recurrence};
            end
        end

        function value = get.Deductions(obj)

            % Sum pre-tax voluntary contributions.
            value(1) = obj.convertFrom(obj.Currency, obj.Recurrence, ...
                sum(arrayfun(@(i) obj.convertTo(obj.PreTaxVoluntary.Currency(i), obj.PreTaxVoluntary.Recurrence(i), ...
                obj.PreTaxVoluntary.Deduction(i)), 1:size(obj.PreTaxVoluntary, 1))));

            % Sum pre-tax compulsory contributions.
            value(2) = obj.convertFrom(obj.Currency, obj.Recurrence, sum(obj.YearlyTaxNI)) + obj.Pension;

            % Sum post-tax contributions.
            value(3) = obj.convertFrom(obj.Currency, obj.Recurrence, ...
                sum(arrayfun(@(i) obj.convertTo(obj.PostTax.Currency(i), obj.PostTax.Recurrence(i), ...
                obj.PostTax.Deduction(i)), 1:size(obj.PostTax, 1))));
        end
    end

    methods (Access = public)

        function addPreTaxVoluntaryDeduction(obj, name, deduction, currency, recurrence)
            % ADDPRETAXVOLUNTARYDEDUCTION Add one pre-tax deduction by
            % specifying name, deduction value, currency and recurrence.
            % This deduction will be subtracted from the pre-tax income
            % value, before the computation of tax and National Insurance.

            % Check data.
            narginchk(5, 5)
            assert(isstring(name), "Finance:PreTaxVoluntary:InvalidName", "Name must be of type string.")
            assert(isnumeric(deduction), "Finance:PreTaxVoluntary:InvalidDeduction", "Deduction must be of type numeric.")
            try mustBeCurrency(currency); catch
                error("Finance:PreTaxVoluntary:InvalidCurrency", ...
                    "Currency must be member of: %s.", strjoin(obj.AllowedCurrencies, ", "))
            end
            try mustBeRecurrence(recurrence); catch
                error("Finance:PreTaxVoluntary:InvalidRecurrence", ...
                    "Recurrence must be member of: %s.", strjoin(obj.AllowedRecurrence, ", "))
            end

            % Add data to pre-tax table.
            obj.PreTaxVoluntary(end+1, :) = {name, deduction, currency, recurrence};

            % Update finances.
            obj.update();
        end

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
        end

        function amendPreTaxVoluntaryDeduction(obj, rowNumber, name, deduction, currency, recurrence)
            % AMENDPRETAXDEDUCTION Amend a pre-tax deduction by specifying
            % the row number and new name, deduction value, currency and
            % recurrence.

            % Check data.
            narginchk(6, 6)
            assert(isnumeric(rowNumber), "Finance:PreTaxVoluntary:InvalidRow", "Row values must be numeric.")
            assert(all(rowNumber > 0), "Finance:PreTaxVoluntary:InvalidRow", "Row number must be positive.")
            assert(all(rowNumber <= size(obj.PreTaxVoluntary, 1)), "Finance:PreTaxVoluntary:InvalidRow", ...
                "Row specified does not exist. Maximum value is %d.", size(obj.PreTaxVoluntary, 1))
            assert(isstring(name), "Finance:PreTaxVoluntary:InvalidName", "Name must be of type string.")
            assert(isnumeric(deduction), "Finance:PreTaxVoluntary:InvalidDeduction", "Deduction must be of type numeric.")
            try mustBeCurrency(currency); catch
                error("Finance:PreTaxVoluntary:InvalidCurrency", ...
                    "Currency must be member of: %s.", strjoin(obj.AllowedCurrencies, ", "))
            end
            try mustBeRecurrence(recurrence); catch
                error("Finance:PreTaxVoluntary:InvalidRecurrence", ...
                    "Recurrence must be member of: %s.", strjoin(obj.AllowedRecurrence, ", "))
            end

            % Add data to pre-tax table.
            obj.PreTaxVoluntary(rowNumber, :) = {name, deduction, currency, recurrence};

            % Update finances.
            obj.update();
        end

        function amendPostTaxDeduction(obj, rowNumber, name, deduction, currency, recurrence)
            % AMENDPOSTTAXDEDUCTION Amend a post-tax deduction by
            % specifying the row number and new name, deduction value,
            % currency and recurrence.

            % Check data.
            narginchk(6, 6)
            assert(isnumeric(rowNumber), "Finance:PostTax:InvalidRow", "Row values must be numeric.")
            assert(all(rowNumber > 0), "Finance:PostTax:InvalidRow", "Row number must be positive.")
            assert(all(rowNumber <= size(obj.PostTax, 1)), "Finance:PostTax:InvalidRow", ...
                "Row specified does not exist. Maximum value is %d.", size(obj.PostTax, 1))
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
            obj.PostTax(rowNumber, :) = {name, deduction, currency, recurrence};

            % Update finances.
            obj.update();
        end

        function removePreTaxVoluntaryDeduction(obj, rowNumbers)
            % REMOVEPRETAXVOLUNTARYDEDUCTION Remove one or more pre-tax
            % deductions by specifying the row value. This deduction will
            % be removed from the pre-tax list.

            % Check data.
            narginchk(2, 2)
            assert(isnumeric(rowNumbers), "Finance:PreTaxVoluntary:InvalidRow", "Row values must be numeric.")
            assert(all(rowNumbers > 0), "Finance:PreTaxVoluntary:InvalidRow", "Row number must be positive.")
            assert(all(rowNumbers <= size(obj.PreTaxVoluntary, 1)), "Finance:PreTaxVoluntary:InvalidRow", ...
                "Row specified does not exist. Maximum value is %d.", size(obj.PreTaxVoluntary, 1))

            % Remove data from pre-tax table.
            obj.PreTaxVoluntary(rowNumbers, :) = [];

            % Update finances.
            obj.update();
        end

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
        end

        function deletePreTaxVoluntaryDeductions(obj)
            % DELETEPRETAXVOLUNTARYDEDUCTIONS Delete all pre-tax voluntary
            % deductions.

            % Empty table of pre-tax deductions.
            obj.PreTaxVoluntary = getEmptyDeductionTable();

            % Update finances.
            obj.update();
        end

        function deletePostTaxDeductions(obj)
            % DELETEPOSTTAXDEDUCTIONS Delete all post-tax voluntary
            % deductions.

            % Empty table of post-tax deductions.
            obj.PostTax = getEmptyDeductionTable();

            % Update finances.
            obj.update();
        end

        function downloadCurrencyConversion(obj, CurrencyAPI)
            % DOWNLOADCURRENCYCONVERSION Function to download currency
            % conversion information from fixer.io.

            % Download and store updated currency conversions.
            [EUR2GBP, USD2GBP, CurrencyUpdate] = currency.downloadConversions(CurrencyAPI); %#ok<ASGLU,PROPLC>

            % Show and store latest update date.
            obj.save(obj.CurrencyFile, "CurrencyAPI", "EUR2GBP", "USD2GBP", "CurrencyUpdate");

            % Invoke load function for MAT file.
            obj.loadCurrency();

            % Update finances.
            obj.update();
        end

        function downloadTaxNationalInsurance(obj, TaxNIAPI)
            % DOWNLOADTAXNATIONALINSURANCE Function to download tax and
            % National Insurance information from income-tax.co.uk.

            % Download new tax and National Insurance information.
            [TaxNIMatrix, TaxNIUpdate] = taxni.downloadTaxNI(TaxNIAPI, obj.InflectionValues); %#ok<ASGLU,PROPLC>

            % Save values to MAT file.
            obj.save(obj.TaxNIFile, "TaxNIMatrix", "TaxNIUpdate");

            % Invoke load function for MAT file.
            obj.loadTaxNI();

            % Update finances.
            obj.update();
        end
    end

    methods (Access = ?element.hybrid.SettingsViewController)

        function setFromImport(obj, YearlyGrossIncome, PreTaxVoluntary, PostTax)
            % SETFROMIMPORT Function to set values of yearly gross income,
            % and pre-tax and post-tax deductions from MAT file.

            % Store values.
            obj.YearlyGrossIncome = YearlyGrossIncome;
            obj.PreTaxVoluntary = PreTaxVoluntary;
            obj.PostTax = PostTax;

            % Update finances.
            obj.update();
        end

        function [YearlyGrossIncome, PreTaxVoluntary, PostTax] = getForExport(obj)
            % GETFOREXPORT Function to get values of yearly gross income,
            % and pre-tax and post-tax deductions for export to MAT file.

            % Store values.
            YearlyGrossIncome = obj.YearlyGrossIncome;
            PreTaxVoluntary = obj.PreTaxVoluntary;
            PostTax = obj.PostTax;
        end

    end

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
        end

        function load(obj)
            % LOAD Internal function to load previous session of app. The
            % app loads a MAT file containing the gross income value and
            % the voluntary pre-tax and post-tax deductions.

            % Set currency and tax-NI information.
            obj.loadCurrency();
            obj.loadTaxNI();

            % Check that MAT file exists.
            if exist(obj.Session, "file")
                % Load MAT file.
                load(obj.Session, obj.ImportExportVariables{:});

                % Store values.
                obj.setFromImport(YearlyGrossIncome, PreTaxVoluntary, PostTax); %#ok<CPROP>
                obj.DeductPension = DeductPension; %#ok<CPROP>
                obj.PensionContribution = PensionContribution; %#ok<CPROP>
            end
        end

        function loadCurrency(obj)
            % LOADCURRENCY Function to load currency conversion information
            % from MAT file.

            % Check that MAT file exists.
            if exist(obj.CurrencyFile, "file")
                % Load MAT file.
                load(obj.CurrencyFile, "CurrencyAPI", "EUR2GBP", "USD2GBP", "CurrencyUpdate");

                % Store values.
                obj.CurrencyAPI = CurrencyAPI; %#ok<PROP>
                obj.EUR2GBP = EUR2GBP; %#ok<PROP>
                obj.USD2GBP = USD2GBP; %#ok<PROP>
                obj.CurrencyUpdate = CurrencyUpdate; %#ok<PROP>
            else
                % Give default values.
                [obj.CurrencyAPI, obj.EUR2GBP, obj.USD2GBP, obj.CurrencyUpdate] = getCurrencyDefaults();

                % Save defaults.
                saveStruct = struct("CurrencyAPI", obj.CurrencyAPI, "EUR2GBP", obj.EUR2GBP, ...
                    "USD2GBP", obj.USD2GBP, "CurrencyUpdate", obj.CurrencyUpdate); %#ok<NASGU>
                obj.save(obj.CurrencyFile, "-struct", "saveStruct");
            end
        end

        function loadTaxNI(obj)
            % LOADTAXNI Function to load tax and National Insurance
            % information from MAT file.

            % Check that MAT file exists.
            if exist(obj.TaxNIFile, "file")
                % Load MAT file.
                load(obj.TaxNIFile, "TaxNIMatrix", "TaxNIUpdate");

                % Store values.
                obj.TaxNIMatrix = TaxNIMatrix; %#ok<PROP>
                obj.TaxNIUpdate = TaxNIUpdate; %#ok<PROP>
            else
                % Give default values.
                [obj.TaxNIMatrix, obj.TaxNIUpdate] = getTaxNIDefaults();

                % Save defaults.
                saveStruct = struct("TaxNIMatrix", obj.TaxNIMatrix, "TaxNIUpdate", obj.TaxNIUpdate); %#ok<NASGU>
                obj.save(obj.TaxNIFile, "-struct", "saveStruct");
            end

            % Determine values of minumum and maximum of tabulated values.
            obj.MinYearlyIncome = min(obj.InflectionValues);
            obj.MaxYearlyIncome = max(obj.InflectionValues);
        end

        function cache(obj)
            % CACHE Internal function to save current session of app. The
            % app saves a MAT file containing the gross income value and
            % the voluntary pre-tax and post-tax deductions.

            % Retrieve values.
            [YearlyGrossIncome, PreTaxVoluntary, PostTax] = obj.getForExport(); %#ok<ASGLU,PROP>
            DeductPension = obj.DeductPension; %#ok<NASGU,PROP>
            PensionContribution = obj.PensionContribution; %#ok<NASGU,PROP>

            % Save MAT file.
            obj.save(obj.Session, obj.ImportExportVariables{:});
        end

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
        end

        function netIncome = deductPreTax(obj, netIncome)
            % DEDUCTPRETAX Internal function to subtract voluntary pre-tax
            % deductions. Voluntary pre-tax deductions are added with the
            % public method 'addPreTaxDeduction'.

            % Subtract pension.
            if obj.DeductPension
                netIncome = netIncome - netIncome * obj.PensionContribution / 100;
            end

            % For each entry, subtract from income.
            for d = 1:size(obj.PreTaxVoluntary, 1)
                % Convert to yearly.
                yearlyDeduction = obj.convertTo(obj.PreTaxVoluntary.Currency(d), ...
                    obj.PreTaxVoluntary.Recurrence(d), obj.PreTaxVoluntary.Deduction(d));

                % Subtract from income.
                netIncome = netIncome - yearlyDeduction;
            end

            % Retrieve tax-NI information for current gross income.
            obj.YearlyTaxNI = interp1(obj.InflectionValues, obj.TaxNIMatrix, netIncome, "linear", NaN);

            % Subtract tax and National Insurance, as last pre-tax
            % deductions.
            netIncome = netIncome - sum(obj.YearlyTaxNI);
        end

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
        end

        function value = convertTo(obj, currency, recurrence, value)
            % CONVERTTO Internal function to convert value to GBP and
            % yearly recurrence from speficied currency and recurrence.

            % Convert to GBP from specified currency.
            value = obj.convertCurrency(@times, currency, value, obj.EUR2GBP, obj.USD2GBP);

            % Convert to yearly from specified recurrence.
            value = obj.convertRecurrence(@times, recurrence, value, obj.WeeklyWorkDays, obj.DailyWorkHours);
        end

        function value = convertFrom(obj, currency, recurrence, value)
            % CONVERTFROM Internal function to convert value from GBP and
            % yearly recurrence to speficied currency and recurrence.

            % Convert from GBP to specified currency.
            value = obj.convertCurrency(@rdivide, currency, value, obj.EUR2GBP, obj.USD2GBP);

            % Convert from yearly to specified recurrence.
            value = obj.convertRecurrence(@rdivide, recurrence, value, obj.WeeklyWorkDays, obj.DailyWorkHours);
        end

    end

    methods (Static, Access = private)

        function save(filename, varargin)
            % SAVE Internal function to call built-in 'save' function with
            % specified inputs and options. This function differs from
            % built-in one, in that it creates the save folder if it does
            % not exist.

            % Check that folder exists.
            if ~(ismcc || isdeployed) && ~exist(fileparts(filename), "dir")
                mkdir(fileparts(filename))
            end

            % Call built-in save function.
            evalin("caller", sprintf("save(""%s"", %s)", filename, ...
                strjoin(cellfun(@(x) '"' + string(x) + '"', varargin), ", ")))
        end

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
                case "Quarterly"
                    value = operator(value, 4);
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
        end
    end
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
    % GETEMPTYDEDUCTIONSTABLE Function to return an empty deductions table
    % to be used as visualization purposes.

    % Create empty table with deductions properties.
    t = table('Size', [0, 4], 'VariableTypes', ["string", "double", "categorical", "categorical"], ...
        'VariableNames', ["Name", "Deduction", "Currency", "Recurrence"]);
    t.Currency = setcats(t.Currency, Finance.AllowedCurrencies);
    t.Recurrence = setcats(t.Recurrence, Finance.AllowedRecurrence);
end

function sessionFile = getSessionFile()
    % GETSESSIONFILE Function to return the name of the file to load
    % previous session and store current one.

    % Hard-code file based on execution.
    if ismcc || isdeployed
        sessionFile = which("deductions.mat");
    else
        sessionFile = fullfile("cache", "deductions.mat");
    end
end

function currencyFile = getCurrencyFile()
    % GETCURRENCYFILE Function to return the file where the currency API
    % key for fixer.io is stored.

    % Get currency information.
    if ismcc || isdeployed
        currencyFile = which("currencyAPI.mat");
    else
        currencyFile = fullfile("cache", "currencyAPI.mat");
    end
end

function taxNIFile = getTaxNIFile()
    % GETTAXNIFILE Function to return the tax-NI file downloaded using
    % income-tax.co.uk APIs.

    % Get tax-NI information.
    if ismcc || isdeployed
        taxNIFile = which("taxNIInfo.mat");
    else
        taxNIFile = fullfile("cache", "taxNIInfo.mat");
    end
end

function [CurrencyAPI, EUR2GBP, USD2GBP, CurrencyUpdate] = getCurrencyDefaults()
    % GETCURRENCYDEFAULTS Function to return default values of currency
    % conversion information.

    CurrencyAPI = string.empty();
    EUR2GBP = 0.85;
    USD2GBP = 0.75;
    CurrencyUpdate = NaT;
end

function [TaxNIMatrix, TaxNIUpdate] = getTaxNIDefaults()
    % GETTAXNIDEFAULTS Function to return default values of tax and
    % National Insurance information.

    TaxNIMatrix = [0, 0; 0, 464; 7500, 4964; 27500, 5964; 42500, 6464; 52500, 6964; 75000, 7964];
    TaxNIUpdate = NaT;
end