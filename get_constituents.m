clc
clear

%% Settings

INDEX_NAME = 'SX5E Index'; %S&P BSE 100 Index SX5E Index
N = 700;
start_date = datetime(1984, 01, 01); % YYYY, MM, DD
end_date = datetime(2020, 11, 01);


%% Start
% import javascript instance for bloomberg to work
javaaddpath c:\blp\DAPI\blpapi3.jar

% import bloomberg
b = blp;

% specify the desired datetime format
datetime.setDefaultFormats('defaultdate','yyyyMMdd') % yyyyMMdd
formatOut = "yyyyMMdd"

% specify what are the start and end date
%start_date = datetime(2000,01,01);
%end_date = datetime(2000,01,10);
%end_date = datetime(2019,10,10);

% create datetime vector with all the dates you want 
% // comment out what you don't need

% ------ DAILY:
vector_date = start_date:end_date; 

% ------ MONTHLY-- But get last trading day just so you can use for
% backtest
 last_days_of_month = unique(eomdate(vector_date));
 for i= 1:length(last_days_of_month)
     year = last_days_of_month(i).Year;
     month = last_days_of_month(i).Month;
     last_days_of_month(i) = lbusdate(year, month,[],[],'datetime'); 
 end
 num_month_temp = length(last_days_of_month);
 num_month_temp = num_month_temp - 1; % COMMENT OUT IF YOU WANT TO INCLUDE THE LAST MONTH
 vector_date = last_days_of_month(1:num_month_temp);

% ------ WEEKLY
%vector_date = vector_date(weekday(vector_date) == 7); % only get mondays
% 
%vector_date_str = strcat('date_', datestr(vector_date,'yyyy_mm_dd'));


% get constituents data
base_cell = cellstr(repmat('NaN', N, 1));

% Get data
current_date = vector_date(1);
char_date = char(current_date);

bloomberg_data = getdata(b, INDEX_NAME,{'INDX_MWEIGHT_HIST'},{'END_DT'},{char_date});
bloomberg_data = bloomberg_data.INDX_MWEIGHT_HIST{1,1};

index_constituents = base_cell;
index_constituents_temp = bloomberg_data(:,1); % actual index constituents data for the current date % {'UXX Index', 'U1234', 'ULV Index', 'UXVIXX Index', 'SIC Index'}
index_constituents(1:length(index_constituents_temp)) = index_constituents_temp;
all_index_constituents_table = cell2table(index_constituents);
all_index_constituents_table.Properties.VariableNames = cellstr(strcat('date_', datestr(current_date,'yyyy_mm_dd')));



% LOOP
for current_date = vector_date(2:end)
    
    % current_date = vector_date(2);
    char_date = char(current_date)
    
    bloomberg_data = getdata(b, INDEX_NAME,{'INDX_MWEIGHT_HIST'},{'END_DT'},{char_date});
    bloomberg_data = bloomberg_data.INDX_MWEIGHT_HIST{1,1};
    
    index_constituents = base_cell;
    index_constituents_temp = bloomberg_data(:,1); % actual index constituents data for the current date % {'ABC Index', 'DEF', 'GHI Index'}
    index_constituents(1:length(index_constituents_temp)) = index_constituents_temp;
    index_constituents_table = cell2table(index_constituents);
    index_constituents_table.Properties.VariableNames = cellstr(strcat('date_', datestr(current_date,'yyyy_mm_dd')));
    all_index_constituents_table = [all_index_constituents_table, index_constituents_table];

end

index_name = strrep(INDEX_NAME, ' ', '_')
filename = strcat('all_', index_name, '_constituents_from_', datestr(start_date,'yyyy-mm-dd'), '_to_', datestr(end_date,'yyyy-mm-dd'), '.csv')
writetable(all_index_constituents_table, filename)

    

