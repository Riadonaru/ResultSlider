function data = intensity_along_the_slit(sf, ef, np, Y_all)    
    % Plot Intensity Along the Slit :
    batch = [1 2]; % Batches to plot
    
    data = cell(1, length(batch));
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
        data{num} = abs(Y).^2;
    end
   
    % for num = batch
    %     hold on
    %     data = a{num};
    %     plot(x, data(:, index), 'b*-', 'LineWidth', 1.2, 'color', [1-num/length(batch) 0 num/length(batch)]);
    % end

end


