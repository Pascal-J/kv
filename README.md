# kv
dictionary for J.  inverted table implemetation auto upgrades from native to boxed data including nested dictionaries.

intended for coinsert 'kv' into any other locale.  (should be) safe for coinsert_z_ 'kv' (base needs extra coinsert 'z' call)
unique key implied access even when non-unique keys permitted.
create(bulk), add, del, update/set all have versions to allow/avoid duplicates.  1 suffix permits duplicates
optimized for bulk operations, where arguments to functions are either a list of keys, or a kv dictionary.
kv dictionary always y argument.  modifications return copies.
A DSL is provided to permit one line string descriptions of the simplest dictionaries.
Non-unique key implementation can still provide unique key expected behaviour.  add appending a duplicate value creates an undo operation when del deletes the last value.
	kvadd1 instead of kvadd
Multiple internal keys also permit using kv with meaningful order and /.(key) "applications" and classifiers.
tosym replacement for s: cut instead of leading delimiter.  tosym on symbols returns the symbols instead of error.
values kept native numeric or string (padded) if possible.  Otherwise boxed.
values can hold other kv structures, and so may wish to hold 3 independent dictionaries for each data type: numeric, string, boxed.
kv (get) function returns values only for keys found, returns i.0 if no keys found.
adding or updating unboxed values will promote to boxed if internal values are boxed.

deep operations are supported, where typical kv right arguments (set add) will when provided with nested k1;(kv) :
	will modify kv deeply with (k0 kvbulk (keys;vals) set kvdata will set at k0 level.
	get/del can access/del at infinte depth.
  
  
  kvtest code:
  
  pD_z_ =: (1!:2&2) : (] [ (1!:2&2)@:(,&<))  
 myattr =: tosym 'sorted unique foreignkey foreignval' 

pD d=: ('nums' kvbulk < 'field2 field3' kvbulk > 1 ; 0 1 0 0)   kvadd  ' descF' kvf 'descF field2' kvbulk 2 $ < myattr kvbulk  _1 0 0 0

'set on empty dict.  using gerund dsL call' pD 'dicts1 dicts2' kvbulk ,. (< kvEMPTY) kvset~ each ';'&cut`cut kvdsL each ('asdf`v' ; '2nd dict key with embedded spaces ` v2')

'transform numeric array with a symbol list into a dictionary ']&pD myattr kvbulk 'nums ` field2' kvd d

'dictionary to values' pD ,@kvvals myattr kvbulk 'nums ` field2' kvd d

 d =: ('strs' kvbulk < cut kvdsL 'str1 str2 str3`g asdf xcvb')  kvset d
 
 ((< 'str1 `ggg ' cut kvsetL 'strs' kv d) kvbulk~ 'strs') kvset d

'multidict' ]&pD d kvset~ kvbulk&.>(<@)/(>@)(>@)  ( <'strs'),(tosym' str1 fds'),&< 'gg',:'fds'

'simple dsL add of deep misc`fields`values' ]&pD d =: 'misc ` str1 fds ` gg fds ' cut kvsetL d

'deep get strs ` str1 str2' pD 'strs ` str1 str2' kvd  d

'use `misc vals to deep set strs'  ]&pD (kvsetd~ 'strs' (kvbulk <) 'misc'&kv )  d

'subkey access str1 str2 for all if all dicts with kv"1' pD  ,/ 'str1 str2' kv"1 (G0 kv ]) d

'subkey access str2 str1  with <@kv"1 and clean for empties' pD  a: -.~ standardnull each 'str2 str1' <@(kv"1) (G0 kv ]) d

'subkey filter str2 str1  with <@kvf"1 returns list of dictionaries)' pD  ('str2 str1' kvf"1 G0 kv ]) d

'subkey filter str2 str1  with <@kvf"1 adding back keys' pD  (,@G0 kvbulk 'str2 str1' kvf"1 G0 kv ]) d

pD 'empty dictionary is 2$a:, but a filtered empty dictionary retains its original value shape'

pD 'if numbers mixed with strings, values are upgraded to boxes'

'add 2 numeric keys to all (last filtered) dictionaries with dsl ". kvsetL"1' pD 'a b ` 3 4' ". kvsetL"1 ( 'str2 str1' kvf"1 G0 kv ]) d

'make a mistake adding duplicate key' pD d =: ('misc' kvbulk1 123) kvadd1 d

'undo mistake... restore dict by deleting last key' pD d=: 'misc' kvdel d

'deep delete dic`misc`fds from `dic (masterdict over) d' pD  'dic` misc `fds fd 'kvdeld 'dic' kvbulk < d


  output from kvtest run: (in edit mode looks ok)
  
┌──────┬───────────────────┐
│`descF│┌─────────────────┐│
│`nums ││┌───────────┬──┐ ││
│      │││`sorted    │_1│ ││
│      │││`unique    │ 0│ ││
│      │││`foreignkey│ 0│ ││
│      │││`foreignval│ 0│ ││
│      ││└───────────┴──┘ ││
│      │├─────────────────┤│
│      ││┌───────┬───────┐││
│      │││`field2│1 0 0 0│││
│      │││`field3│0 1 0 0│││
│      ││└───────┴───────┘││
│      │└─────────────────┘│
└──────┴───────────────────┘
┌─────────────────────────────────────────┬───────────────────────────────────────────────────┐
│set on empty dict.  using gerund dsL call│┌───────┬─────────────────────────────────────────┐│
│                                         ││`dicts1│┌───────────────────────────────────────┐││
│                                         ││`dicts2││┌─────┬─┐                              │││
│                                         ││       │││`asdf│v│                              │││
│                                         ││       ││└─────┴─┘                              │││
│                                         ││       │├───────────────────────────────────────┤││
│                                         ││       ││┌──────────────────────────────────┬──┐│││
│                                         ││       │││`2nd dict key with embedded spaces│v2││││
│                                         ││       ││└──────────────────────────────────┴──┘│││
│                                         ││       │└───────────────────────────────────────┘││
│                                         │└───────┴─────────────────────────────────────────┘│
└─────────────────────────────────────────┴───────────────────────────────────────────────────┘
┌───────────┬─┐
│`sorted    │1│
│`unique    │0│
│`foreignkey│0│
│`foreignval│0│
└───────────┴─┘
transform numeric array with a symbol list into a dictionary 
┌────────────────────┬───────┐
│dictionary to values│1 0 0 0│
└────────────────────┴───────┘
┌──────┬───────────────────┐
│`descF│┌─────────────────┐│
│`nums ││┌───────────┬──┐ ││
│`strs │││`sorted    │_1│ ││
│      │││`unique    │ 0│ ││
│      │││`foreignkey│ 0│ ││
│      │││`foreignval│ 0│ ││
│      ││└───────────┴──┘ ││
│      │├─────────────────┤│
│      ││┌───────┬───────┐││
│      │││`field2│1 0 0 0│││
│      │││`field3│0 1 0 0│││
│      ││└───────┴───────┘││
│      │├─────────────────┤│
│      ││┌─────┬───┐      ││
│      │││`str1│gg │      ││
│      │││`fds │fds│      ││
│      ││└─────┴───┘      ││
│      │└─────────────────┘│
└──────┴───────────────────┘
multidict
┌──────┬───────────────────┐
│`descF│┌─────────────────┐│
│`nums ││┌───────────┬──┐ ││
│`strs │││`sorted    │_1│ ││
│`misc │││`unique    │ 0│ ││
│      │││`foreignkey│ 0│ ││
│      │││`foreignval│ 0│ ││
│      ││└───────────┴──┘ ││
│      │├─────────────────┤│
│      ││┌───────┬───────┐││
│      │││`field2│1 0 0 0│││
│      │││`field3│0 1 0 0│││
│      ││└───────┴───────┘││
│      │├─────────────────┤│
│      ││┌─────┬────┐     ││
│      │││`str1│g   │     ││
│      │││`str2│asdf│     ││
│      │││`str3│xcvb│     ││
│      ││└─────┴────┘     ││
│      │├─────────────────┤│
│      ││┌─────┬───┐      ││
│      │││`str1│gg │      ││
│      │││`fds │fds│      ││
│      ││└─────┴───┘      ││
│      │└─────────────────┘│
└──────┴───────────────────┘
simple dsL add of deep misc`fields`values
┌─────────────────────────┬────┐
│deep get strs ` str1 str2│g   │
│                         │asdf│
└─────────────────────────┴────┘
┌──────┬───────────────────┐
│`descF│┌─────────────────┐│
│`nums ││┌───────────┬──┐ ││
│`strs │││`sorted    │_1│ ││
│`misc │││`unique    │ 0│ ││
│      │││`foreignkey│ 0│ ││
│      │││`foreignval│ 0│ ││
│      ││└───────────┴──┘ ││
│      │├─────────────────┤│
│      ││┌───────┬───────┐││
│      │││`field2│1 0 0 0│││
│      │││`field3│0 1 0 0│││
│      ││└───────┴───────┘││
│      │├─────────────────┤│
│      ││┌─────┬────┐     ││
│      │││`str1│gg  │     ││
│      │││`str2│asdf│     ││
│      │││`str3│xcvb│     ││
│      │││`fds │fds │     ││
│      ││└─────┴────┘     ││
│      │├─────────────────┤│
│      ││┌─────┬───┐      ││
│      │││`str1│gg │      ││
│      │││`fds │fds│      ││
│      ││└─────┴───┘      ││
│      │└─────────────────┘│
└──────┴───────────────────┘
use `misc vals to deep set strs
┌──────────────────────────────────────────────────────┬────┐
│subkey access str1 str2 for all if all dicts with kv"1│    │
│                                                      │    │
│                                                      │    │
│                                                      │    │
│                                                      │g   │
│                                                      │asdf│
│                                                      │gg  │
│                                                      │    │
└──────────────────────────────────────────────────────┴────┘
┌──────────────────────────────────────────────────────────┬──────────┐
│subkey access str2 str1  with <@kv"1 and clean for empties│┌────┬───┐│
│                                                          ││asdf│gg ││
│                                                          ││g   │   ││
│                                                          │└────┴───┘│
└──────────────────────────────────────────────────────────┴──────────┘
┌───────────────────────────────────────────────────────────────────┬────────────┐
│subkey filter str2 str1  with <@kvf"1 returns list of dictionaries)│┌─────┬────┐│
│                                                                   │├─────┼────┤│
│                                                                   │├─────┼────┤│
│                                                                   ││`str2│asdf││
│                                                                   ││`str1│g   ││
│                                                                   │├─────┼────┤│
│                                                                   ││`str1│gg  ││
│                                                                   │└─────┴────┘│
└───────────────────────────────────────────────────────────────────┴────────────┘
┌──────────────────────────────────────────────────────┬─────────────────────┐
│subkey filter str2 str1  with <@kvf"1 adding back keys│┌──────┬────────────┐│
│                                                      ││`descF│┌─────┬────┐││
│                                                      ││`nums │├─────┼────┤││
│                                                      ││`strs │├─────┼────┤││
│                                                      ││`misc ││`str2│asdf│││
│                                                      ││      ││`str1│g   │││
│                                                      ││      │├─────┼────┤││
│                                                      ││      ││`str1│gg  │││
│                                                      ││      │└─────┴────┘││
│                                                      │└──────┴────────────┘│
└──────────────────────────────────────────────────────┴─────────────────────┘
empty dictionary is 2$a:, but a filtered empty dictionary retains its original value shape
if numbers mixed with strings, values are upgraded to boxes
┌───────────────────────────────────────────────────────────────────────────┬───────────────┐
│add 2 numeric keys to all (last filtered) dictionaries with dsl ". kvsetL"1│┌─────┬───────┐│
│                                                                           ││`a   │3      ││
│                                                                           ││`b   │4      ││
│                                                                           │├─────┼───────┤│
│                                                                           ││`a   │3 0 0 0││
│                                                                           ││`b   │4 0 0 0││
│                                                                           │├─────┼───────┤│
│                                                                           ││`str2│┌────┐ ││
│                                                                           ││`str1││asdf│ ││
│                                                                           ││`a   │├────┤ ││
│                                                                           ││`b   ││g   │ ││
│                                                                           ││     │├────┤ ││
│                                                                           ││     ││3   │ ││
│                                                                           ││     │├────┤ ││
│                                                                           ││     ││4   │ ││
│                                                                           ││     │└────┘ ││
│                                                                           │├─────┼───────┤│
│                                                                           ││`str1│┌───┐  ││
│                                                                           ││`a   ││gg │  ││
│                                                                           ││`b   │├───┤  ││
│                                                                           ││     ││3  │  ││
│                                                                           ││     │├───┤  ││
│                                                                           ││     ││4  │  ││
│                                                                           ││     │└───┘  ││
│                                                                           │└─────┴───────┘│
└───────────────────────────────────────────────────────────────────────────┴───────────────┘
┌───────────────────────────────────┬────────────────────────────┐
│make a mistake adding duplicate key│┌──────┬───────────────────┐│
│                                   ││`descF│┌─────────────────┐││
│                                   ││`nums ││┌───────────┬──┐ │││
│                                   ││`strs │││`sorted    │_1│ │││
│                                   ││`misc │││`unique    │ 0│ │││
│                                   ││`misc │││`foreignkey│ 0│ │││
│                                   ││      │││`foreignval│ 0│ │││
│                                   ││      ││└───────────┴──┘ │││
│                                   ││      │├─────────────────┤││
│                                   ││      ││┌───────┬───────┐│││
│                                   ││      │││`field2│1 0 0 0││││
│                                   ││      │││`field3│0 1 0 0││││
│                                   ││      ││└───────┴───────┘│││
│                                   ││      │├─────────────────┤││
│                                   ││      ││┌─────┬────┐     │││
│                                   ││      │││`str1│g   │     │││
│                                   ││      │││`str2│asdf│     │││
│                                   ││      │││`str3│xcvb│     │││
│                                   ││      ││└─────┴────┘     │││
│                                   ││      │├─────────────────┤││
│                                   ││      ││┌─────┬───┐      │││
│                                   ││      │││`str1│gg │      │││
│                                   ││      │││`fds │fds│      │││
│                                   ││      ││└─────┴───┘      │││
│                                   ││      │├─────────────────┤││
│                                   ││      ││123              │││
│                                   ││      │└─────────────────┘││
│                                   │└──────┴───────────────────┘│
└───────────────────────────────────┴────────────────────────────┘
┌─────────────────────────────────────────────────┬────────────────────────────┐
│undo mistake... restore dict by deleting last key│┌──────┬───────────────────┐│
│                                                 ││`descF│┌─────────────────┐││
│                                                 ││`nums ││┌───────────┬──┐ │││
│                                                 ││`strs │││`sorted    │_1│ │││
│                                                 ││`misc │││`unique    │ 0│ │││
│                                                 ││      │││`foreignkey│ 0│ │││
│                                                 ││      │││`foreignval│ 0│ │││
│                                                 ││      ││└───────────┴──┘ │││
│                                                 ││      │├─────────────────┤││
│                                                 ││      ││┌───────┬───────┐│││
│                                                 ││      │││`field2│1 0 0 0││││
│                                                 ││      │││`field3│0 1 0 0││││
│                                                 ││      ││└───────┴───────┘│││
│                                                 ││      │├─────────────────┤││
│                                                 ││      ││┌─────┬────┐     │││
│                                                 ││      │││`str1│g   │     │││
│                                                 ││      │││`str2│asdf│     │││
│                                                 ││      │││`str3│xcvb│     │││
│                                                 ││      ││└─────┴────┘     │││
│                                                 ││      │├─────────────────┤││
│                                                 ││      ││┌─────┬───┐      │││
│                                                 ││      │││`str1│gg │      │││
│                                                 ││      │││`fds │fds│      │││
│                                                 ││      ││└─────┴───┘      │││
│                                                 ││      │└─────────────────┘││
│                                                 │└──────┴───────────────────┘│
└─────────────────────────────────────────────────┴────────────────────────────┘
┌──────────────────────────────────────────────────────┬─────────────────────────────────────┐
│deep delete dic`misc`fds from `dic (masterdict over) d│┌────┬──────────────────────────────┐│
│                                                      ││`dic│┌────────────────────────────┐││
│                                                      ││    ││┌──────┬───────────────────┐│││
│                                                      ││    │││`descF│┌─────────────────┐││││
│                                                      ││    │││`nums ││┌───────────┬──┐ │││││
│                                                      ││    │││`strs │││`sorted    │_1│ │││││
│                                                      ││    │││`misc │││`unique    │ 0│ │││││
│                                                      ││    │││      │││`foreignkey│ 0│ │││││
│                                                      ││    │││      │││`foreignval│ 0│ │││││
│                                                      ││    │││      ││└───────────┴──┘ │││││
│                                                      ││    │││      │├─────────────────┤││││
│                                                      ││    │││      ││┌───────┬───────┐│││││
│                                                      ││    │││      │││`field2│1 0 0 0││││││
│                                                      ││    │││      │││`field3│0 1 0 0││││││
│                                                      ││    │││      ││└───────┴───────┘│││││
│                                                      ││    │││      │├─────────────────┤││││
│                                                      ││    │││      ││┌─────┬────┐     │││││
│                                                      ││    │││      │││`str1│g   │     │││││
│                                                      ││    │││      │││`str2│asdf│     │││││
│                                                      ││    │││      │││`str3│xcvb│     │││││
│                                                      ││    │││      ││└─────┴────┘     │││││
│                                                      ││    │││      │├─────────────────┤││││
│                                                      ││    │││      ││┌─────┬───┐      │││││
│                                                      ││    │││      │││`str1│gg │      │││││
│                                                      ││    │││      ││└─────┴───┘      │││││
│                                                      ││    │││      │└─────────────────┘││││
│                                                      ││    ││└──────┴───────────────────┘│││
│                                                      ││    │└────────────────────────────┘││
│                                                      │└────┴──────────────────────────────┘│
└──────────────────────────────────────────────────────┴─────────────────────────────────────┘

Benchmark for 1m keys/values create/optimize/search

 bench_kvtest_~ 1000000 
┌──────────────────────────────────────────┬──────────────────┐
│create ?.x$y keys/vals ignoring duplicates│0.467815 1.87771e8│
└──────────────────────────────────────────┴──────────────────┘
┌─────────────────────┬───────────────────┐
│uniquify on last step│0.0233238 2.51676e7│
└─────────────────────┴───────────────────┘
┌───────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│30 keys│35128 462151 33398 101000 455991 444063 693381 733962 192982 194438 451320 226701 822320 565878 625418 316363 110354 725930 680443 84347 355455 102665 788146 838954 990780 944237 892594 949868 446740 673026│
└───────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────┬───────────────────┐
│uniquify and optimize│0.0274095 2.51766e7│
└─────────────────────┴───────────────────┘
┌─────────────────────────────┬───────────┐
│random 30key optimized access│4.9e_6 5888│
└─────────────────────────────┴───────────┘
┌─────────────────────────────┬───────────────────┐
│same 30key unoptimized access│0.0027556 4.19658e6│
└─────────────────────────────┴───────────────────┘
