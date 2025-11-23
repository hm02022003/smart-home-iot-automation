
%% MATLAB Script for Smart Home Energy Optimization ANFIS
% Generated automatically - Run this in MATLAB after downloading the CSV files

%% Clear workspace
clear; clc; close all;

%% Load the optimized dataset
fprintf('Loading smart home data...\n');
data = readtable('smart_home_anfis_ready.csv');

%% Display dataset info
fprintf('Dataset loaded successfully!\n');
fprintf('Size: %d samples x %d features\n', size(data, 1), size(data, 2));
fprintf('Features:\n');
disp(data.Properties.VariableNames);

%% Prepare inputs and outputs for ANFIS
% Inputs: Hour_of_Day, Day_of_Week, Month, Consumption_Pattern, Voltage
inputs = [data.Hour_of_Day, data.Day_of_Week, data.Month, ...
          data.Consumption_Pattern, data.Voltage];

% Output: Energy_Consumption_kWh
output = data.Energy_Consumption_kWh;

fprintf('Input data shape: %d x %d\n', size(inputs));
fprintf('Output data shape: %d x %d\n', size(output));

%% Analyze consumption patterns
fprintf('\n=== Consumption Patterns Analysis ===\n');
unique_patterns = unique(data.Consumption_Pattern);
for i = 1:length(unique_patterns)
    pattern_idx = data.Consumption_Pattern == unique_patterns(i);
    pattern_energy = mean(data.Energy_Consumption_kWh(pattern_idx));
    pattern_count = sum(pattern_idx);
    fprintf('Pattern %d: %d samples, Avg Energy: %.2f kWh\n', ...
            unique_patterns(i), pattern_count, pattern_energy);
end

%% Data visualization
figure('Position', [100, 100, 1200, 800]);

% Plot 1: Energy consumption by hour
subplot(2,3,1);
scatter(data.Hour_of_Day, data.Energy_Consumption_kWh, 20, data.Consumption_Pattern, 'filled');
xlabel('Hour of Day');
ylabel('Energy Consumption (kWh)');
title('Energy Consumption vs Hour');
colorbar;

% Plot 2: Energy consumption by pattern
subplot(2,3,2);
boxplot(data.Energy_Consumption_kWh, data.Consumption_Pattern);
xlabel('Consumption Pattern');
ylabel('Energy Consumption (kWh)');
title('Energy by Consumption Pattern');

% Plot 3: Voltage vs Energy
subplot(2,3,3);
scatter(data.Voltage, data.Energy_Consumption_kWh, 20, data.Month, 'filled');
xlabel('Voltage');
ylabel('Energy Consumption (kWh)');
title('Voltage vs Energy');
colorbar;

% Plot 4: Monthly patterns
subplot(2,3,4);
monthly_energy = grpstats(data, 'Month', 'mean', 'DataVars', 'Energy_Consumption_kWh');
bar(monthly_energy.Month, monthly_energy.mean_Energy_Consumption_kWh);
xlabel('Month');
ylabel('Average Energy (kWh)');
title('Monthly Energy Consumption');

% Plot 5: Weekly patterns
subplot(2,3,5);
weekly_energy = grpstats(data, 'Day_of_Week', 'mean', 'DataVars', 'Energy_Consumption_kWh');
bar(weekly_energy.Day_of_Week, weekly_energy.mean_Energy_Consumption_kWh);
xlabel('Day of Week (1=Mon, 7=Sun)');
ylabel('Average Energy (kWh)');
title('Weekly Energy Patterns');

% Plot 6: Histogram of energy consumption
subplot(2,3,6);
histogram(data.Energy_Consumption_kWh, 50);
xlabel('Energy Consumption (kWh)');
ylabel('Frequency');
title('Energy Distribution');

sgtitle('Smart Home Energy Consumption Analysis');

fprintf('\n✅ Data preparation complete! Ready for ANFIS training.\n');
fprintf('Use these commands to start ANFIS:\n');
fprintf('  opt = genfisOptions(''GridPartition'');\n');
fprintf('  opt.NumMembershipFunctions = [4 3 3 3 3];\n');
fprintf('  fis = genfis(inputs, output, opt);\n');
fprintf('  anfis_output = anfis([inputs output], fis);\n');

%% Save prepared data for ANFIS
save('anfis_training_data.mat', 'inputs', 'output');
fprintf('\n💾 Training data saved as: anfis_training_data.mat\n');
