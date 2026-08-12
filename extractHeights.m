function y = extractHeights(Y_all, batches, index)
    y = zeros(height(Y_all{1}), length(batches));
    for i = 1:length(batches)
        y_vals = Y_all{batches(i)};
        y(:, i) = y_vals(:, index);
    end
end