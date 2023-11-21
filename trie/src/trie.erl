-module(trie).

%% API exports
-export([lookup/2, add/2, build_branch/1]).

lookup(Invalid, _Trie) when is_atom(Invalid) -> fail;
lookup([], Trie) ->
  case maps:is_key(nil, Trie) of
    true -> found;
    false -> fail
  end;
lookup([First|Rest], Trie) ->
  True = maps:is_key(First, Trie),
  if 
    True =:= true ->
      Sub_trie = maps:get(First, Trie),
      lookup(Rest, Sub_trie);
    true -> 
      fail
    end.

add(Invalid, _Trie) when is_atom(Invalid) -> fail;
add([], Trie)->
    maps:put(nil, nil, Trie);
add([H|T], Trie) ->
  case maps:is_key(H, Trie) of
    true ->
      Sub_trie = maps:get(H, Trie),
      maps:put(H, add(T, Sub_trie), Trie);
    false ->
      maps:put(H, build_branch(T), Trie)
  end.

build_branch([]) ->
    #{nil => nil};
build_branch([H | T]) ->
    #{H => build_branch(T)}.


%%% Only include the eunit testing library and functions
%%% in the compiled code if testing is 
%%% being done.
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
 

 
lookup_test_()->
  Trie1 = #{},
  Trie2 = #{'D' => #{'a' => #{'n' => #{'i' => #{nil => nil, 'e' => #{'l' => #{'l' => #{'e' => #{nil => nil}}}}}}}}},
  Trie3 = #{
    'D' => #{'a' => #{
      'n' => #{'i' => #{nil => nil, 'e' => #{'l' => #{'l' => #{'e' => #{nil => nil}}}}}},
      'v' => #{'i' => #{'d' => #{nil => nil}}}
      }
    }
  },
	[?_assertEqual(found, lookup(['D', 'a', 'n', 'i', 'e', 'l', 'l', 'e'], Trie2)),%happy path
	 ?_assertEqual(fail, lookup(['S', 'a', 'l', 'l', 'y'], Trie3)),%happy path
	 ?_assertEqual(fail, lookup([], Trie2)),%happy path
	 ?_assertEqual(found, lookup(['D', 'a', 'v', 'i', 'd'], Trie3)),%happy path      
   ?_assertEqual(fail, lookup(['D', 'a', 'v', 'i', 'd'], Trie1)),
   %nasty thoughts start here
   ?_assertEqual(fail, lookup(not_valid, Trie1))
	].

add_test_()->
  Trie0 = #{},
  Trie1 = #{'D' => #{'a' => #{'n' => #{'i' => #{nil => nil}}}}},
  Trie2 = maps:put('S', #{'a' => #{'l' => #{'l' => #{'y' => #{nil => nil}}}}}, Trie1),
	[?_assertEqual(
    #{'D' => #{'a' => #{'n' => #{'i' => #{'e' => #{'l' => #{'l' => #{'e' => #{nil => nil}}}}}}}}},
    add(['D', 'a', 'n', 'i', 'e', 'l', 'l', 'e'], Trie0)
   ),
   ?_assertEqual(
    #{'D' => #{'a' => #{'n' => #{'i' => #{nil => nil, 'e' => #{'l' => #{'l' => #{'e' => #{nil => nil}}}}}}}}},
    add(['D', 'a', 'n', 'i', 'e', 'l', 'l', 'e'], Trie1)),%happy path
	 ?_assertEqual(
    #{'D' => #{'a' => #{'n' => #{'i' => #{nil => nil, 'e' => #{'l' => #{'l' => #{'e' => #{nil => nil}}}}}}}},
      'S' => #{'a' => #{'l' => #{'l' => #{'y' => #{nil => nil}}}}}},
    add(['D', 'a', 'n', 'i', 'e', 'l', 'l', 'e'], Trie2)
  ),%happy path
	 %nasty thoughts start here
   ?_assertEqual(fail, add(not_valid, Trie1))
    
	].


-endif.