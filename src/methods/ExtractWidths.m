function y = ExtractWidths(data, scans, index)
    height = length(scans);
    if height == 0
        height = height + 1;
    end
    y = zeros(width(data{1}), height);
    for batch = scans
        y_vals = data{batch};
        y(:, batch) = y_vals(index, :).';
    end
end