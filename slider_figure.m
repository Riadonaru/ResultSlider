function slider_figure(sf, ef, np)   
    % 1. Create a UI figure window
    fig = uifigure('Name', 'Intensity along the Slit', 'Position', [100, 100, 600, 400]);

    % Create a 1x1 grid layout that fills the entire figure
    g = uigridlayout(fig, [2, 2]);
    g.RowHeight = {'10x', '1x'};
    g.ColumnWidth = {'5x', '1x'};

    % Create axes inside the grid and center it
    ax = uiaxes(g);
    ax.Layout.Row = 1;
    ax.Layout.Column = [1, 2];
    
    % Initial data setup
    x = linspace(1, 2);
    y = sin(x);
    freq = sf; % Initial frequency
    
    % Initial plot
    p = plot(ax, x, y, 'LineWidth', 2);
    ax.XLim = [0, 2*pi];
    ax.YLim = [-1.5, 1.5];
    title(ax, ['Frequency: ', num2str(freq)]);

    % 3. Create a UI slider component
    txtField = uieditfield(g, 'text', ...
        'Position', [100, 200, 150, 30], ...
        'Value', num2str(freq), ...
        'ValueChangedFcn', @(txtField, event) disp(txtField.Value));
    txtField.Layout.Row = 2;
    txtField.Layout.Column =2;

    sld = uislider(g, ...
        'Position', [100, 50, 450, 3], ...
        'Limits', [1, np], ...
        'Value', freq, ...
        'ValueChangedFcn', @(sld, event) sliderUpdate(sld, txtField, p, x, ax, sf, ef, np));
    sld.Layout.Row = 2;
    sld.Layout.Column = 1;
end

% 4. Callback function to update the plot when the slider moves
function sliderUpdate(sld, txtField, p, x, ax, sf, ef, np)
    index = round(sld.Value) - 1; % Get current slider value
    freq = sf + index * (ef - sf) / (np - 1);
    p.YData = sin(freq * x);  % Update plot y-data
    title(ax, ['Frequency: ', num2str(freq)]); % Update title
    txtField.Value = num2str(freq);
end