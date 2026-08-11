clear;
clc;
figure;

load('MultiScan_20260809_154904.mat');
HALF_CM = 671;


batch = 2;
point = 26.5; % Number in range [0, tubeLength] ----> in [cm]!
index = 2 * point + 1;
diff = (stepSize/HALF_CM) * 0.5; % Conversion stepSize ---> [cm]
tubeLength = (numMeasurements - 1) * diff;
if point < 0.5 || point > tubeLength || mod(point, diff) ~= 0
    ME = MException("MyComponent:UniqueId", "INVALID POINT!");
    throw(ME);
end

Y = Y_all{batch};
if mod(batch, 2) == 0
    Y = flip(Y);
end

a = abs(Y).^2;

% Find the correct index in the array
data = a(index, :);
x = linspace(sf, ef, np);
plot(x, data, 'b*-', 'LineWidth', 1.2, 'color', 'b');
title(['Spectrum @ ', num2str(point)]);
ylabel('Intensity (au)','FontSize',20,'FontWeight','bold');
xlabel('Frequency (Hz)','FontSize',20,'FontWeight','bold');
xlim([sf, ef]);
legend(['Batch ', num2str(batch)], 'location', 'best');
set(gca,'FontSize',20,'FontWeight','bold');