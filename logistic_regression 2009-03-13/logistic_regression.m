function logistic_regression
%
% Geoffrey Stewart Morrison
% Version of 2009-03-13
% sucessfully tested in Matlab R2008b running under Windows XP
% Statistics Toolbox is required
% compiled version uses MCR7.9
%
% This software runs the logistic regression analyses reported in:
%       Morrison, G. S., & Kondaurova, M. V. (submitted 2009-03-03)
%       Multivariate logistic regression analysis of vowel perception data from Kondaurova and Francis
%       [J. Acoust Soc. Am.124, 3959–3971 (2008)] (L)
%
% Data from:
%       Kodaurova, M. V., & Francis, A. L. (2008)
%       The relationship between native allophonic experience with vowel duration 
%       and perception of the English tense/lax vowel contrast by Spanish and Russian listeners
%       Journal of the Acoustical Society of America, 124, 3959--3971.
%
% For an intoduction to the use of logistic regression with this type of data see:
%       Morrison, G. S. (2007). 
%       Logistic regression modelling for first- and second-language perception data. 
%       In M. J. Solé, P. Prieto, & J. Mascaró(Eds.), 
%       Segmental and prosodic issues in Romance phonology (pp. 219--236).
%       Amsterdam: John Benjamins.


% read in input arguments
read_input_arguments

% start screen
fullscreenfigure(999);
set(999, 'Name', 'Logistic Regression Software', 'NumberTitle', 'off');
text(-0.05,1,'Logistic Regression Software', 'FontName','Times', 'Fontsize',30, 'Units','normalized', 'HorizontalAlignment','left', 'VerticalAlignment','top');
text(-0.05,0.025,'Release 2009-03-07', 'FontName','Times', 'Fontsize',10, 'Units','normalized', 'HorizontalAlignment','left', 'VerticalAlignment','top');
text(-0.05,0,'© Geoffrey Stewart Morrison', 'FontName','Times', 'Fontsize',10, 'Units','normalized', 'HorizontalAlignment','left', 'VerticalAlignment','top');
text(-0.05,-0.025,'http://geoff-morrison.net', 'FontName','Times', 'Fontsize',10, 'Units','normalized', 'HorizontalAlignment','left', 'VerticalAlignment','top');
axis off
options_gui

h_message = text(.5,.7,'Running Analysis. Please Wait.', 'FontName','Times', 'Fontsize',25, 'Units','normalized', 'HorizontalAlignment','center', 'VerticalAlignment','top', 'EraseMode','xor');


% default and initial values
if isempty(lang_label)
    lang_label = 'English';                 % English             Russian             Spanish
end
datafile = ['data_', lang_label, '.txt'];   % data_english.txt    data_russian.txt    data_spanish.txt
text_output_file = ['Logistic_Regression_output_', lang_label, '.txt'];

if isempty(stimcols)
    stimcols = {'listener' 'spec' 'dur'};
else
    stimcols = eval(stimcols);
end
stim_labels = stimcols(2:end);
num_stim_dims = length(stim_labels);

if isempty(respcols)
    respcols = {'/I/' '/i/'};
else
    respcols = eval(respcols);
end
num_cat = length(respcols);

if isempty(models)
    models = {'spec' 'dur' 'spec+dur' 'spec+dur+spec*dur'};
else
    models = eval(models);
end
num_models = length(models);

if isempty(default_model)
    default_model = 3;
else
    default_model = eval(default_model);
end

if isempty(save_coefs)
    save_coefs = false;
else
    save_coefs = eval(save_coefs);
end
if save_coefs
    savefile = ['coefs_', lang_label, '.txt'];     % coefs_english.mat   coefs_russian.mat   coefs_spanish.mat
end

if isempty(compareG2)
    compareG2 = false;
    num_hyps = 0;
else
    compareG2 = eval(compareG2);
end
if compareG2
    if isempty(hyp_pairs)
        hyp_pairs = [1 3; 2 3; 3 4];
    else
        hyp_pairs = eval(hyp_pairs);
    end
    num_hyps = size(hyp_pairs, 1);
else
    num_hyps = 1;
end

if compareG2
    model_to_plot = default_model;
    model_to_save = default_model;
else
    models = models(default_model);
    num_models = 1;
    model_to_plot = 1;
    model_to_save = 1;
end

if isempty(make_plots)
    make_plots = false;
else
    make_plots = eval(make_plots);
end
if make_plots
    if isempty(colours)
        colours = {'r' 'g'};
    else
        colours = eval(colours);
    end
    if isempty(orientation)
        orientation = [45 45];
    else
        orientation = eval(orientation);
    end
    if isempty(axis_labels)
        axis_labels	= {'spectral properties' 'duration'};
    else
        axis_labels = eval(axis_labels);
    end
end

% load stimulus properties and response data
data = load(datafile);
response_matrix_all = data(:, end-num_cat+1:end);
stim_matrix_all = data(:, 2:num_stim_dims+1);
II_listeners =  data(:, 1);
listenersIDs = unique(II_listeners);
num_listeners = length(listenersIDs);

% reserve spece for variables
B = cell(num_listeners, num_models);
B_deviation_from_mean = cell(num_listeners, num_models);
G2 = NaN(num_listeners, num_models);
df = NaN(num_listeners, num_models);
deltaG2 = NaN(num_listeners, num_hyps);
delta_df = NaN(num_listeners, num_hyps);
p = NaN(num_listeners, num_hyps);

% conduct analysis writing output to file
fid = fopen(text_output_file, 'wt');
fprintf(fid, 'LOGISTIC REGRESSION ANALYSIS\n');
for I_listener = 1:num_listeners
    fprintf(fid, '------------------------\n');
    fprintf(fid, '------------------------\n');
    fprintf(fid, 'LISTENER: %02.0f\n', listenersIDs(I_listener));
    II_this_listener = II_listeners == listenersIDs(I_listener);
    
    fprintf(fid, '------------------------\n');
    fprintf(fid, 'MODELS:\n');
    for Imodel = 1:length(models)
        % format input according to model to be tested
        [stim_matrix, var_string] = parse_model(stim_matrix_all(II_this_listener, :), stim_labels, models{Imodel});

        % multinomial logistic regression
        [B{I_listener, Imodel}, G2(I_listener, Imodel), stats] = mnrfit(stim_matrix, response_matrix_all(II_this_listener, :), 'interactions', 'on');
        df(I_listener, Imodel) = stats.dfe;

        % calculate deviation-from-mean coefficient values
        B_redundant = [B{I_listener, Imodel}, zeros(size(B{I_listener, Imodel},1),1)];
        B_mean = repmat( mean(B_redundant,2), [1 size(B_redundant,2)]);
        B_deviation_from_mean{I_listener, Imodel} = B_redundant - B_mean;

        fprintf(fid, '------------------------\n');
        fprintf(fid, '%s\n', models{Imodel});
        fprintf(fid, 'G2: %0.0f \tdf: %0.0f \n', G2(I_listener, Imodel), df(I_listener, Imodel));
        print_str = repmat('%s\t', 1, num_cat);
        print_str(end) = 'n';
        fprintf(fid, print_str, respcols{:});
        print_str = repmat('%0.3f\t', 1, num_cat);
        print_str(end) = 'n';
        fprintf(fid, print_str, B_deviation_from_mean{I_listener, Imodel}');
    end

    if compareG2
        fprintf(fid, '------------------------\n');
        fprintf(fid, 'MODEL COMPARISONS:\n');
        for I_hype = 1:num_hyps
            fprintf(fid, '------------------------\n');
            deltaG2(I_listener, I_hype) = G2(I_listener, hyp_pairs(I_hype, 1)) - G2(I_listener, hyp_pairs(I_hype, 2));
            delta_df(I_listener, I_hype) = df(I_listener, hyp_pairs(I_hype, 1)) - df(I_listener, hyp_pairs(I_hype, 2));
            p(I_listener, I_hype) = 1 - chi2cdf(deltaG2(I_listener, I_hype), delta_df(I_listener, I_hype));
            fprintf(fid, '%s v %s\n', models{hyp_pairs(I_hype, 1)}, models{hyp_pairs(I_hype, 2)});
            fprintf(fid, 'deltaG2:\t%0.2f\ndelta_df:\t%0.0f\np:\t\t%0.4f\n', deltaG2(I_listener, I_hype), delta_df(I_listener, I_hype), p(I_listener, I_hype));
        end
    end
end
fclose(fid);

% write coef values from default model to file
if save_coefs
    coefs = cell2mat(B_deviation_from_mean(:, model_to_save));
    listenersIDs_coefs = repmat(listenersIDs, 1, size(B{1, model_to_save}, 1))';
    coefs_to_print = [listenersIDs_coefs(:), coefs];
    fid = fopen(savefile, 'wt');
    print_str = ['%02.0f\t', repmat('%0.4f\t', 1, num_cat)];
    print_str(end) = 'n';
    fprintf(fid, print_str, coefs_to_print');
    fclose(fid);
end

if make_plots
    XminYmin = min(stim_matrix); Xmin = XminYmin(1); Ymin = XminYmin(2); 
    XmaxYmax = max(stim_matrix); Xmax = XmaxYmax(1); Ymax = XmaxYmax(2); 
    Xrange = Xmax - Xmin; Yrange = Ymax - Ymin;
    X = Xmin: Xrange/99 : Xmax;
    Y = Ymin: Yrange/99 : Ymax;
    lengthX = length(X);
    lengthY = length(Y);
    [XX, YY] = meshgrid(X, Y);
    XY = [XX(:), YY(:)];
    for I_listener = 1:num_listeners
        figure;
        for I_cat = 1:num_cat
            Z = mnrval(B{I_listener, model_to_plot}, XY, 'interactions', 'on');
            ZZ = reshape(Z(:,I_cat), lengthX, lengthY);
            surface(XX, YY, ZZ, 'FaceColor',colours{I_cat}, 'EdgeColor','none');
            hold on
        end
        legend(respcols);
        axis tight
        %set(gca,'XTick',1:8, 'YTick', 1:8);
        view(orientation);
        grid on
        box on
        xlabel(axis_labels{1}); ylabel(axis_labels{2}); zlabel('probability');
        title_str = [lang_label, ' listener ', num2str(listenersIDs(I_listener), '%02.0f')];
        title(title_str);
        hold off
    end
end

% display output file
set(h_message, 'String','Analysis Complete.');
dos(['notepad ', text_output_file, ' &']);

