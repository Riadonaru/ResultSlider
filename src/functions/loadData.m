function vars = loadData
    % List all available directories with data
    prefix = "MeasureProject";
    items = dir(strcat(prefix, "*"));
    is_dir = [items.isdir];
    folders = items(is_dir);
    folderNames = {folders.name};
    folderNames = folderNames(~ismember(folderNames, {'.', '..'}));
    matFiles = {};
    for folder = folderNames
        % Search for .mat files in target folders
        search_pattern = fullfile(folder, "*.mat");
        items = dir(search_pattern);
        files = items(~[items.isdir]);
        matFiles = [matFiles, {files.name}];
    end
    vars = loadVariables(matFiles);
    vars.data = extractData(vars.sf, vars.ef, vars.np, vars.Y_all);
    vars = rmfield(vars, 'Y_all');
end


function vars = loadVariables(matFiles)
    if length(matFiles) < 1
        error('No .mat files found in the specified folders.');
    end
    Y_all = {};
    numScans = 0;
    vars = load(matFiles{1});
    vars = rmfield(vars, 'positions_all');
    for file = matFiles
        varsNew = load(file{1});
        if varsNew.sf ~= vars.sf || varsNew.ef ~= vars.ef || ...
           varsNew.np ~= vars.np || varsNew.stepSize ~= vars.stepSize || ...
           varsNew.numMeasurements ~= vars.numMeasurements
           error(['Mismatch between .mat Files: ', file, ' and ', matFiles{1}]);
        end
        Y_all = [Y_all, varsNew.Y_all];
        numScans = numScans + varsNew.numScans;
    end
    vars.Y_all = Y_all;
    vars.numScans = numScans;
end


function data = extractData(sf, ef, np, Y_all)    
    global PHASE
    
    % Plot Intensity Along the Slit :
    numBatches = length(Y_all);
    data = {};
    % if mod(sym(frequency_to_plot) - 9, sym(freq_spacing)) ~= 0
    %     ME = MException("MyComponent:UniqueId", "INVALID FREQUENCY!");
    %     throw(ME);
    % end
    
    % Flip the batches that were scanned the opposite way
    magnitudes = cell(1, numBatches);
    phases = cell(1, numBatches);
    for num = 1:numBatches
        Y = Y_all{num};
        if mod(num, 2) == 0
            Y = flip(Y);
        end
        magnitudes{num} = abs(Y).^2;
        phases{num} = angle(Y);
    end
    data{1} = magnitudes;
    data{2} = phases;
end


