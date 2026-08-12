load("MultiScan_20260812_020813.mat");

data = extract_data(sf, ef, np, Y_all);
slider_figure(data, sf, ef, np, stepSize, numMeasurements);
