-file("/Users/fceruti/.local/share/rtx/installs/erlang/26.0.2/lib/parsetools-2.5/include/leexinc.hrl", 0).
%% The source of this file is part of leex distribution, as such it
%% has the same Copyright as the other files in the leex
%% distribution. The Copyright is defined in the accompanying file
%% COPYRIGHT. However, the resultant scanner generated by leex is the
%% property of the creator of the scanner and is not covered by that
%% Copyright.

-module(css_lexer).

-export([string/1,string/2,token/2,token/3,tokens/2,tokens/3]).
-export([format_error/1]).

%% User code. This is placed here to allow extra attributes.
-file("src/css_lexer.xrl", 17).

extract_property(Chars) -> 
  C1 = list_to_binary(Chars),
  C2 = string:replace(C1, ";", ""),
  C3 = string:strip(C2),
  [Property, Value] = string:split(C3, ":"),
  {string:trim(Property, both), string:trim(Value, both)}.

extract_begin_selector(Chars) ->
  C1 = list_to_binary(Chars),
  C2 = string:replace(C1, "{", ""),
  string:trim(C2).

extract_apply(Chars) ->
  C1 = list_to_binary(Chars),
  C2 = string:replace(C1, ";", ""),
  C3 = string:replace(C2, "@apply", ""),
  string:trim(C3).

-file("/Users/fceruti/.local/share/rtx/installs/erlang/26.0.2/lib/parsetools-2.5/include/leexinc.hrl", 14).

format_error({illegal,S}) -> ["illegal characters ",io_lib:write_string(S)];
format_error({user,S}) -> S.

%% string(InChars) ->
%% string(InChars, Loc) ->
%% {ok,Tokens,EndLoc} | {error,ErrorInfo,EndLoc}.
%% Loc is the starting location of the token, while EndLoc is the first not scanned
%% location. Location is either Line or {Line,Column}, depending on the "error_location" option.

string(Ics) -> 
    string(Ics,1).
string(Ics,L0) -> 
    string(Ics, L0, 1, Ics, []).
string(Ics, L0, C0, Tcs, Ts) -> 
    case do_string(Ics, L0, C0, Tcs, Ts) of
        {ok, T, {L,_}} -> {ok, T, L};
        {error, {{EL,_},M,D}, {L,_}} ->
            EI = {EL,M,D},
            {error, EI, L}
    end.

do_string([], L, C, [], Ts) ->                     % No partial tokens!
    {ok,yyrev(Ts),{L,C}};
do_string(Ics0, L0, C0, Tcs, Ts) ->
    case yystate(yystate(), Ics0, L0, C0, 0, reject, 0) of
        {A,Alen,Ics1,L1,_C1} ->                  % Accepting end state
            C2 = adjust_col(Tcs, Alen, C0),
            string_cont(Ics1, L1, C2, yyaction(A, Alen, Tcs, L0, C0), Ts);
        {A,Alen,Ics1,L1,_C1,_S1} ->              % Accepting transition state
            C2 = adjust_col(Tcs, Alen, C0),
            string_cont(Ics1, L1, C2, yyaction(A, Alen, Tcs, L0, C0), Ts);
        {reject,_Alen,Tlen,_Ics1,_L1,_C1,_S1} ->  % After a non-accepting state
            {error,{{L0, C0} ,?MODULE,{illegal,yypre(Tcs, Tlen+1)}},{L0, C0}};
        {A,Alen,Tlen,_Ics1,L1, C1,_S1}->
            Tcs1 = yysuf(Tcs, Alen),
            L2 = adjust_line(Tlen, Alen, Tcs1, L1),
            C2 = adjust_col(Tcs, Alen, C1),
            string_cont(Tcs1, L2, C2, yyaction(A, Alen, Tcs, L0,C0), Ts)
    end.

%% string_cont(RestChars, Line, Col, Token, Tokens)
%% Test for and remove the end token wrapper. Push back characters
%% are prepended to RestChars.

-dialyzer({nowarn_function, string_cont/5}).

string_cont(Rest, Line, Col, {token,T}, Ts) ->
    do_string(Rest, Line, Col, Rest, [T|Ts]);
string_cont(Rest, Line, Col, {token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    do_string(NewRest, Line, Col, NewRest, [T|Ts]);
string_cont(Rest, Line, Col, {end_token,T}, Ts) ->
    do_string(Rest, Line, Col, Rest, [T|Ts]);
string_cont(Rest, Line, Col, {end_token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    do_string(NewRest, Line, Col, NewRest, [T|Ts]);
string_cont(Rest, Line, Col, skip_token, Ts) ->
    do_string(Rest, Line, Col, Rest, Ts);
string_cont(Rest, Line, Col, {skip_token,Push}, Ts) ->
    NewRest = Push ++ Rest,
    do_string(NewRest, Line, Col, NewRest, Ts);
string_cont(_Rest, Line, Col, {error,S}, _Ts) ->
    {error,{{Line, Col},?MODULE,{user,S}},{Line,Col}}.

%% token(Continuation, Chars) ->
%% token(Continuation, Chars, Loc) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% Must be careful when re-entering to append the latest characters to the
%% after characters in an accept. The continuation is:
%% {token,State,CurrLine,CurrCol,TokenChars,TokenLen,TokenLine,TokenCol,AccAction,AccLen}

token(Cont,Chars) -> 
    token(Cont,Chars,1).
token(Cont, Chars, Line) -> 
    case do_token(Cont,Chars,Line,1) of
        {more, _} = C -> C;
        {done, Ret0, R} ->
            Ret1 = case Ret0 of
                {ok, T, {L,_}} -> {ok, T, L};
                {eof, {L,_}} -> {eof, L};
                {error, {{EL,_},M,D},{L,_}} -> {error, {EL,M,D},L}
            end,
            {done, Ret1, R}
    end.

do_token([], Chars, Line, Col) ->
    token(yystate(), Chars, Line, Col, Chars, 0, Line, Col, reject, 0);
do_token({token,State,Line,Col,Tcs,Tlen,Tline,Tcol,Action,Alen}, Chars, _, _) ->
    token(State, Chars, Line, Col, Tcs ++ Chars, Tlen, Tline, Tcol, Action, Alen).

%% token(State, InChars, Line, Col, TokenChars, TokenLen, TokenLine, TokenCol
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% The argument order is chosen to be more efficient.

token(S0, Ics0, L0, C0, Tcs, Tlen0, Tline, Tcol, A0, Alen0) ->
    case yystate(S0, Ics0, L0, C0, Tlen0, A0, Alen0) of
        %% Accepting end state, we have a token.
        {A1,Alen1,Ics1,L1,C1} ->
            C2 = adjust_col(Tcs, Alen1, C1),
            token_cont(Ics1, L1, C2, yyaction(A1, Alen1, Tcs, Tline,Tcol));
        %% Accepting transition state, can take more chars.
        {A1,Alen1,[],L1,C1,S1} ->                  % Need more chars to check
            {more,{token,S1,L1,C1,Tcs,Alen1,Tline,Tcol,A1,Alen1}};
        {A1,Alen1,Ics1,L1,C1,_S1} ->               % Take what we got
            C2 = adjust_col(Tcs, Alen1, C1),
            token_cont(Ics1, L1, C2, yyaction(A1, Alen1, Tcs, Tline,Tcol));
        %% After a non-accepting state, maybe reach accept state later.
        {A1,Alen1,Tlen1,[],L1,C1,S1} ->            % Need more chars to check
            {more,{token,S1,L1,C1,Tcs,Tlen1,Tline,Tcol,A1,Alen1}};
        {reject,_Alen1,Tlen1,eof,L1,C1,_S1} ->     % No token match
            %% Check for partial token which is error.
            Ret = if Tlen1 > 0 -> {error,{{Tline,Tcol},?MODULE,
                                          %% Skip eof tail in Tcs.
                                          {illegal,yypre(Tcs, Tlen1)}},{L1,C1}};
                     true -> {eof,{L1,C1}}
                  end,
            {done,Ret,eof};
        {reject,_Alen1,Tlen1,Ics1,_L1,_C1,_S1} ->    % No token match
            Error = {{Tline,Tcol},?MODULE,{illegal,yypre(Tcs, Tlen1+1)}},
            {done,{error,Error,{Tline,Tcol}},Ics1};
        {A1,Alen1,Tlen1,_Ics1,L1,_C1,_S1} ->       % Use last accept match
            Tcs1 = yysuf(Tcs, Alen1),
            L2 = adjust_line(Tlen1, Alen1, Tcs1, L1),
            C2 = C0 + Alen1,
            token_cont(Tcs1, L2, C2, yyaction(A1, Alen1, Tcs, Tline, Tcol))
    end.

%% token_cont(RestChars, Line, Col, Token)
%% If we have a token or error then return done, else if we have a
%% skip_token then continue.

-dialyzer({nowarn_function, token_cont/4}).

token_cont(Rest, Line, Col, {token,T}) ->
    {done,{ok,T,{Line,Col}},Rest};
token_cont(Rest, Line, Col, {token,T,Push}) ->
    NewRest = Push ++ Rest,
    {done,{ok,T,{Line,Col}},NewRest};
token_cont(Rest, Line, Col, {end_token,T}) ->
    {done,{ok,T,{Line,Col}},Rest};
token_cont(Rest, Line, Col, {end_token,T,Push}) ->
    NewRest = Push ++ Rest,
    {done,{ok,T,{Line,Col}},NewRest};
token_cont(Rest, Line, Col, skip_token) ->
    token(yystate(), Rest, Line, Col, Rest, 0, Line, Col, reject, 0);
token_cont(Rest, Line, Col, {skip_token,Push}) ->
    NewRest = Push ++ Rest,
    token(yystate(), NewRest, Line, Col, NewRest, 0, Line, Col, reject, 0);
token_cont(Rest, Line, Col, {error,S}) ->
    {done,{error,{{Line, Col},?MODULE,{user,S}},{Line, Col}},Rest}.

%% tokens(Continuation, Chars) ->
%% tokens(Continuation, Chars, Loc) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% Must be careful when re-entering to append the latest characters to the
%% after characters in an accept. The continuation is:
%% {tokens,State,CurrLine,CurrCol,TokenChars,TokenLen,TokenLine,TokenCur,Tokens,AccAction,AccLen}
%% {skip_tokens,State,CurrLine,CurrCol,TokenChars,TokenLen,TokenLine,TokenCur,Error,AccAction,AccLen}

tokens(Cont,Chars) -> 
    tokens(Cont,Chars,1).
tokens(Cont, Chars, Line) -> 
    case do_tokens(Cont,Chars,Line,1) of
        {more, _} = C -> C;
        {done, Ret0, R} ->
            Ret1 = case Ret0 of
                {ok, T, {L,_}} -> {ok, T, L};
                {eof, {L,_}} -> {eof, L};
                {error, {{EL,_},M,D},{L,_}} -> {error, {EL,M,D},L}
            end,
            {done, Ret1, R}
    end.

do_tokens([], Chars, Line, Col) ->
    tokens(yystate(), Chars, Line, Col, Chars, 0, Line, Col, [], reject, 0);
do_tokens({tokens,State,Line,Col,Tcs,Tlen,Tline,Tcol,Ts,Action,Alen}, Chars, _,_) ->
    tokens(State, Chars, Line, Col, Tcs ++ Chars, Tlen, Tline, Tcol, Ts, Action, Alen);
do_tokens({skip_tokens,State,Line, Col, Tcs,Tlen,Tline,Tcol,Error,Action,Alen}, Chars, _,_) ->
    skip_tokens(State, Chars, Line, Col, Tcs ++ Chars, Tlen, Tline, Tcol, Error, Action, Alen).

%% tokens(State, InChars, Line, Col, TokenChars, TokenLen, TokenLine, TokenCol,Tokens,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.

tokens(S0, Ics0, L0, C0, Tcs, Tlen0, Tline, Tcol, Ts, A0, Alen0) ->
    case yystate(S0, Ics0, L0, C0, Tlen0, A0, Alen0) of
        %% Accepting end state, we have a token.
        {A1,Alen1,Ics1,L1,C1} ->
            C2 = adjust_col(Tcs, Alen1, C1),
            tokens_cont(Ics1, L1, C2, yyaction(A1, Alen1, Tcs, Tline, Tcol), Ts);
        %% Accepting transition state, can take more chars.
        {A1,Alen1,[],L1,C1,S1} ->                  % Need more chars to check
            {more,{tokens,S1,L1,C1,Tcs,Alen1,Tline,Tcol,Ts,A1,Alen1}};
        {A1,Alen1,Ics1,L1,C1,_S1} ->               % Take what we got
            C2 = adjust_col(Tcs, Alen1, C1),
            tokens_cont(Ics1, L1, C2, yyaction(A1, Alen1, Tcs, Tline,Tcol), Ts);
        %% After a non-accepting state, maybe reach accept state later.
        {A1,Alen1,Tlen1,[],L1,C1,S1} ->            % Need more chars to check
            {more,{tokens,S1,L1,C1,Tcs,Tlen1,Tline,Tcol,Ts,A1,Alen1}};
        {reject,_Alen1,Tlen1,eof,L1,C1,_S1} ->     % No token match
            %% Check for partial token which is error, no need to skip here.
            Ret = if Tlen1 > 0 -> {error,{{Tline,Tcol},?MODULE,
                                          %% Skip eof tail in Tcs.
                                          {illegal,yypre(Tcs, Tlen1)}},{L1,C1}};
                     Ts == [] -> {eof,{L1,C1}};
                     true -> {ok,yyrev(Ts),{L1,C1}}
                  end,
            {done,Ret,eof};
        {reject,_Alen1,Tlen1,_Ics1,L1,C1,_S1} ->
            %% Skip rest of tokens.
            Error = {{L1,C1},?MODULE,{illegal,yypre(Tcs, Tlen1+1)}},
            skip_tokens(yysuf(Tcs, Tlen1+1), L1, C1, Error);
        {A1,Alen1,Tlen1,_Ics1,L1,_C1,_S1} ->
            Token = yyaction(A1, Alen1, Tcs, Tline,Tcol),
            Tcs1 = yysuf(Tcs, Alen1),
            L2 = adjust_line(Tlen1, Alen1, Tcs1, L1),
            C2 = C0 + Alen1,
            tokens_cont(Tcs1, L2, C2, Token, Ts)
    end.

%% tokens_cont(RestChars, Line, Column, Token, Tokens)
%% If we have an end_token or error then return done, else if we have
%% a token then save it and continue, else if we have a skip_token
%% just continue.

-dialyzer({nowarn_function, tokens_cont/5}).

tokens_cont(Rest, Line, Col, {token,T}, Ts) ->
    tokens(yystate(), Rest, Line, Col, Rest, 0, Line, Col, [T|Ts], reject, 0);
tokens_cont(Rest, Line, Col, {token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    tokens(yystate(), NewRest, Line, Col, NewRest, 0, Line, Col, [T|Ts], reject, 0);
tokens_cont(Rest, Line, Col, {end_token,T}, Ts) ->
    {done,{ok,yyrev(Ts, [T]),{Line,Col}},Rest};
tokens_cont(Rest, Line, Col, {end_token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    {done,{ok,yyrev(Ts, [T]),{Line, Col}},NewRest};
tokens_cont(Rest, Line, Col, skip_token, Ts) ->
    tokens(yystate(), Rest, Line, Col, Rest, 0, Line, Col, Ts, reject, 0);
tokens_cont(Rest, Line, Col, {skip_token,Push}, Ts) ->
    NewRest = Push ++ Rest,
    tokens(yystate(), NewRest, Line, Col, NewRest, 0, Line, Col, Ts, reject, 0);
tokens_cont(Rest, Line, Col, {error,S}, _Ts) ->
    skip_tokens(Rest, Line, Col, {{Line,Col},?MODULE,{user,S}}).

%% skip_tokens(InChars, Line, Col, Error) -> {done,{error,Error,{Line,Col}},Ics}.
%% Skip tokens until an end token, junk everything and return the error.

skip_tokens(Ics, Line, Col, Error) ->
    skip_tokens(yystate(), Ics, Line, Col, Ics, 0, Line, Col, Error, reject, 0).

%% skip_tokens(State, InChars, Line, Col, TokenChars, TokenLen, TokenLine, TokenCol, Tokens,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.

skip_tokens(S0, Ics0, L0, C0, Tcs, Tlen0, Tline, Tcol, Error, A0, Alen0) ->
    case yystate(S0, Ics0, L0, C0, Tlen0, A0, Alen0) of
        {A1,Alen1,Ics1,L1, C1} ->                  % Accepting end state
            skip_cont(Ics1, L1, C1, yyaction(A1, Alen1, Tcs, Tline, Tcol), Error);
        {A1,Alen1,[],L1,C1, S1} ->                 % After an accepting state
            {more,{skip_tokens,S1,L1,C1,Tcs,Alen1,Tline,Tcol,Error,A1,Alen1}};
        {A1,Alen1,Ics1,L1,C1,_S1} ->
            skip_cont(Ics1, L1, C1, yyaction(A1, Alen1, Tcs, Tline, Tcol), Error);
        {A1,Alen1,Tlen1,[],L1,C1,S1} ->           % After a non-accepting state
            {more,{skip_tokens,S1,L1,C1,Tcs,Tlen1,Tline,Tcol,Error,A1,Alen1}};
        {reject,_Alen1,_Tlen1,eof,L1,C1,_S1} ->
            {done,{error,Error,{L1,C1}},eof};
        {reject,_Alen1,Tlen1,_Ics1,L1,C1,_S1} ->
            skip_tokens(yysuf(Tcs, Tlen1+1), L1, C1,Error);
        {A1,Alen1,Tlen1,_Ics1,L1,C1,_S1} ->
            Token = yyaction(A1, Alen1, Tcs, Tline, Tcol),
            Tcs1 = yysuf(Tcs, Alen1),
            L2 = adjust_line(Tlen1, Alen1, Tcs1, L1),
            skip_cont(Tcs1, L2, C1, Token, Error)
    end.

%% skip_cont(RestChars, Line, Col, Token, Error)
%% Skip tokens until we have an end_token or error then return done
%% with the original rror.

-dialyzer({nowarn_function, skip_cont/5}).

skip_cont(Rest, Line, Col, {token,_T}, Error) ->
    skip_tokens(yystate(), Rest, Line, Col, Rest, 0, Line, Col, Error, reject, 0);
skip_cont(Rest, Line, Col, {token,_T,Push}, Error) ->
    NewRest = Push ++ Rest,
    skip_tokens(yystate(), NewRest, Line, Col, NewRest, 0, Line, Col, Error, reject, 0);
skip_cont(Rest, Line, Col, {end_token,_T}, Error) ->
    {done,{error,Error,{Line,Col}},Rest};
skip_cont(Rest, Line, Col, {end_token,_T,Push}, Error) ->
    NewRest = Push ++ Rest,
    {done,{error,Error,{Line,Col}},NewRest};
skip_cont(Rest, Line, Col, skip_token, Error) ->
    skip_tokens(yystate(), Rest, Line, Col, Rest, 0, Line, Col, Error, reject, 0);
skip_cont(Rest, Line, Col, {skip_token,Push}, Error) ->
    NewRest = Push ++ Rest,
    skip_tokens(yystate(), NewRest, Line, Col, NewRest, 0, Line, Col, Error, reject, 0);
skip_cont(Rest, Line, Col, {error,_S}, Error) ->
    skip_tokens(yystate(), Rest, Line, Col, Rest, 0, Line, Col, Error, reject, 0).

-compile({nowarn_unused_function, [yyrev/1, yyrev/2, yypre/2, yysuf/2]}).

yyrev(List) -> lists:reverse(List).
yyrev(List, Tail) -> lists:reverse(List, Tail).
yypre(List, N) -> lists:sublist(List, N).
yysuf(List, N) -> lists:nthtail(N, List).

%% adjust_line(TokenLength, AcceptLength, Chars, Line) -> NewLine
%% Make sure that newlines in Chars are not counted twice.
%% Line has been updated with respect to newlines in the prefix of
%% Chars consisting of (TokenLength - AcceptLength) characters.

-compile({nowarn_unused_function, adjust_line/4}).

adjust_line(N, N, _Cs, L) -> L;
adjust_line(T, A, [$\n|Cs], L) ->
    adjust_line(T-1, A, Cs, L-1);
adjust_line(T, A, [_|Cs], L) ->
    adjust_line(T-1, A, Cs, L).

%% adjust_col(Chars, AcceptLength, Col) -> NewCol
%% Handle newlines, tabs and unicode chars.
adjust_col(_, 0, Col) ->
    Col;
adjust_col([$\n | R], L, _) ->
    adjust_col(R, L-1, 1);
adjust_col([$\t | R], L, Col) ->
    adjust_col(R, L-1, tab_forward(Col)+1);
adjust_col([C | R], L, Col) when C>=0 andalso C=< 16#7F ->
    adjust_col(R, L-1, Col+1);
adjust_col([C | R], L, Col) when C>= 16#80 andalso C=< 16#7FF ->
    adjust_col(R, L-1, Col+2);
adjust_col([C | R], L, Col) when C>= 16#800 andalso C=< 16#FFFF ->
    adjust_col(R, L-1, Col+3);
adjust_col([C | R], L, Col) when C>= 16#10000 andalso C=< 16#10FFFF ->
    adjust_col(R, L-1, Col+4).

tab_forward(C) ->
    D = C rem tab_size(),
    A = tab_size()-D,
    C+A.

tab_size() -> 8.

%% yystate() -> InitialState.
%% yystate(State, InChars, Line, Col, CurrTokLen, AcceptAction, AcceptLen) ->
%% {Action, AcceptLen, RestChars, Line, Col} |
%% {Action, AcceptLen, RestChars, Line, Col, State} |
%% {reject, AcceptLen, CurrTokLen, RestChars, Line, Col, State} |
%% {Action, AcceptLen, CurrTokLen, RestChars, Line, Col, State}.
%% Generated state transition functions. The non-accepting end state
%% return signal either an unrecognised character or end of current
%% input.

-file("src/css_lexer.erl", 357).
yystate() -> 18.

yystate(19, Ics, Line, Col, Tlen, _, _) ->
    {4,Tlen,Ics,Line,Col};
yystate(18, [125|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(16, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(18, [64|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(14, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(18, [46|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(11, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(18, [45|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(1, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(18, [38|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(11, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(18, [32|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(19, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(18, [13|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(19, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(18, [9|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(19, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(18, [10|Ics], Line, _, Tlen, Action, Alen) ->
    yystate(19, Ics, Line+1, 1, Tlen+1, Action, Alen);
yystate(18, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(1, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(18, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,18};
yystate(17, [123|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(17, [32|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(17, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 37, C =< 95 ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(17, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(17, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,17};
yystate(16, Ics, Line, Col, Tlen, _, _) ->
    {3,Tlen,Ics,Line,Col};
yystate(15, Ics, Line, Col, Tlen, _, _) ->
    {2,Tlen,Ics,Line,Col};
yystate(14, [97|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(12, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(14, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,14};
yystate(13, [123|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(13, [46|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(13, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(13, [38|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(13, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(13, [37|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(13, [32|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(13, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 39, C =< 45 ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(13, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 47, C =< 95 ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(13, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(13, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,13};
yystate(12, [112|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(10, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(12, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,12};
yystate(11, [46|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(13, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(11, [38|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(13, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(11, [37|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(11, [32|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(11, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 39, C =< 45 ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(11, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 47, C =< 95 ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(11, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(17, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(11, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,11};
yystate(10, [112|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(8, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(10, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,10};
yystate(9, [58|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(3, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(9, [32|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(9, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(9, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,9};
yystate(8, [108|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(6, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(8, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,8};
yystate(7, Ics, Line, Col, Tlen, _, _) ->
    {0,Tlen,Ics,Line,Col};
yystate(6, [121|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(4, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(6, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,6};
yystate(5, [95|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(5, [64|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(5, [59|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(7, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(5, [37|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(5, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 32, C =< 35 ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(5, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 39, C =< 41 ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(5, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 44, C =< 58 ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(5, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 60, C =< 62 ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(5, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(5, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,5};
yystate(4, [93|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(4, [91|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(4, [44|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(4, [45|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(4, [34|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(4, [35|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(4, [32|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(4, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 39, C =< 41 ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(4, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(4, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(4, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,4};
yystate(3, [95|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(3, [64|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(3, [37|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(3, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 32, C =< 35 ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(3, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 39, C =< 41 ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(3, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 44, C =< 58 ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(3, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 60, C =< 62 ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(3, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(5, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(3, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,3};
yystate(2, [93|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(2, [91|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(2, [59|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(0, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(2, [44|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(2, [45|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(2, [34|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(2, [35|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(2, [32|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(2, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 39, C =< 41 ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(2, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(2, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(2, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(2, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,2};
yystate(1, [58|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(3, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(1, [45|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(1, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(1, [32|Ics], Line, Col, Tlen, Action, Alen) ->
    yystate(9, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(1, [C|Ics], Line, Col, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(1, Ics, Line, Col, Tlen+1, Action, Alen);
yystate(1, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,1};
yystate(0, Ics, Line, Col, Tlen, _, _) ->
    {1,Tlen,Ics,Line,Col};
yystate(S, Ics, Line, Col, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,Col,S}.

%% yyaction(Action, TokenLength, TokenChars, TokenLine, TokenCol) ->
%% {token,Token} | {end_token, Token} | skip_token | {error,String}.
%% Generated action function.

yyaction(0, TokenLen, YYtcs, TokenLine, _) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_0(TokenChars, TokenLine);
yyaction(1, TokenLen, YYtcs, TokenLine, _) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_1(TokenChars, TokenLine);
yyaction(2, TokenLen, YYtcs, TokenLine, _) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_2(TokenChars, TokenLine);
yyaction(3, _, _, TokenLine, _) ->
    yyaction_3(TokenLine);
yyaction(4, _, _, _, _) ->
    yyaction_4();
yyaction(_, _, _, _, _) -> error.

-compile({inline,yyaction_0/2}).
-file("src/css_lexer.xrl", 9).
yyaction_0(TokenChars, TokenLine) ->
     { token, { property, TokenLine, extract_property (TokenChars) } } .

-compile({inline,yyaction_1/2}).
-file("src/css_lexer.xrl", 10).
yyaction_1(TokenChars, TokenLine) ->
     { token, { apply, TokenLine, extract_apply (TokenChars) } } .

-compile({inline,yyaction_2/2}).
-file("src/css_lexer.xrl", 11).
yyaction_2(TokenChars, TokenLine) ->
     { token, { start_scope, TokenLine, extract_begin_selector (TokenChars) } } .

-compile({inline,yyaction_3/1}).
-file("src/css_lexer.xrl", 12).
yyaction_3(TokenLine) ->
     { token, { end_scope, TokenLine } } .

-compile({inline,yyaction_4/0}).
-file("src/css_lexer.xrl", 13).
yyaction_4() ->
     skip_token .
-file("/Users/fceruti/.local/share/rtx/installs/erlang/26.0.2/lib/parsetools-2.5/include/leexinc.hrl", 344).
