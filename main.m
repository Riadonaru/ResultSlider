global HALF_CM INITIAL_FREQUENCY INITIAL_POINT INITIAL_SCANS SPECTRUM PHASE;

load("MultiScan_20260812_231408.mat");

% Global Settings
HALF_CM = 671; % Conversion constant [MotorStep --> cm]
INITIAL_FREQUENCY = 10.2498; % Slider starting position for Intensity along the slit
INITIAL_POINT = 20; % Slider starting position for Spectrum at point
INITIAL_SCANS = [1 2]; % Batches to show on plot
SPECTRUM = 0; % 1 = Spectrum at point, 0 = Intensity along the slit
PHASE = 0; % 1 = Phase graph 0 = Magnitude graph

data = extract_data(sf, ef, np, Y_all);
slider_figure(data, sf, ef, np, stepSize, numMeasurements);
