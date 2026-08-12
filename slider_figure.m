function slider_figure(data, sf, ef, np, stepSize, numMeasurements)   
    HALF_CM = 671;
    INITIAL_FREQUENCY = 9.0036;
    INITIAL_BATCHES = [1 2 3 4 5];
  
    fig_h = 800;
    fig_w = 1200;
    
    % 1. Create a UI figure window
    fig = uifigure('Name', 'Intensity along the Slit', 'Position', [100, 100, fig_w, fig_h]);

    % Create a 1x1 grid layout that fills the entire figure
    g = uigridlayout(fig, [2, 2]);
    g.RowHeight = {'10x', '1x'};
    g.ColumnWidth = {'5x', '1x'};

    % Create axes inside the grid and center it
    ax = uiaxes(g);
    ax.Layout.Row = 1;
    ax.Layout.Column = [1, 2];
    
    % Infer tube length and array index from experiment parameters
    diff = (stepSize/HALF_CM) * 0.5; % Conversion stepSize ---> [cm]
    tubeLength = (numMeasurements - 1) * diff;

    freq_spacing = (ef - sf) / (np-1);
    index = 1 + round((INITIAL_FREQUENCY - sf)/freq_spacing);

    % Initial data setup
    x = linspace(0, tubeLength, numMeasurements);
    y = extractHeights(data, INITIAL_BATCHES, index);

    % Initial plot
    p = plot(ax, x, y, 'LineWidth', 2);
    ax.XLim = [0, tubeLength];
    title(ax, ['Frequency: ', num2str(INITIAL_FREQUENCY)]);

    % 3. Create a UI slider component
    txtField = uieditfield(g, 'text', ...
        'Position', [100, 200, 150, 30], ...
        'Value', num2str(INITIAL_FREQUENCY), ...
        'ValueChangedFcn', @(txtField, event) disp(txtField.Value));
    txtField.Layout.Row = 2;
    txtField.Layout.Column =2;

    sld = uislider(g, ...
        'Position', [100, 50, 450, 3], ...
        'Limits', [1, np], ...
        'Value', INITIAL_FREQUENCY, ...
        'Step', 1, ...
        'ValueChangedFcn', @(sld, event) sliderUpdate(sld, txtField, p, ax, sf, ef, np, data, INITIAL_BATCHES));
    sld.Layout.Row = 2;
    sld.Layout.Column = 1;
end

function updatePlot(p, data, index, INITIAL_BATCHES)
    y = extractHeights(data, INITIAL_BATCHES, index);  % Update plot y-data
    for i = 1:width(y)
        p(i).YData = y(:, i); 
    end
    drawnow;
end

function sliderUpdate(sld, txtField, p, ax, sf, ef, np, data, INITIAL_BATCHES)
    index = sld.Value; % Get current slider value\
    freq = sf + (index - 1) * (ef - sf) / (np - 1);
    title(ax, ['Frequency: ', num2str(freq)]); % Update title
    txtField.Value = num2str(freq);
    updatePlot(p, data, index, INITIAL_BATCHES);
end