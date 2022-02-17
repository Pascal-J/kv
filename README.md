# kv
dictionary for J.  inverted table implemetation auto upgrades from native to boxed data including nested dictionaries.

Definition of dictionary:
```j
A datastructure such that when provided with a list of keys a get function will retrieve 
  the latest value associated with that key as a result of latest set/add/del operations that could have modified that associated value. 
If a requested retrival key has no associated value, then nothing is returned, 
  where in a list of requested keys, nothing combined with other requested values is the list of the other values.

If a user only uses set/del modifiers after loading or optimizing to a unique dictionary, then the dictionary will remain in unique state.
  a user may use special add1 function to place kv in non-unique state.  get and filter will still operate as if unique.
  in non unique mode, filtall and delall will affect multiple values.  set/del/get operate on last key occurrence + related value.

keys are stored as a table of symbols.  Values as a table of numeric, string, or boxed values.  Table width for simplest keys and values is 1.
This allows multikey keys or metainfo after first key.  Allows inverted table or associated array datastructures.
Boxed values permit embedded keyed dictionaries.
	keyed data/value access is similar to J locale access to data/functions.  
	An embedded dictionary is an association of data variables that replaces use for a locale/datastructure.
A dictionary or dictionary hierarchy is a single J entity that can be serialized/deserialized with 3!:1 , 3!:2
```

Basic operations:
```j
(key0;key1...) kv val1;val2... creates dictionary.  keys can also be a space separated string, or symbols. # of keys and values must match
	a dictionary is 2 boxes. left is keys as symbols, right is values.  Both are table shaped.


(key0;key1...) kvget dictionary...  retrieves any values associated with key0 and/or key1 and/or other keys in list.  Unboxes values if possible.
	kvdel has same calling signature.  will delete any keys+associated values matching x argument.
	kvfilt will return a dictionary instead of just values.
	kvfiltall will return duplicate keys instead of just last one. kvdelall deletes all duplicate keys instead of last.
dictionary kvset dictionary... uses x dictionary key/values to update/add y dictionary.  Merging matching keys with new values from x.
	kvadd has same signature.
```

Features:
```j
intended for coinsert 'kv' into any other locale.  (should be) safe for coinsert_z_ 'kv' (base needs extra coinsert 'z' call)
unique key implied access even when non-unique keys permitted.
create(bulk), add, del, update/set all have versions to allow/avoid duplicates.  1 suffix permits duplicates
optimized for bulk operations, where arguments to functions are either a list of keys, or a kv dictionary.
kv dictionary always y argument to kvfunctions.  modifications return copies.'
	x right argument to set/add is another dictionary (key,value pairs)
	x right argument to get/del is a boxed list of symbol keys or keys as strings.
A DSL is provided to permit one line string descriptions of required x argument dictionaries or deep set/get/del variations.
Non-unique key implementation can still provide unique key expected behaviour.  add appending a duplicate key-value creates an undo operation when del deletes the last value.
	use kvadd1 instead of kvadd
Multiple internal keys also permit using kv with meaningful order (kvinsert permits ordered manipulation) and /.(key) "applications" and classifiers.
tosym replacement for s: cut instead of leading delimiter.  tosym on symbols returns the symbols instead of error.  Use of ;: in dsl version allows J words as keys/symbols.
values kept native numeric or string (padded) if possible.  Otherwise boxed.
values can hold other kv structures, and so may wish to hold 3 independent dictionaries for each data type: numeric, string, boxed.
kv (get) function returns values only for keys found, returns i.0 if no keys found.
adding or updating unboxed values will promote to boxed if internal values are boxed.

deep operations are supported, where typical kv right arguments (set add) will when provided with nested k1;(kv) :
	will modify kv deeply with (k0 kv (keys;vals) set kvdata will set at k0 level.
	get/del can access/del at infinte depth by appending (single key) path
```
Limitations:
```j
values lists are stored as tables.  If you attempt to store a higher shape than a table, 
	it is presumed to be a mistake.
linearize is a crutch to combine with "tableize" (monad ,.) to "fix" situations that might create/provide greater than table shapes prior to inclusion as a table.
	kv does not use ,.@linearize combo in order to prevent non table keys/values.
set,set1,update,update1 present needlessly many options for extremely limited behaviour operation.  
	Behaviour that has a good argument for systemically preventing.
	Behaviour deviances that I know how to fix easily.
	update1 will add a key instead of updating when trying to add a boxed or numeric value to a string value table (+vice versa)
	update and update1 will operate as set with autoboxing if adding a string or numeric value to a boxed value table.
```

Architecture considerations:
```j
Non-unique mode (add1 instead of set) can provide 4x update throughput.  
  Using optimize every 1 to 5 seconds can serve a slightly out of date dataset to a wide audience with 100x access throughput on top of 4x update throughput.
keyed boxed arrays in a single dictionary provides keyed inverted table structure, or associated data as alternative to classes.
Using J native data offers a size and access performance benefit, and is encouraged.
Arrays/tables as key values makes J suitable for key-value oriented programs.
	JSON implementation with kv should outperform current J implementations.
```
  
## kvtest code

```j
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


  output from kvtest run: (in raw/edit mode looks ok)
  
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
set on empty dict.  using gerund dsL call: vvv
┌───────┬─────────────────────────────────────────┐
│`dicts1│┌───────────────────────────────────────┐│
│`dicts2││┌─────┬─┐                              ││
│       │││`asdf│v│                              ││
│       ││└─────┴─┘                              ││
│       │├───────────────────────────────────────┤│
│       ││┌──────────────────────────────────┬──┐││
│       │││`2nd dict key with embedded spaces│v2│││
│       ││└──────────────────────────────────┴──┘││
│       │└───────────────────────────────────────┘│
└───────┴─────────────────────────────────────────┘
transform numeric array with a symbol list into a dictionary: vvv
┌───────────┬─┐
│`sorted    │1│
│`unique    │0│
│`foreignkey│0│
│`foreignval│0│
└───────────┴─┘
dictionary to values: vvv
1 0 0 0
multidict: vvv
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
simple dsL add of deep misc`fields`values: vvv
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
deep get strs ` str1 str2: vvv
g   
asdf
use `misc vals to deep set strs: vvv
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
subkey access str1 str2 for all if all dicts with kvget"1: vvv
    
    
    
    
g   
asdf
gg  
    
subkey access str2 str1  with <@kvget"1 and clean for empties: vvv
┌────┬───┐
│asdf│gg │
│g   │   │
└────┴───┘
subkey filter str2 str1  with <@kvfilt"1 returns list of dictionaries): vvv
┌─────┬────┐
├─────┼────┤
├─────┼────┤
│`str2│asdf│
│`str1│g   │
├─────┼────┤
│`str1│gg  │
└─────┴────┘
subkey filter str2 str1  with <@kvfilt"1 adding back keys: vvv
┌──────┬────────────┐
│`descF│┌─────┬────┐│
│`nums │├─────┼────┤│
│`strs │├─────┼────┤│
│`misc ││`str2│asdf││
│      ││`str1│g   ││
│      │├─────┼────┤│
│      ││`str1│gg  ││
│      │└─────┴────┘│
└──────┴────────────┘
empty dictionary is "2$ <,.i.0", but a filtered empty dictionary retains its original value shape
if numbers mixed with strings, values are upgraded to boxes
add 2 numeric keys to all (last filtered) dictionaries with dsl ". kvsetL"1: vvv
┌─────┬───────┐
│`a   │3      │
│`b   │4      │
├─────┼───────┤
│`a   │3 0 0 0│
│`b   │4 0 0 0│
├─────┼───────┤
│`str2│┌────┐ │
│`str1││asdf│ │
│`a   │├────┤ │
│`b   ││g   │ │
│     │├────┤ │
│     ││3   │ │
│     │├────┤ │
│     ││4   │ │
│     │└────┘ │
├─────┼───────┤
│`str1│┌───┐  │
│`a   ││gg │  │
│`b   │├───┤  │
│     ││3  │  │
│     │├───┤  │
│     ││4  │  │
│     │└───┘  │
└─────┴───────┘
make a mistake adding duplicate key: vvv
┌──────┬───────────────────┐
│`descF│┌─────────────────┐│
│`nums ││┌───────────┬──┐ ││
│`strs │││`sorted    │_1│ ││
│`misc │││`unique    │ 0│ ││
│`misc │││`foreignkey│ 0│ ││
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
│      │├─────────────────┤│
│      ││123              ││
│      │└─────────────────┘│
└──────┴───────────────────┘
undo mistake... restore dict by deleting last key: vvv
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
deep delete dic`misc`fds from `dic (masterdict over) d: vvv
┌────┬──────────────────────────────┐
│`dic│┌────────────────────────────┐│
│    ││┌──────┬───────────────────┐││
│    │││`descF│┌─────────────────┐│││
│    │││`nums ││┌───────────┬──┐ ││││
│    │││`strs │││`sorted    │_1│ ││││
│    │││`misc │││`unique    │ 0│ ││││
│    │││      │││`foreignkey│ 0│ ││││
│    │││      │││`foreignval│ 0│ ││││
│    │││      ││└───────────┴──┘ ││││
│    │││      │├─────────────────┤│││
│    │││      ││┌───────┬───────┐││││
│    │││      │││`field2│1 0 0 0│││││
│    │││      │││`field3│0 1 0 0│││││
│    │││      ││└───────┴───────┘││││
│    │││      │├─────────────────┤│││
│    │││      ││┌─────┬────┐     ││││
│    │││      │││`str1│g   │     ││││
│    │││      │││`str2│asdf│     ││││
│    │││      │││`str3│xcvb│     ││││
│    │││      ││└─────┴────┘     ││││
│    │││      │├─────────────────┤│││
│    │││      ││┌─────┬───┐      ││││
│    │││      │││`str1│gg │      ││││
│    │││      ││└─────┴───┘      ││││
│    │││      │└─────────────────┘│││
│    ││└──────┴───────────────────┘││
│    │└────────────────────────────┘│
└────┴──────────────────────────────┘
create inverted table: vvv
┌───────┬────────────┐
│`Id    │┌──────────┐│
│`Name  ││3         ││
│`Job   ││6         ││
│`Status││5         ││
│       ││1         ││
│       │├──────────┤│
│       ││Jerry     ││
│       ││Jan       ││
│       ││Frieda    ││
│       ││Alex      ││
│       │├──────────┤│
│       ││Unemployed││
│       ││CEO       ││
│       ││student   ││
│       ││Waiter    ││
│       │├──────────┤│
│       ││Married   ││
│       ││Married   ││
│       ││Single    ││
│       ││Separated ││
│       │└──────────┘│
└───────┴────────────┘
┌───────────────────┬─┐
│dsL version matches│1│
└───────────────────┴─┘
itdisplay(selected fields) query on Job -:(padded) 'CEO' or 'student' : vvv
┌───┬──────┬──────────┐
│`Id│`Name │`Job      │
├───┼──────┼──────────┤
│6  │Jan   │CEO       │
│5  │Frieda│student   │
└───┴──────┴──────────┘
dsL (; separated "keys") version of same query as kv: vvv
┌───────┬────────────┐
│`Id    │┌──────────┐│
│`Name  ││6         ││
│`Job   ││5         ││
│`Status│├──────────┤│
│       ││Jan       ││
│       ││Frieda    ││
│       │├──────────┤│
│       ││CEO       ││
│       ││student   ││
│       │├──────────┤│
│       ││Married   ││
│       ││Single    ││
│       │└──────────┘│
└───────┴────────────┘
add inverted table to "main" dic: vvv
┌──────┬────────────────────────┐
│`descF│┌──────────────────────┐│
│`nums ││┌───────────┬──┐      ││
│`strs │││`sorted    │_1│      ││
│`misc │││`unique    │ 0│      ││
│`it   │││`foreignkey│ 0│      ││
│      │││`foreignval│ 0│      ││
│      ││└───────────┴──┘      ││
│      │├──────────────────────┤│
│      ││┌───────┬───────┐     ││
│      │││`field2│1 0 0 0│     ││
│      │││`field3│0 1 0 0│     ││
│      ││└───────┴───────┘     ││
│      │├──────────────────────┤│
│      ││┌─────┬────┐          ││
│      │││`str1│g   │          ││
│      │││`str2│asdf│          ││
│      │││`str3│xcvb│          ││
│      ││└─────┴────┘          ││
│      │├──────────────────────┤│
│      ││┌─────┬───┐           ││
│      │││`str1│gg │           ││
│      │││`fds │fds│           ││
│      ││└─────┴───┘           ││
│      │├──────────────────────┤│
│      ││┌───────┬────────────┐││
│      │││`Id    │┌──────────┐│││
│      │││`Name  ││3         ││││
│      │││`Job   ││6         ││││
│      │││`Status││5         ││││
│      │││       ││1         ││││
│      │││       │├──────────┤│││
│      │││       ││Jerry     ││││
│      │││       ││Jan       ││││
│      │││       ││Frieda    ││││
│      │││       ││Alex      ││││
│      │││       │├──────────┤│││
│      │││       ││Unemployed││││
│      │││       ││CEO       ││││
│      │││       ││student   ││││
│      │││       ││Waiter    ││││
│      │││       │├──────────┤│││
│      │││       ││Married   ││││
│      │││       ││Married   ││││
│      │││       ││Single    ││││
│      │││       ││Separated ││││
│      │││       │└──────────┘│││
│      ││└───────┴────────────┘││
│      │└──────────────────────┘│
└──────┴────────────────────────┘


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
┌─────────────────────────────────────────────────────────────────────────────────────┬──────────────────┐
│create 100000 key/vals (uniquified) in range of 2*y so half are new half are existing│0.114918 5.36975e7│
└─────────────────────────────────────────────────────────────────────────────────────┴──────────────────┘
┌──────────────────────────────────────────────────────────────────────────────────────┬───────────────────┐
│set (update or add depending on existing status of key) 100000 keys/vals into first kv│0.0214939 5.11204e7│
└──────────────────────────────────────────────────────────────────────────────────────┴───────────────────┘
```
