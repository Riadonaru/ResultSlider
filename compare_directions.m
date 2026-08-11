clear;
clc;
figure; 

load('MultiScan_20260809_154904.mat');
HALF_CM = 671;


% Plot Intensity Along the Slit :
batch = [1 2]; % Batches to plot
frequency_to_plot = 'All'; % Must be a valid frequency!

a = cell(1, length(batch));
freq_spacing = (ef - sf) / (np-1);
% if mod(sym(frequency_to_plot) - 9, sym(freq_spacing)) ~= 0
%     ME = MException("MyComponent:UniqueId", "INVALID FREQUENCY!");
%     throw(ME);
% end

% Flip the batches that were scanned the opposite way
for num = batch
    Y = Y_all{num};
    if mod(num, 2) == 0
        Y = flip(Y);
    end
    a{num} = abs(Y).^2;
end

% Find the correct index in the array
index = 1 + round((frequency_to_plot - sf)/freq_spacing);
diff = (stepSize/HALF_CM) * 0.5; % Conversion stepSize ---> [cm]
tubeLength = (numMeasurements - 1) * diff;
x = linspace(0, tubeLength, numMeasurements);

data = abs(a{2} - a{1}).^2;
if frequency_to_plot ~= 'All'
    plot(x, data(:, index), 'b*-', 'LineWidth', 1.2, 'color', 'b');
else
    plot(x, mean(data, 2), 'b*-', 'LineWidth', 1.2, 'color', 'b');
end

title(['Error along the Slit @ ', num2str(frequency_to_plot)]);
ylabel('Intensity (au)','FontSize',20,'FontWeight','bold');
xlabel('Distance (Cm)','FontSize',20,'FontWeight','bold');
xlim([0 tubeLength]);
legend(['Batch ', num2str(batch)], 'location', 'best');
set(gca,'FontSize',20,'FontWeight','bold');