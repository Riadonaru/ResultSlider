function data = extract_data(sf, ef, np, Y_all)    
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


