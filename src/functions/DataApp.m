classdef DataApp < handle
    % The '< handle' part is critical so updates modify the original object

    properties
        % These replace your global variables.
        % Every function in the class can read and write to these.
        PlotColor = 'blue'
        Vars
        FigureHandle
    end

    methods
        % 1. The Constructor
        % This runs once when you first create the object.
        function obj = DataApp(vars)
            obj.Vars = vars;
            % You could also initialize your UI window here
        end

        function show(obj)

            global HALF_CM INITIAL_FREQUENCY INITIAL_POINT DISPLAYED_SCANS SPECTRUM PHASE;

            data = obj.Vars.data;
            sf = obj.Vars.sf;
            ef = obj.Vars.ef;
            np = obj.Vars.np;
            stepSize = obj.Vars.stepSize;
            numMeasurements = obj.Vars.numMeasurements;

            fig_h = 800;
            fig_w = 1200;
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

            y_vals = data{PHASE + 1};

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
            settings_spectrum{5} = ['Spectrum @ ', num2str(INITIAL_POINT), ' [cm] from Origin'];
            settings_spectrum{6} = 2 * INITIAL_POINT; % Data index
            settings_spectrum{7} = linspace(sf, ef, np); % % X axis
            settings_spectrum{8} = extractWidths(y_vals, DISPLAYED_SCANS, settings_spectrum{6}); % Y axis

            % FREQUENCY DOMAIN SETTINGS
            settings_frequency{1} = [0 tubeLength]; % X lim
            settings_frequency{2} = [1, np]; % Slider lim
            settings_frequency{3} = 1; % Slider step
            settings_frequency{4} = INITIAL_FREQUENCY; % Slider init
            settings_frequency{5} = ['Intensity along the Slit @ ', num2str(INITIAL_FREQUENCY), ' [Hz]']; % Plot name
            settings_frequency{6} = 1 + round((INITIAL_FREQUENCY - sf)/freq_spacing); % Data index
            settings_frequency{7} = linspace(0, tubeLength, numMeasurements); % % X axis
            settings_frequency{8} = extractHeights(y_vals, DISPLAYED_SCANS, settings_frequency{6}); % Y axis

            plot_settings{1} = settings_frequency;
            plot_settings{2} = settings_spectrum;
            settings = plot_settings{SPECTRUM + 1};

            % Initial plot
            plot(ax, settings{7}, settings{8}, 'LineWidth', 2);
            xlim(ax, settings{1});
            info = cell(1, length(DISPLAYED_SCANS));
            for i = 1:length(DISPLAYED_SCANS)
                info{i} = ['Scan ' num2str(DISPLAYED_SCANS(i))];
            end
            legend(ax, info, 'Location', 'northeastoutside', 'FontSize', 16);
            title(ax, settings{5}, ...
                'FontSize', 24, ...
                'FontWeight','Bold', ...
                'FontName', 'Times New Roman');

            sld = uislider(g, ...
                'Position', [100, 50, 450, 3], ...
                'Limits', settings{2}, ...
                'Value', settings{6}, ...
                'Step', settings{3}, ...
                'ValueChangedFcn', @(sld, event) obj.sliderUpdate(sld, ax, sf, ef, np, data, plot_settings));
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
            labelTexts = {'Intensity along the slit', 'Spectrum at point'};
            lbl = uilabel(tab2, ...
                'Text', labelTexts{SPECTRUM + 1}, ...
                'Position', [105, fig_h - 220, 200, 20]);

            uiswitch(tab2, 'slider', ...
                'Value', 'Off', ...
                'ValueChangedFcn', @(src, event) obj.modifyLayout(ax, lbl, labelTexts, sld, plot_settings, data), ...
                'Position', [50, fig_h - 220, 45, 20], ...
                'Items', hiddenStates, ...
                'Value', hiddenStates{SPECTRUM + 1});

            hiddenStates1 = {' ', ' '};
            labelTexts1 = {'Magnitude', 'Phase'};
            lbl1 = uilabel(tab2, ...
                'Text', labelTexts1{PHASE + 1}, ...
                'Position', [105, fig_h - 250, 200, 20]);

            uiswitch(tab2, 'slider', ...
                'Value', 'Off', ...
                'ValueChangedFcn', @(src, event) obj.modifyY(ax, lbl1, labelTexts1, data, plot_settings, sld), ...
                'Position', [50, fig_h - 250, 45, 20], ...
                'Items', hiddenStates1, ...
                'Value', hiddenStates{PHASE + 1});

            uilabel('Text', 'Available Scans', ...
                'Parent', tab2, ...
                'FontSize', 16, ...
                'FontWeight', 'Bold', ...
                'Position', [550 fig_h - 180 200 50]);

            for num = 1:length(y_vals)
                value = 0;
                if any(DISPLAYED_SCANS == num)
                    value = 1;
                end
                uicheckbox('Text', ['  Scan' num2str(num)], ...
                    'Parent', tab2, ...
                    'Value', value, ...
                    'UserData', num, ...
                    'ValueChangedFcn', @(src, event) obj.updateScan(src, ax, sld, data, plot_settings), ...
                    'Position', [550 fig_h - (200+30*num) 200 50]);
            end
        end

        % Called each time a plot update is required
        function updatePlot(obj, ax, data, index, plot_settings)
            global SPECTRUM DISPLAYED_SCANS PHASE;

            y_vals = data{PHASE + 1};
            if SPECTRUM == 1
                y = extractWidths(y_vals, DISPLAYED_SCANS, index);
            else
                y = extractHeights(y_vals, DISPLAYED_SCANS, index);
            end
            settings = plot_settings{SPECTRUM + 1};
            cla(ax);
            plot(ax, settings{7}, y, 'LineWidth', 2);
            info = cell(1, length(DISPLAYED_SCANS));
            for i = 1:length(DISPLAYED_SCANS)
                info{i} = ['Scan ' num2str(DISPLAYED_SCANS(i))];
            end
            legend(ax, info, 'Location', 'northeastoutside', 'FontSize', 16);
        end


        % Handler for the slider
        function sliderUpdate(obj, sld, ax, sf, ef, np, data, plot_settings)

            global SPECTRUM DISPLAYED_SCANS;

            if SPECTRUM == 1
                index =  2 * sld.Value + 1; % Get current slider value\
                title(ax, ['Spectrum @ ', num2str((index - 1)/ 2), ' [cm] from Origin']); % In spectrum at point title is point
            else
                index = sld.Value; % Get current slider value\
                freq = sf + (index - 1) * (ef - sf) / (np - 1); % In frequency along the axis title is frequency
                title(ax, ['Intensity along the Slit @ ', num2str(freq), ' [hz]']); % Update title
            end
            updatePlot(obj, ax, data, index, plot_settings);
        end


        % Callback for first toggle button
        function modifyLayout(obj, ax, lbl, labelTexts, sld, plot_settings, data)
            global SPECTRUM;

            SPECTRUM = ~SPECTRUM;
            lbl.Text = labelTexts(SPECTRUM + 1);
            cla(ax);

            settings = plot_settings{SPECTRUM + 1};
            sld.Limits = settings{2};
            sld.Value = settings{6};
            sld.Step = settings{3};

            xlim(ax, settings{1});
            title(ax, settings{5}, ...
                'FontSize', 24, ...
                'FontWeight','Bold', ...
                'FontName', 'Times New Roman');

            if SPECTRUM == 1
                index =  2 * sld.Value + 1;
            else
                index = sld.Value;
            end
            updatePlot(obj, ax, data, index, plot_settings);

        end


        % Callback for second toggle button
        function modifyY(obj, ax, lbl1, labelTexts1, data, plot_settings, sld)
            global SPECTRUM PHASE;

            PHASE = ~PHASE;
            lbl1.Text = labelTexts1(PHASE + 1);
            if SPECTRUM == 1
                index =  2 * sld.Value + 1; % Get current slider value\
            else
                index = sld.Value; % Get current slider value\
            end
            updatePlot(obj, ax, data, index, plot_settings);
        end

        function updateScan(obj, src, ax, sld, data, plot_settings)
            global DISPLAYED_SCANS SPECTRUM;

            if src.Value == 1
                DISPLAYED_SCANS = [DISPLAYED_SCANS, src.UserData];
            else
                DISPLAYED_SCANS(DISPLAYED_SCANS == src.UserData) = [];
            end

            if SPECTRUM == 1
                index =  2 * sld.Value + 1; % Get current slider value\
            else
                index = sld.Value; % Get current slider value\
            end
            updatePlot(obj, ax, data, index, plot_settings);
        end
    end
end