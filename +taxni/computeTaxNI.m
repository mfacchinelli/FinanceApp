% Set daily API for website:
% https://www.income-tax.co.uk/tax-calculator-api/
APIKey = "2733823872";

% Set range of incomes for download.
income = [0, 12500, 50000, 150000, 200000];

% Define API key and URL.
taxNIMatrix = taxni.downloadTaxNI(APIKey, income);

% Save matrix to MAT file.
save(fullfile("..", "persistent", "taxNIInfo.mat"), "taxNIMatrix")

% Plot tax-NI info.
taxni.plotTaxNI()