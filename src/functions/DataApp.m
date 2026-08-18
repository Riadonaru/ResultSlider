classdef DataApp < handle
    % The '< handle' part is critical so updates modify the original object

    properties (SetAccess = private)
        FigH = 800;
        FigW = 1200;
        PlotColor = 'blue'
        StartFreq
        EndFreq
        NumPoints
        StepSize
        NumMeasurements
        Data
    end
    
    properties (Access = public)
        Figure
        TabGroup
        Tab1
        Tab2
        GridLayout
        Axis
    end

    methods
        % 1. The Constructor
        % This runs once when you first create the object.
        function obj = DataApp(vars)
            obj.StartFreq = vars.sf;
            obj.EndFreq = vars.ef;
            obj.NumPoints = vars.np;
            obj.StepSize = vars.stepSize;
            obj.NumMeasurements = vars.numMeasurements;
            obj.Data = vars.data;

            obj.Figure = uifigure('Name', 'Results', ...
                           'Visible', 'On', ...
                           'Position', [100, 100, obj.FigW, obj.FigH]);

            obj.TabGroup = uitabgroup(obj.Figure, 'Units', 'Normalized', 'Position', [0 0 1 1]);
            obj.Tab1 = uitab(obj.TabGroup, 'Title', 'Data View');
            obj.Tab2 = uitab(obj.TabGroup, 'Title', 'Settings');

            obj.GridLayout = uigridlayout(obj.Tab1, [2, 1]);
            obj.GridLayout.RowHeight = {'10x', '1x'};
            obj.GridLayout.ColumnWidth = {'1x'};
            obj.Axis = uiaxes(obj.GridLayout);
            obj.Axis.Layout.Row = 1;
            obj.Axis.Layout.Column = 1;

        end

        function show(obj)

            global HALF_CM INITIAL_FREQUENCY INITIAL_POINT DISPLAYED_SCANS SPECTRUM PHASE;

            y_vals = obj.Data{PHASE + 1};

            %% ==================== Data View INIT ====================
            % Infer tube length and array index from experiment parameters
            diff = (obj.StepSize/HALF_CM) * 0.5; % Conversion stepSize ---> [cm]
            tubeLength = (obj.NumMeasurements - 1) * diff;

            freq_spacing = (obj.EndFreq - obj.StartFreq) / (obj.NumPoints-1);
            plot_settings = {};
            settings_spectrum = {};
            settings_frequency = {};

            % SPECTRUM DOMAIN SETTINGS
            settings_spectrum{1} = [obj.StartFreq obj.EndFreq];
            settings_spectrum{2} = [0, tubeLength];
            settings_spectrum{3} = 0.5;
            settings_spectrum{4} = INITIAL_POINT;
            settings_spectrum{5} = ['Spectrum @ ', num2str(INITIAL_POINT), ' [cm] from Origin'];
            settings_spectrum{6} = 2 * INITIAL_POINT; % Data index
            settings_spectrum{7} = linspace(obj.StartFreq, obj.EndFreq, obj.NumPoints); % % X axis
            settings_spectrum{8} = extractWidths(y_vals, DISPLAYED_SCANS, settings_spectrum{6}); % Y axis

            % FREQUENCY DOMAIN SETTINGS
            settings_frequency{1} = [0 tubeLength]; % X lim
            settings_frequency{2} = [1, obj.NumPoints]; % Slider lim
            settings_frequency{3} = 1; % Slider step
            settings_frequency{4} = INITIAL_FREQUENCY; % Slider init
            settings_frequency{5} = ['Intensity along the Slit @ ', num2str(INITIAL_FREQUENCY), ' [Hz]']; % Plot name
            settings_frequency{6} = 1 + round((INITIAL_FREQUENCY - obj.StartFreq)/freq_spacing); % Data index
            settings_frequency{7} = linspace(0, tubeLength, obj.NumMeasurements); % % X axis
            settings_frequency{8} = extractHeights(y_vals, DISPLAYED_SCANS, settings_frequency{6}); % Y axis

            plot_settings{1} = settings_frequency;
            plot_settings{2} = settings_spectrum;
            settings = plot_settings{SPECTRUM + 1};

            % Initial plot
            plot(obj.Axis, settings{7}, settings{8}, 'LineWidth', 2);
            xlim(obj.Axis, settings{1});
            info = cell(1, length(DISPLAYED_SCANS));
            for i = 1:length(DISPLAYED_SCANS)
                info{i} = ['Scan ' num2str(DISPLAYED_SCANS(i))];
            end
            legend(obj.Axis, info, 'Location', 'northeastoutside', 'FontSize', 16);
            title(obj.Axis, settings{5}, ...
                'FontSize', 24, ...
                'FontWeight','Bold', ...
                'FontName', 'Times New Roman');

            sld = uislider(obj.GridLayout, ...
                'Position', [100, 50, 450, 3], ...
                'Limits', settings{2}, ...
                'Value', settings{6}, ...
                'Step', settings{3}, ...
                'ValueChangedFcn', @(sld, event) obj.sliderUpdate(sld, plot_settings));
            sld.Layout.Row = 2;
            sld.Layout.Column = 1;

            %% ==================== TAB 2 ====================

            uilabel('Text', 'Settings', ...
                'Parent', obj.Tab2, ...
                'FontSize', 40, ...
                'FontWeight', 'Bold', ...
                'Position', [50 obj.FigH - 100 200 50]);

            uilabel('Text', 'Plot Settings', ...
                'Parent', obj.Tab2, ...
                'FontSize', 16, ...
                'FontWeight', 'Bold', ...
                'Position', [50 obj.FigH - 180 200 50]);

            hiddenStates = {' ', ' '};
            labelTexts = {'Intensity along the slit', 'Spectrum at point'};
            lbl = uilabel(obj.Tab2, ...
                'Text', labelTexts{SPECTRUM + 1}, ...
                'Position', [105, obj.FigH - 220, 200, 20]);

            uiswitch(obj.Tab2, 'slider', ...
                'Value', 'Off', ...
                'ValueChangedFcn', @(src, event) obj.modifyLayout(lbl, labelTexts, sld, plot_settings), ...
                'Position', [50, obj.FigH - 220, 45, 20], ...
                'Items', hiddenStates, ...
                'Value', hiddenStates{SPECTRUM + 1});

            hiddenStates1 = {' ', ' '};
            labelTexts1 = {'Magnitude', 'Phase'};
            lbl1 = uilabel(obj.Tab2, ...
                'Text', labelTexts1{PHASE + 1}, ...
                'Position', [105, obj.FigH - 250, 200, 20]);

            uiswitch(obj.Tab2, 'slider', ...
                'Value', 'Off', ...
                'ValueChangedFcn', @(src, event) obj.modifyY(lbl1, labelTexts1, plot_settings, sld), ...
                'Position', [50, obj.FigH - 250, 45, 20], ...
                'Items', hiddenStates1, ...
                'Value', hiddenStates{PHASE + 1});

            uilabel('Text', 'Available Scans', ...
                'Parent', obj.Tab2, ...
                'FontSize', 16, ...
                'FontWeight', 'Bold', ...
                'Position', [550 obj.FigH - 180 200 50]);

            for num = 1:length(y_vals)
                value = 0;
                if any(DISPLAYED_SCANS == num)
                    value = 1;
                end
                uicheckbox('Text', ['  Scan' num2str(num)], ...
                    'Parent', obj.Tab2, ...
                    'Value', value, ...
                    'UserData', num, ...
                    'ValueChangedFcn', @(src, event) obj.updateScan(src, sld, plot_settings), ...
                    'Position', [550 obj.FigH - (200+30*num) 200 50]);
            end
        end

        % Called each time a plot update is required
        function updatePlot(obj, index, plot_settings)
            global SPECTRUM DISPLAYED_SCANS PHASE;

            y_vals = obj.Data{PHASE + 1};
            if SPECTRUM == 1
                y = extractWidths(y_vals, DISPLAYED_SCANS, index);
            else
                y = extractHeights(y_vals, DISPLAYED_SCANS, index);
            end
            settings = plot_settings{SPECTRUM + 1};
            cla(obj.Axis);
            plot(obj.Axis, settings{7}, y, 'LineWidth', 2);
            info = cell(1, length(DISPLAYED_SCANS));
            for i = 1:length(DISPLAYED_SCANS)
                info{i} = ['Scan ' num2str(DISPLAYED_SCANS(i))];
            end
            legend(obj.Axis, info, 'Location', 'northeastoutside', 'FontSize', 16);
        end


        % Handler for the slider
        function sliderUpdate(obj, sld, plot_settings)

            global SPECTRUM DISPLAYED_SCANS;

            if SPECTRUM == 1
                index =  2 * sld.Value + 1; % Get current slider value\
                title(obj.Axis, ['Spectrum @ ', num2str((index - 1)/ 2), ' [cm] from Origin']); % In spectrum at point title is point
            else
                index = sld.Value; % Get current slider value\
                freq = obj.StartFreq + (index - 1) * (obj.EndFreq - obj.StartFreq) / (obj.NumPoints - 1); % In frequency along the axis title is frequency
                title(obj.Axis, ['Intensity along the Slit @ ', num2str(freq), ' [hz]']); % Update title
            end
            updatePlot(obj, index, plot_settings);
        end


        % Callback for first toggle button
        function modifyLayout(obj, lbl, labelTexts, sld, plot_settings)
            global SPECTRUM;

            SPECTRUM = ~SPECTRUM;
            lbl.Text = labelTexts(SPECTRUM + 1);
            cla(obj.Axis);

            settings = plot_settings{SPECTRUM + 1};
            sld.Limits = settings{2};
            sld.Value = settings{6};
            sld.Step = settings{3};

            xlim(obj.Axis, settings{1});
            title(obj.Axis, settings{5}, ...
                'FontSize', 24, ...
                'FontWeight','Bold', ...
                'FontName', 'Times New Roman');

            if SPECTRUM == 1
                index =  2 * sld.Value + 1;
            else
                index = sld.Value;
            end
            updatePlot(obj, index, plot_settings);

        end


        % Callback for second toggle button
        function modifyY(obj, lbl1, labelTexts1, plot_settings, sld)
            global SPECTRUM PHASE;

            PHASE = ~PHASE;
            lbl1.Text = labelTexts1(PHASE + 1);
            if SPECTRUM == 1
                index =  2 * sld.Value + 1; % Get current slider value\
            else
                index = sld.Value; % Get current slider value\
            end
            updatePlot(obj, index, plot_settings);
        end

        function updateScan(obj, src, sld, plot_settings)
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
            updatePlot(obj, index, plot_settings);
        end
    end
end