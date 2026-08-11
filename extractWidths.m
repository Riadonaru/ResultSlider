function y = extractWidths(data, batches, index)
    y = zeros(width(data{1}), length(batches));
    for batch = batches
        y_vals = data{batch};
        y(:, batch) = y_vals(index, :).';
    end
end