function slider_figure(data, sf, ef, np, stepSize, numMeasurements)   
    
    global HALF_CM INITIAL_FREQUENCY INITIAL_POINT INITIAL_BATCHES SPECTRUM;

    fig_h = 800;
    fig_w = 1200;
    
    % 1. Create a UI figure window
    fig = uifigure('Name', 'Results', 'Position', [100, 100, fig_w, fig_h]);

    % Create a 1x1 grid layout that fills the entire figure
    g = uigridlayout(fig, [1, 1]);
    g.RowHeight = {'10x', '1x'};
    g.ColumnWidth = {'1x'};

    % Create axes inside the grid and center it
    ax = uiaxes(g);
    ax.Layout.Row = 1;
    ax.Layout.Column = 1;
    
    % Infer tube length and array index from experiment parameters
    diff = (stepSize/HALF_CM) * 0.5; % Conversion stepSize ---> [cm]
    tubeLength = (numMeasurements - 1) * diff;

    freq_spacing = (ef - sf) / (np-1);
    % Initial data setup
    if SPECTRUM == 1
        index = 2 * INITIAL_POINT;
        x = linspace(sf, ef, np);
        y = extractWidths(data, INITIAL_BATCHES, index);
        x_lim = [sf ef];
        slider_lim = [0, tubeLength];
        slider_step = 0.5;
        slider_init = INITIAL_POINT;
        name = ["Spectrum @ ", INITIAL_POINT, 'cm From Origin'];
    else
        index = 1 + round((INITIAL_FREQUENCY - sf)/freq_spacing);
        x = linspace(0, tubeLength, numMeasurements);
        y = extractHeights(data, INITIAL_BATCHES, index);
        x_lim = [0 tubeLength];
        slider_lim = [1, np];
        slider_step = 1;
        slider_init = INITIAL_FREQUENCY;
        name = ["Intensity along the Slit @ ", INITIAL_FREQUENCY, "hz"];
    end

    % Initial plot
    p = plot(ax, x, y, 'LineWidth', 2);
    xlim(ax, x_lim);
    title(ax, name);
    

    sld = uislider(g, ...
        'Position', [100, 50, 450, 3], ...
        'Limits', slider_lim, ...
        'Value', slider_init, ...
        'Step', slider_step, ...
        'ValueChangedFcn', @(sld, event) sliderUpdate(sld, p, ax, sf, ef, np, data, INITIAL_BATCHES, SPECTRUM));
    sld.Layout.Row = 2;
    sld.Layout.Column = 1;
end

function updatePlot(p, data, index, INITIAL_BATCHES, SPECTRUM)
    if SPECTRUM == 1
        y = extractWidths(data, INITIAL_BATCHES, index);
    else
        y = extractHeights(data, INITIAL_BATCHES, index);
    end

    for i = 1:width(y)
        p(i).YData = y(:, i); 
    end
    drawnow;
end

function sliderUpdate(sld, p, ax, sf, ef, np, data, INITIAL_BATCHES, SPECTRUM)
    if SPECTRUM == 1
        index =  2 * sld.Value + 1; % Get current slider value\
        title(ax, ["Spectrum @ ", num2str((index - 1)/ 2)], "cm From Origin"); % In spectrum at point title is point
    else
        index = sld.Value; % Get current slider value\
        freq = sf + (index - 1) * (ef - sf) / (np - 1); % In frequency along the axis title is frequency
        title(ax, ["Intensity along the Slit @ ", num2str(freq), "hz"]); % Update title
    end
    updatePlot(p, data, index, INITIAL_BATCHES, SPECTRUM);
end