function plotTaxNI()

% Load tax-NI info.
load("taxNIInfo.mat", "taxNIMatrix")

% Create income matrix.
income = taxNIMatrix(:, 1);

% Create figure.
f = figure;
a = axes(f);
xlabel(a, "Income [k£]")
grid(a, "on")

yyaxis left
tax = interp1(income, taxNIMatrix(:, 2), income, "linear")/1e3;
hold on
% scatter(a, income/1e3, tax, 50)
plot(a, income/1e3, tax, "LineWidth", 1.5, "LineStyle", "--")
hold off
ylabel(a, "Tax [k£]")

yyaxis right
ni = interp1(income, taxNIMatrix(:, 3), income, "linear");
hold on
% scatter(a, income/1e3, ni, 50)
plot(a, income/1e3, ni, "LineWidth", 1.5, "LineStyle", "-.")
hold off
ylabel(a, "NI [£]")

end