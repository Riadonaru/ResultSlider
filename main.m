global HALF_CM INITIAL_FREQUENCY INITIAL_POINT INITIAL_BATCHES SPECTRUM;

load("MultiScan_20260812_020813.mat");

% Global Settings
HALF_CM = 671; % Conversion constant [MotorStep --> cm]
INITIAL_FREQUENCY = 9.0036; % Slider starting position for Intensity along the slit
INITIAL_POINT = 20; % Slider starting position for Spectrum at point
INITIAL_BATCHES = [1 2 5]; % Batches to show on plot
SPECTRUM = 1; % 1 = Spectrum at point, 0 = Intensity along the slit

data = extract_data(sf, ef, np, Y_all);
slider_figure(data, sf, ef, np, stepSize, numMeasurements);
