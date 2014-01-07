%%%-------------------------------------------------------------------
%%% @author balegas
%%% @copyright (C) 2013, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. Dez 2013 19:10
%%%-------------------------------------------------------------------
-module(client).
-author("balegas").
-include("constants.hrl").

%% API
-export([init/4, loop/2, reset/4]).

-record(client, {id :: term(), worker:: worker_rc:worker(), succ_count :: integer(), op_count :: integer(), stats_pid :: term()}).

loop(init, Client) ->
  Client#client.stats_pid ! start,
  loop(worker_rc:get_value(Client#client.worker),Client);

loop(Value, Client) when Value =< 0 ->
  Client#client.stats_pid ! stop;

loop(Value, Client) ->
  InitTime = now(),
  ClientMod = Client#client{op_count=Client#client.op_count+1},
  
  TT=?MIN_INTERVAL- random:uniform(?MIN_INTERVAL div 3),
  timer:sleep(TT),
  
  case worker_rc:update_value_crdt(Client#client.worker) of
    {ok, UpdValue} ->
      Client#client.stats_pid ! {self(), UpdValue, timer:now_diff(now(),InitTime),InitTime,success},
      ClientMod2 = Client#client{op_count=ClientMod#client.op_count+1},
      loop(UpdValue,ClientMod2);
    fail ->
      Client#client.stats_pid ! {self(), Value, timer:now_diff(now(),InitTime),InitTime,failure},
      loop(Value,Client);
    {forbidden,CRDT} ->
      loop(nncounter:value(CRDT),ClientMod);
    {finished, V} ->
      loop(V,ClientMod)
  end.

init(N,NodeAddress,Bucket,Id)->
  Stats = client_stats:start(lists:concat(["T",N,"-",erlang:binary_to_list(element(1,Bucket))])),
  init(Stats,N,NodeAddress,Bucket,Id).

init(_,0,_,_,_) ->
  receive
    _ -> io:format("Statistics stopped"),
      timer:sleep(2000),
      ok
  end;


init(Stats,N,NodeAddress,Bucket,Id)->
    Client = #client{id=client, worker=worker_rc:init(NodeAddress,Bucket,Id),
      succ_count = 0, op_count=0, stats_pid = Stats},
	spawn_monitor(client,loop,[init,Client]),
	init(Stats,N-1,NodeAddress,Bucket,Id).


reset(V,Bucket,LocalId,AllAddressIds)  ->
  worker_rc:reset_crdt(V,Bucket,LocalId,AllAddressIds).

