% Set daily API for website:
% https://www.income-tax.co.uk/tax-calculator-api/
APIKey = "1236710752560";

% Set range of incomes for download.
income = [0, 12500, 50000, 75000, 150000, 200000];

% Define API key and URL.
[TaxNIMatrix, TaxNIUpdate] = taxni.downloadTaxNI(APIKey, income);

% Save matrix to MAT file.
save(Finance.TaxNIFile, "TaxNIMatrix", "TaxNIUpdate")

% Plot tax-NI info.
taxni.plotTaxNI()