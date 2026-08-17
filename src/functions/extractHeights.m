function y = extractHeights(Y_all, scans, index)
    width = length(scans);
    if width == 0
        width = width + 1;
    end
    y = zeros(height(Y_all{1}), width);
    for i = 1:length(scans)
        y_vals = Y_all{scans(i)};
        y(:, i) = y_vals(:, index);
    end
end