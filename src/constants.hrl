-define(BUCKET, {<<"default">>,<<"ITEM">>}).

-define(KEY, <<"KEY">>).

%% Delays the execution of updates in milliseconds
-define(MIN_INTERVAL, 50).

-define(TIME_UNIT, 1000).

-define(DEFAULT_TIMEOUT, 30000).

%%Replication may have to be changed between experiments, this should be a aprameter
-define(REPLICATION_FACTOR,1).


%% 10 second interval
-define(PLOT_INTERVAL, 10000000).

