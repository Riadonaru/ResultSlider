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
    plot_settings = {};
    settings_spectrum = {};
    settings_frequency = {};
    
    % SPECTRUM DOMAIN SETTINGS
    settings_spectrum{1} = [sf ef];
    settings_spectrum{2} = [0, tubeLength];
    settings_spectrum{3} = 0.5;
    settings_spectrum{4} = INITIAL_POINT;
    settings_spectrum{5} = ["Spectrum @ ", INITIAL_POINT, 'cm From Origin'];
    settings_spectrum{6} = 2 * INITIAL_POINT; % Data index
    settings_spectrum{7} = linspace(sf, ef, np); % % X axis
    settings_spectrum{8} = extractWidths(data, INITIAL_BATCHES, settings_spectrum{6}); % Y axis

    % FREQUENCY DOMAIN SETTINGS
    settings_frequency{1} = [0 tubeLength]; % X lim
    settings_frequency{2} = [1, np]; % Slider lim
    settings_frequency{3} = 1; % Slider step
    settings_frequency{4} = INITIAL_FREQUENCY; % Slider init
    settings_frequency{5} = ["Intensity along the Slit @ ", INITIAL_FREQUENCY, "hz"]; % Plot name
    settings_frequency{6} = 1 + round((INITIAL_FREQUENCY - sf)/freq_spacing); % Data index
    settings_frequency{7} = linspace(0, tubeLength, numMeasurements); % % X axis
    settings_frequency{8} = extractHeights(data, INITIAL_BATCHES, settings_frequency{6}); % Y axis
    
    plot_settings{1} = settings_frequency;
    plot_settings{2} = settings_spectrum;
    settings = plot_settings{SPECTRUM + 1};
    % Initial plot
    p = plot(ax, settings{7}, settings{8}, 'LineWidth', 2);
    xlim(ax, settings{1});
    title(ax, settings{5});
    

    sld = uislider(g, ...
        'Position', [100, 50, 450, 3], ...
        'Limits', settings{2}, ...
        'Value', settings{4}, ...
        'Step', settings{3}, ...
        'ValueChangedFcn', @(sld, event) sliderUpdate(sld, ax, sf, ef, np, data, plot_settings));
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
    
    hiddenStates = {' ', ' '};
    labelTexts = {'Spectrum at point', 'Intensity along the slit'};
    startIdx = (~SPECTRUM) + 1;
    lbl = uilabel(tab2, ...
        'Text', labelTexts{startIdx}, ...
        'Position', [105, fig_h - 220, 200, 20]);

    uiswitch(tab2, 'slider', ...
        'Value', 'Off', ...
        'ValueChangedFcn', @(src, event)modifyLayout(src, ax, data, lbl, labelTexts, sld, plot_settings), ...
        'Position', [50, fig_h - 220, 45, 20], ...
        'Items', hiddenStates, ...
        'Value', hiddenStates{startIdx});

    uilabel('Text', 'Available Batches', ...
        'Parent', tab2, ...
        'FontSize', 16, ...
        'FontWeight', 'Bold', ...
        'Position', [550 fig_h - 180 200 50]);
end


function updatePlot(ax, data, index, plot_settings)
    global SPECTRUM INITIAL_BATCHES;
     if SPECTRUM == 1
        y = extractWidths(data, INITIAL_BATCHES, index);
    else
        y = extractHeights(data, INITIAL_BATCHES, index);
     end
    settings = plot_settings{SPECTRUM + 1};
    cla(ax);
    plot(ax, settings{7}, y, 'LineWidth', 2);
end

function sliderUpdate(sld, ax, sf, ef, np, data, plot_settings)
    global SPECTRUM INITIAL_BATCHES;

    if SPECTRUM == 1
        index =  2 * sld.Value + 1; % Get current slider value\
        title(ax, ["Spectrum @ ", num2str((index - 1)/ 2)], "cm From Origin"); % In spectrum at point title is point
    else
        index = sld.Value; % Get current slider value\
        freq = sf + (index - 1) * (ef - sf) / (np - 1); % In frequency along the axis title is frequency
        title(ax, ["Intensity along the Slit @ ", num2str(freq), "hz"]); % Update title
    end
    updatePlot(ax, data, index, plot_settings);
end

function modifyLayout(src, ax, data, lbl, labelTexts, sld, plot_settings)
    global SPECTRUM;
    
    SPECTRUM = ~SPECTRUM;
    startIdx = (~SPECTRUM) + 1;
    lbl.Text = labelTexts(startIdx);
    cla(ax);

    settings = plot_settings{SPECTRUM + 1};
    sld.Limits = settings{2};
    sld.Value = settings{4};
    sld.Step = settings{3};

    plot(ax, settings{7}, settings{8}, 'LineWidth', 2);
    xlim(ax, settings{1});
    title(ax, settings{5});
end