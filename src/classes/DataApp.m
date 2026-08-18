classdef DataApp < handle
    % The '< handle' part is critical so updates modify the original object

    properties (SetAccess = private)
        FigH = 800;
        FigW = 1200;
        HALF_CM = 671; % Conversion constant [MotorStep --> cm]
        INITIAL_POINT = 20; % Slider starting position for Spectrum at point
        INITIAL_FREQUENCY = 10.2498; % Slider starting position for Intensity along the slit
        DISPLAYED_SCANS = [1]; % Batches to show on plot
        PLOT_TYPE = 0; % 1 = Phase graph 0 = Magnitude graph
        PLOT_SET = 0; % 1 = Spectrum at point, 0 = Intensity along the slit
        Label1Texts = {'Intensity along the slit', 'Spectrum at point'};
        Label2Texts = {'Magnitude', 'Phase'};
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
        Slider
        Label1
        Label2
        Settings = {}

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

            % Infer tube length and array index from experiment parameters
            diff = (obj.StepSize/obj.HALF_CM) * 0.5; % Conversion stepSize ---> [cm]
            tubeLength = (obj.NumMeasurements - 1) * diff;

            freq_spacing = (obj.EndFreq - obj.StartFreq) / (obj.NumPoints-1);

            y_vals = obj.Data{obj.PLOT_TYPE + 1};  

            % SPECTRUM DOMAIN SETTINGS
            SpectrumSettingsInitial = Settings();
            SpectrumSettingsInitial.XLim = [obj.StartFreq obj.EndFreq];
            SpectrumSettingsInitial.SliderLim = [0, tubeLength];
            SpectrumSettingsInitial.SliderStep = 0.5;
            SpectrumSettingsInitial.PlotName = ['Spectrum @ ', num2str(obj.INITIAL_POINT), ' [cm] from Origin'];
            SpectrumSettingsInitial.SliderInit = 2 * obj.INITIAL_POINT;
            SpectrumSettingsInitial.XData = linspace(obj.StartFreq, obj.EndFreq, obj.NumPoints);
            SpectrumSettingsInitial.YData = ExtractWidths(y_vals, obj.DISPLAYED_SCANS, SpectrumSettingsInitial.SliderInit);

            % FREQUENCY DOMAIN SETTINGS
            FrequencySettingsInitial = Settings();
            FrequencySettingsInitial.XLim = [0 tubeLength];
            FrequencySettingsInitial.SliderLim = [1, obj.NumPoints];
            FrequencySettingsInitial.SliderStep = 1;
            FrequencySettingsInitial.PlotName = ['Intensity along the Slit @ ', num2str(obj.INITIAL_FREQUENCY), ' [Hz]'];
            FrequencySettingsInitial.SliderInit = 1 + round((obj.INITIAL_FREQUENCY - obj.StartFreq)/freq_spacing);
            FrequencySettingsInitial.XData = linspace(0, tubeLength, obj.NumMeasurements);
            FrequencySettingsInitial.YData = ExtractHeights(y_vals, obj.DISPLAYED_SCANS, FrequencySettingsInitial.SliderInit);


            obj.Settings{1} = FrequencySettingsInitial;
            obj.Settings{2} = SpectrumSettingsInitial;

            settings = obj.Settings{obj.PLOT_SET + 1};

            obj.Slider = uislider(obj.GridLayout, ...
                'Position', [100, 50, 450, 3], ...
                'Limits', settings.SliderLim, ...
                'Value', settings.SliderInit, ...
                'Step', settings.SliderStep, ...
                'ValueChangedFcn', @(src, event) obj.sliderUpdate());
            obj.Slider.Layout.Row = 2;
            obj.Slider.Layout.Column = 1;

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
            obj.Label1 = uilabel(obj.Tab2, ...
                'Text', obj.Label1Texts{obj.PLOT_SET + 1}, ...
                'Position', [105, obj.FigH - 220, 200, 20]);

            uiswitch(obj.Tab2, 'slider', ...
                'Value', 'Off', ...
                'ValueChangedFcn', @(src, event) obj.modifyLayout(), ...
                'Position', [50, obj.FigH - 220, 45, 20], ...
                'Items', hiddenStates, ...
                'Value', hiddenStates{obj.PLOT_SET + 1});

            obj.Label2 = uilabel(obj.Tab2, ...
                'Text', obj.Label2Texts{obj.PLOT_TYPE + 1}, ...
                'Position', [105, obj.FigH - 250, 200, 20]);

            uiswitch(obj.Tab2, 'slider', ...
                'Value', 'Off', ...
                'ValueChangedFcn', @(src, event) obj.modifyY(), ...
                'Position', [50, obj.FigH - 250, 45, 20], ...
                'Items', hiddenStates, ...
                'Value', hiddenStates{obj.PLOT_TYPE + 1});

            uilabel('Text', 'Available Scans', ...
                'Parent', obj.Tab2, ...
                'FontSize', 16, ...
                'FontWeight', 'Bold', ...
                'Position', [550 obj.FigH - 180 200 50]);

            for num = 1:length(y_vals)
                value = 0;
                if any(obj.DISPLAYED_SCANS == num)
                    value = 1;
                end
                uicheckbox('Text', ['  Scan' num2str(num)], ...
                    'Parent', obj.Tab2, ...
                    'Value', value, ...
                    'UserData', num, ...
                    'ValueChangedFcn', @(src, event) obj.updateScan(src), ...
                    'Position', [550 obj.FigH - (200+30*num) 200 50]);
            end

        end

        function ShowDefault(obj)
            settings = obj.Settings{obj.PLOT_SET + 1};

            % Initial plot
            plot(obj.Axis, settings.XData, settings.YData, 'LineWidth', 2);
            xlim(obj.Axis, settings.XLim);
            info = cell(1, length(obj.DISPLAYED_SCANS));
            for i = 1:length(obj.DISPLAYED_SCANS)
                info{i} = ['Scan ' num2str(obj.DISPLAYED_SCANS(i))];
            end
            legend(obj.Axis, info, 'Location', 'northeastoutside', 'FontSize', 16);
            title(obj.Axis, settings.PlotName, ...
                'FontSize', 24, ...
                'FontWeight','Bold', ...
                'FontName', 'Times New Roman');

        end

        % Called each time a plot update is required
        function updatePlot(obj, index)

            y_vals = obj.Data{obj.PLOT_TYPE + 1};
            if obj.PLOT_SET == 1
                y = ExtractWidths(y_vals, obj.DISPLAYED_SCANS, index);
            else
                y = ExtractHeights(y_vals, obj.DISPLAYED_SCANS, index);
            end
            settings = obj.Settings{obj.PLOT_SET + 1};
            cla(obj.Axis);
            plot(obj.Axis, settings.XData, y, 'LineWidth', 2);
            info = cell(1, length(obj.DISPLAYED_SCANS));
            for i = 1:length(obj.DISPLAYED_SCANS)
                info{i} = ['Scan ' num2str(obj.DISPLAYED_SCANS(i))];
            end
            legend(obj.Axis, info, 'Location', 'northeastoutside', 'FontSize', 16);
        end


        % Handler for the slider
        function sliderUpdate(obj)

            if obj.PLOT_SET == 1
                index =  2 * obj.Slider.Value + 1; % Get current slider value\
                title(obj.Axis, ['Spectrum @ ', num2str((index - 1)/ 2), ' [cm] from Origin']); % In spectrum at point title is point
            else
                index = obj.Slider.Value; % Get current slider value\
                freq = obj.StartFreq + (index - 1) * (obj.EndFreq - obj.StartFreq) / (obj.NumPoints - 1); % In frequency along the axis title is frequency
                title(obj.Axis, ['Intensity along the Slit @ ', num2str(freq), ' [hz]']); % Update title
            end
            obj.updatePlot(index);
        end


        % Callback for first toggle button
        function modifyLayout(obj)

            obj.PLOT_SET = ~obj.PLOT_SET;
            obj.Label1.Text = obj.Label1Texts(obj.PLOT_SET + 1);
            cla(obj.Axis);

            settings = obj.Settings{obj.PLOT_SET + 1};
            obj.Slider.Limits = settings.SliderLim;
            obj.Slider.Value = settings.SliderInit;
            obj.Slider.Step = settings.SliderStep;

            xlim(obj.Axis, settings.XLim);
            title(obj.Axis, settings.PlotName, ...
                'FontSize', 24, ...
                'FontWeight','Bold', ...
                'FontName', 'Times New Roman');

            if obj.PLOT_SET == 1
                index =  2 * obj.Slider.Value + 1;
            else
                index = obj.Slider.Value;
            end
            obj.updatePlot(index);

        end


        % Callback for second toggle button
        function modifyY(obj)

            obj.PLOT_TYPE = ~obj.PLOT_TYPE;
            obj.Label2.Text = obj.Label2Texts(obj.PLOT_TYPE + 1);
            if obj.PLOT_SET == 1
                index =  2 * obj.Slider.Value + 1; % Get current slider value\
            else
                index = obj.Slider.Value; % Get current slider value\
            end
            obj.updatePlot(index);
        end
        
        % Callback for Checkboxes
        function updateScan(obj, src)

            if src.Value == 1
                obj.DISPLAYED_SCANS = [obj.DISPLAYED_SCANS, src.UserData];
            else
                obj.DISPLAYED_SCANS(obj.DISPLAYED_SCANS == src.UserData) = [];
            end

            if obj.PLOT_SET == 1
                index =  2 * obj.Slider.Value + 1; % Get current slider value\
            else
                index = obj.Slider.Value; % Get current slider value\
            end
            obj.updatePlot(index);
        end
    end
end