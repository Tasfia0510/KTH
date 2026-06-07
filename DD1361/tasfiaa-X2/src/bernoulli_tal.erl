-module(bernoulli_tal).
% tallar om vilka funktioner vi får anropa
-export([b/1, print_bernoulli/1]).

% För att köra:
% 1. erl
% 2. c(bernoulli_tal).
% 3. bernoulli_tal:print_bernoulli(10).

b(N) -> 
    % B(0) är alltid 1 
    B0 = 1, 

    % startar yttre loopen med m = 1, N=de vi vill ha, och listan börjar med B(0)=1
    % PSEUDOKOD for m←1 to n do
    b_loop1(1, N, [B0]). 

% PSEUDOKOD return B[n] - basfall, när loopen är klar M > N
% lists:nth hämtar element från en position, vi hämtar bernoulli talen från en position
% när loopen är klar, returnerar B(N), pseudokod är 0 indexerat, mem Erlang är 1 indexerat därav N+1
b_loop1(M, N, Bernoulli_Nums) when M > N -> 
    lists:nth(N+1, Bernoulli_Nums);

% PSEUDOKOD rad 3-7 - rekursiva steget 
b_loop1(M, N, Bernoulli_Nums) ->
    M = length(Bernoulli_Nums),
    K_values = lists:seq(0, M-1),

    % foldl loopar igenom alla k och bygger upp Sum med en ackumulator som börjar från 0 
    % Sum är resultatet av den inre loopen B[m] som vi senare kan subtrahera ifrån
    Sum = lists:foldl(
        fun(K, Ack) ->
        B_K = lists:nth(K+1, Bernoulli_Nums),
        Ack - binom(M+1, K) * B_K
        end, 0, K_values),
    
% ger det färga bernoulli talet 
B_M = Sum / (M+1),

% lägger till bernoulli talet i slutet av listan med ++ och anropar sig själv igen
b_loop1(M+1, N, Bernoulli_Nums ++ [B_M]).

% foldl bygger upp produkten r, börjar på 1
binom(N, K) ->
    Iter = lists:seq(1,K),
    lists:foldl(
        fun(I, R) ->
        R * (N-I+1) / I end, 
        1, Iter).

% printar ut 10 bernoulli tal, lists:foreach printar endast, ger inget värdet
print_bernoulli(Max) -> 
lists:foreach(
    fun(I) ->
        io:format("B(~p) = ~p~n", [I, b(I)])
    end,
    lists:seq(0,Max-1)).








% Viktiga koncept inom erlang:
% - rekursion istället för loopar
% - oföränderliga variabler
% - mycket smidigare att jobba i listor än arrayer
