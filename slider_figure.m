function slider_figure(data, sf, ef, np, stepSize, numMeasurements)   
    
    global HALF_CM INITIAL_FREQUENCY INITIAL_POINT INITIAL_BATCHES SPECTRUM;

    fig_h = 800;
    fig_w = 1200;
    
    % 1. Create a UI figure window
    fig = uifigure('Name', 'Results', 'Position', [100, 100, fig_w, fig_h]);

    % 2. Create the tab group as a child of the figure
    tgroup = uitabgroup(fig, 'Units', 'Normalized', 'Position', [0 0 1 1]);

    % 3. Create the individual tabs as children of the tab group
    tab1 = uitab(tgroup, 'Title', 'Data View');
    tab2 = uitab(tgroup, 'Title', 'Settings');

    %% ==================== TAB 1 ====================
    g = uigridlayout(tab1, [2, 1]);
    g.RowHeight = {'10x', '1x'};
    g.ColumnWidth = {'1x'};

    % Create axes inside the grid and center it
    ax = uiaxes(g);
    ax.Layout.Row = 1;
    ax.Layout.Column = 1;
    
    for num = 1:length(data)
        value = 0;
        if any(INITIAL_BATCHES == num)
            value = 1;
        end
        uicheckbox('Text', ['  Batch' num2str(num)], ...
            'Parent', tab2, ...
            'Value', value, ...
            'Position', [550 fig_h - (200+30*num) 200 50]);
    end

    %% ==================== Data View INIT ====================
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

    %% ==================== TAB 2 ====================

    uilabel('Text', 'Settings', ...
        'Parent', tab2, ...
        'FontSize', 40, ...
        'FontWeight', 'Bold', ...
        'Position', [50 fig_h - 100 200 50]);

    uilabel('Text', 'Plot Settings', ...
        'Parent', tab2, ...
        'FontSize', 16, ...
        'FontWeight', 'Bold', ...
        'Position', [50 fig_h - 180 200 50]);

    uicheckbox('Text', '  Intensity along the slit', ...
        'Parent', tab2, ...
        'Value', ~SPECTRUM, ...
        'ValueChangedFcn', @(src, event)modifyLayout(src, p, ax, data), ...
        'Position', [50 fig_h - 230 200 50]);

    uicheckbox('Text', '  Spectrum at point', ...
        'Parent', tab2, ...
        'Value', SPECTRUM, ...
        'Position', [50 fig_h - 260 200 50]);

    uilabel('Text', 'Available Batches', ...
        'Parent', tab2, ...
        'FontSize', 16, ...
        'FontWeight', 'Bold', ...
        'Position', [550 fig_h - 180 200 50]);
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

function modifyLayout(src, p, ax, data)
    if src.Value == 1
        pass
    else
        for k = 1:numel(p)
            p(k).YData = NaN(size(p(k).YData));
        end
    end
end