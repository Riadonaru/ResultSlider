load("MultiScan_20260809_154904.mat");

data = intensity_along_the_slit(sf, ef, np, Y_all);
slider_figure(data, sf, ef, np, stepSize, numMeasurements);
