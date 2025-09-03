ccoclass 'kv'
assertC =: 2 : '] [ v (13!:8^:((0 e. ])`(12"_))) u'
lr_z_ =: 3 : '5!:5 < ''y'''
NB. utilities to clean/modify/process data
mdef =: 2 : 'n&u : u'  NB. monad default parameter n to dyad u
dtb =:  ] #~  +./\.@:~: mdef ' '  NB. used to clean fills, if data gets dirty before turning into boxed. works with numeric fills fill atom is dyad param.
cut =: ([: -.&a: <;._2@,~) mdef ' '
numerify =: 0&".^:(2 = 3!:0)@]
linearize =: (, $~ 1 -.~ $)@]  NB. remove all 1 dimensions.
tableize =:  ,/^:(2 < #@$)@,: NB. set shape count to 2, but opposed to ,., remove leading dimensions
maybenum =: 0&".^:(] -:&linearize ":@:numerify)@dltb NB. for mixed string/num boxed values will convert strings that can be into numbers.
standardnull =: (''"_)^:(0 e. $) NB. any 0s in shape equivalent to i.0
Mifnull =: 1 : ' u`(u@])@.('''' -: [)' NB. monad application if x is null.  y null will still apply to null


kvkeys =: G0 =: 0 {:: ]
kvvals =: G1 =: 1 {:: ]
G2 =: 2 {:: ]
ss =: {{ ' '&cut m }}
bb =: 1 : 'dltb each (''`''&cut) m'

Note 'kv/dictionary definition'
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

)

Note 'basic operation'
(key0;key1...) kv val1;val2... creates dictionary.  keys can also be a space separated string, or symbols. # of keys and values must match
	a dictionary is 2 boxes. left is keys as symbols, right is values.  Both are table shaped.


(key0;key1...) kvget dictionary...  retrieves any values associated with key0 and/or key1 and/or other keys in list.  Unboxes values if possible.
	kvdel has same calling signature.  will delete any keys+associated values matching x argument.
	kvfilt will return a dictionary instead of just values.
	kvfiltall will return duplicate keys instead of just last one. kvdelall deletes all duplicate keys instead of last.
dictionary kvset dictionary... uses x dictionary key/values to update/add y dictionary.  Merging matching keys with new values from x.
	kvadd has same signature.

deep set of dictionaries supported with embedded dictionary in x argument.  d suffix to functions operate in deep mode.
DSL versions of above versions allow a single x string to represent dictionary x arguments.  including deep operations.
	The DSL variation of functions are adverbs named with L suffix.  Adverb parameter is either one function to parse value portion of string, or gerund that parses keyportion`valueportion
)

Note 'kv features'
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
)

Note 'limitations'
values lists are stored as tables.  If you attempt to store a higher shape than a table, 
	it is presumed to be a mistake.
linearize is a crutch to combine with "tableize" (monad ,.) to "fix" situations that might create/provide greater than table shapes prior to inclusion as a table.
	kv does not use ,.@linearize combo in order to prevent non table keys/values.
set,set1,update,update1 present needlessly many options for extremely limited behaviour operation.  
	Behaviour that has a good argument for systemically preventing.
	Behaviour deviances that I know how to fix easily.
	update1 will add a key instead of updating when trying to add a boxed or numeric value to a string value table (+vice versa)
	update and update1 will operate as set with autoboxing if adding a string or numeric value to a boxed value table.
)

Note 'Architecture'
Non-unique mode (add1 instead of set) can provide 4x update throughput.  
  Using optimize every 1 to 5 seconds can serve a slightly out of date dataset to a wide audience with 100x access throughput on top of 4x update throughput.
keyed boxed arrays in a single dictionary provides keyed inverted table structure, or associated data as alternative to classes.
Using J native data offers a size and access performance benefit, and is encouraged.
Arrays/tables as key values makes J suitable for key-value oriented programs.
	JSON implementation with kv should outperform current J implementations.
)

kvEMPTY =: 2$ <,.i.0 NB. for reference. use kvbulk instead of set on empty
tosym =: ( s: :: ])@:(cut :: ]) (@]) NB. string transformed to boxes cut on space.  Boxes transformed to symbols. symbols unchanged.
NB. filters dict for unique keys keeping the last value associated to a key (last add/set wins)
kvuniquify =: (] {~L:_1  (] i: ~.)@:G0) ^: ( (#@~. < #)@:G0) NB. optimize for presumed unique.
NB. returns a kv from list keys and values. keys transformed into symbols and shaped as num,1.  If values a list, also shaped num,1 so that future adds will create fills if they are longer than atoms.
kv1 =: (,.^:(1 = #@$)@] ,&<~ ] =&# assertC 'keys and values must have same item count' (] $~ 1 ,~ #)@:tosym@[ )
kv =:   kv1 (kvuniquify@:)  NB. choice of functions, permits unique or non-unique implmentations.

NB.   ' '&cut(&.>)`(".(&.>))"0 ' as ` 3' bb NB. cuts first on ` ' '&cut for first, ". for 2nd box

NB. DSL to simplify passing keys ` values as a one line string.  
NB. keys and values are separated by a `
NB. default key processing is cut on space.  Use gerund param to override it. keyprocessfunction`u instead of u
NB. u will apply to values string to generate value items. Examples:
NB.		". will turn numeric.  supports expressions such as 10 3 $ i.30 to make 10 items.
NB.		';'&cut will make string items. (keeps leading/trailing spaces)
NB.		maybenum@:(';'&cut) will cut on ; and then turn any items that can be into numbers.
NB. Any boxed values created by DSL, will attempt to be unboxed into items if no error.  So if all strings, will automatically be turned into padded items.
kvdsL =: (;:`) 1 : 0 ((kv&.>(<@)/(>@)(>@)(f.))@:) 
'`k val' =. _2 {. m
NB.(k @:G0 ,&< (> :: ])@:val@:G1)@:(dltb each@:('`'&cut)) f. 
(k @:G0 ,&< (> :: ])@:val@:G1) ((@(_2&{.)) ,~ tosym L:0(^:(0 <#))@:(_2 &}.) )@:(dltb each@:('`'&cut)) f. 
)
NB. verb arguments to kvdsL to create inverted tables. keys=field names. keys ` tabledata still separated by `
NB. itdsl has values for each key separated by ;  and within each string field by : or space (assumes more than 1 value ie. if only 1 string value with : at end will fail (and use space separator))
NB. use with kvdsL kvsetL kvaddL
itdsl =:  cut &>^:(1 = #)@(':'&cut)^:(2 = 3!:0)(>@:)@(,.^:(2 ~: 3!:0))@maybenum each@(';'&cut)( {.^:(2< #@$)each@:)
NB. allows "upgrade" of value structure when new items are incompatible with existing ones.
append =: , :: (, <"_1) :: ((<"_1)@[ , ]) :: ([ , <"_1@]) :: (<"_1@[ , <"_1@]) (,.@:)
NB. append items from kv x into kv y.  1verb ommits uniquify step.
kvadd1 =: append~ L:_1(^:(0 <#@G0@[))  NB. guard against empty x dictionary.
kvadd =: kvuniquify@:kvadd1  NB. adds and updates uniquify
kvaddL =: kvdsL@[ kvadd ]  NB. adverb (AVV) that uses DSL to process x string. see kvdsL for u param.
kvadd1L =: kvdsL@[ kvadd1 ]  NB. adverb (AVV) that uses DSL to process x string. see kvdsL for u param.
NB. manipulate the key/value order by inserting x: (ks kv vs),< atindexpoint (3 boxes).  Does not uniquify. if keys exist later than insert point, those values are still "official" (get result)
kvinsert =: (}:@[ kvadd1 ]) ([ kvi~ (i.@(G1 + G2) ([ {~ (-@G1 }. [ }.~  G0),~ (G2 (+ i.) G1),~ G0 {. [ ) ])) G2~ ([ , ((<: G1) *. 0 < [) assertC 'indexat must be between 0 and count of kvitems') ,&#&G0
NB.ex: 	   ' gg fr` 133 15' ". kvaddL ' as fr' kvbulk 33 5
NB. very useful for function call decomposition where some parameters may be missing from dict, but default values are needed.
	NB.  'a b c d' =. 'certainA maybeB certainC maybeD' kvgetb '('maybeB maybeD' kv bdefaultval , defaultval) kvaddm y NB. y is dict
NB. or         'a b c d' =. G1 'certainA maybeB certainC maybeD' kvfilt '('maybeB maybeD' kv bdefaultval , defaultval) kvaddm y NB. y is dict
NB. or improved with nulls as defaults:  'a b c d' =. 'a b c d' kvgetf y
kvaddm =: (] kvadd1~ [ kvfilt~ ([ #~ -.@:e.)&G0) NB.add only if key is missing.  x is dict of new keys new vals. y is dict to update

NB. if kv keys are static, saving indexes may speed access. x is list of numeric indices, kv y is filtered by index list x
NB. kv keys and values are static for purposes of functions that access keys or values in order to 
kvi =: { L:_1 NB. filter by index  G0@kvi retrieves keys, if x is computed from values (G1), then this is a keysfromvalues function.
kvdi =: ] kvi~ [ -.~ i.@#@G0  NB. del by index
NB.x are keys boxed or ' '&cut formatted string. kv y has items removed that match keys x.
kvdel =:  ] kvdi~ G0 i: ,.@tosym@[  NB. if kv is dirty (not unique), del will undo last duplicate add
NB. deep del matches kvd x format below: last key in list operates at deepest point in path.  result rolled up into path described by previous keys.
kvdeld =: ] ([ kvsetd~ (linearize each)@}:@]  kv&.>(<@)/(>@)(>@)@:(, <@<) >@{:@] kvdel [ kvgetd~ }:@]) (,.@tosym@dltb each @:('`'&cut)(linearize@) :: (,.@tosym each@](linearize@) )@[)

NB. gets values by keys in x from kv y.  if any x not found, then omit from result. if no x found return i.0
kvget =: (G1 {~ G0 (#@[ -.~ i:) ,.@tosym@[)(linearize@)((> :: ])@)NB. if values are all atomic, then returns atom or list of atoms. BUGf: if items are all unpadded chars then will concatenate them.
kvgetb =: (G1 {~ G0 (#@[ -.~ i:) ,.@tosym@[)(linearize@)  NB. do not attempt unboxing.
kvgetf =: ([ kvgetb ] kvaddm~  a: (] ,&< [ ,.@:#~ #@]) ,.@tosym@[) NB. missing keys still return filled with values (i.0)  no attempt to unbox.
NB. when attempting multikey get, ensure that any possible missing keys are at end of list, or use kvfilt instead.  'key1 missing key2 missing2' as x will return 2 keys without indication of which values correspond to found keys.
NB. filters kv y by keys in x
kvfilt =: (] {~ L:_1 G0 (#@[ -.~ i:) ,.@tosym@[)
kvfne =: (kvfilt~ G0 ~.@:(#~,) a: ~: G1)  NB. filter out non empty values.  except if empty value is a duplicate entry.
NB. =========================================================
padstrmatch =: -@#@:(';'&cut :: ])@[ (}. e. {.) (] , >@:(';'&cut :: ])@[) NB. when strings padded, this function allows matching with (unpadded x) with padded version (in y).
NB. padstrmatch =: -@#@[ (}. e. {.) (] , >@[) NB. when strings padded, this function allows matching with (unpadded x) with padded version (in y).
kvQ =: ((I.@) kvi"1 G1) kv~ linearize@:G0  NB. AVV for boolean function u (visible to full dict), filter dic where u is true.
NB. deep get (kvd) will tunnel into sub dicts. x is list of boxes or string cut first on ` then on space inside each box. left to right boxes specify top down keys
kvgetd =: (<@] ] F.. (kvget &.>) (,.@tosym@dltb each @:('`'&cut)(linearize@) :: (,.@tosym each@](linearize@)) )@[)((> :: ])@)  NB. strange value error bug calling localed from base related to F.. ?
kvgetd =: (<@]  kvget &.>/@:(,~ |.) (,.@tosym@dltb each @:('`'&cut)(linearize@) :: (,.@tosym each@](linearize@)) )@[)((> :: ])@)
itdisp1 =: <"_1@G0@:tosym ,: boxopen"_1@kvget NB. displays kv as inverted table (for fields x). for all fields use: (G0 itdisp ])
itdisp1 =: ((<"_1)@G0 ,: linearize@:(boxopen"_1)@:G1)@:kvfilt NB. displays kv as inverted table (for fields x). for all fields use: (G0 itdisp ])
itdisp =: G0 itdisp1 ]
NB. kvf uses lastkey value to filter.  Allowing all keys filter allows expansion of use beyond dictionary. 
NB. duplicate keys allow undo, and having firstkeyindict contain value for field1 as a compound value structure, 2ndkeyindict holds field2 value...
NB. THe /. (key) dyad function is a powerful J paradigm permitted by kvfall multiple key copy structure.
kvfiltall =: ] #~ L:_1 tosym~ ,@:(+./^:(1 < #))@:(="0 _) G0
NB. delete all instead of last keys x from kv y.  When non unique internals are relied upon.
kvdelall=: ] #~ L:_1 tosym~ ,@:-.@:(+./^:(1 < #))@:(="0 _) G0

NB. optimized to keep unique(ish) status, set will update in place those keys that are found, and add1 keys not found.
NB. merging kv x into kv y.  will not check for nulls in kv x
NB. IMPLEMENTED: extra err check to use boxed x values before kvadd resorted to. kvadd would trigger if attempting incompatible update on CURRENTLY unboxed kv y values.
NB. TOCONSIDER: kvadd or kvadd1 should never be backstop to update.  Match full append backstops
kvupdate2 =: (G0 ,&< <"_1@:G1~`(i:~&G0)`(G1)}) NB. internal error handling.  try again with boxed x items.
kvupdate =: (G0 ,&< G1~`(i:~&G0)`(G1)}) :: kvupdate2 :: kvadd NB. requires keys present.  Error assumes rare incompatible type.
kvupdate1 =: (G0 ,&< G1~`(i:~&G0)`(G1)}) :: kvupdate2 :: kvadd1 NB. will keep "ununique structure" on error. kvadd will uniquify.

kvset =:  (([ kvdel~ -.&G0) kvupdate^:(0 <  #@G0~)  ([ kvfilt~ -.&G0) kvadd1^:(0 <  #@G0~) ] ) 
kvset1 =:  ([ kvdel~ -.&G0) kvupdate1^:(0 <  #@G0~)  ([ kvfilt~ -.&G0) kvadd1^:(0 <  #@G0~) ] NB. ensures ununique properties if they exist (due to error handling in update which includes uniquify if updating to incompatible type that requires box promotion)
kvsetL =: kvdsL@[ kvset ]  NB. AVV adverb uses DSL to create x kv from string.
NB. set at depth1 key1 kvbulk keys;values will set keys and values at depth of key1. 
NB.	if x is hierarchy of key1 kvbulk key2 kvbulk keys;values then key2 will have its value replaced by keys;values... instead of set(update/add) operation at depth.
NB.TODO: 	Having set work at unlimited depth will require extra leading boxes in x similar to kvd
kvsetd =: (] kvset~ linearize@G0~ (kv <) ,@:>@G1~ kvset G0~ kvget ])
NB. ADV optimize kv function once kv m is static.  resulting function is monadic kvget for keys to retrieve.  Returned function embeds full kv inside it. Not sure if special code for (m i: ]) so not using.
kvO =: 1 : 'm =. kvuniquify m label_. (((G1 m) {~  (# G0 m) -.~ (G0  m)&i:)@:,.@tosym (linearize@)) f.'  
NB. count = 2, boxed, box0 contains symbols shaped as table.
iskv =: (( (2 = #@$) *. 65536 = 3!:0)@G0 *. (1 <: L.)*. 2 = #)(@]) :: 0  NB. just checking keys shaped as table.
NB. conjunction for single key n.  dyad Verb u applied as kvy set~ key kv [ u (key get kvy)  
NB. updates key n based on dyad u
forkey =: 2 : '] kvset~ n kv [ u n kvget ]'
NB. can be chained for unlimited deep set, but often requires a boxing step after u verb because:
	NB. kvget will unbox when possible.  kvset returns a full dictionary, but to be deep set, requires being an item (so boxing) to have a key association
NB. ('str1' kv ,:'ff') <@kvset forkey'misc'd_kvtest_
NB. (,: 'ff')  [ forkey 'str1'(<@) forkey'misc'  d_kvtest_
NB. 'ff'    ,(,:@) forkey'str1'(<@)forkey'misc'd_kvtest_ NB. (,:@) itemizes result string. one item per key
NB. (' '&cut kvdsL  'str1 fds ` ff fds2') <@[ forkey 'd1'(<@) forkey'misc'  d_kvtest_
NB. (' '&cut kvdsL 'str1 fds` ff fds2')  kvset(<@) forkey'misc'  d_kvtest_


NB. variant that only updates if key does not return null. n(ull guarded)
forkeyn =: 2 : '(] kvset~ n kv [ u n kvget ])^:(0 < n #@kvget ])'

NB. call test code.  y ignored.
kvtest =: 3 : 0
MYDIR =: getpath_j_  '\/' rplc~ > (4!:4<'thisfile'){(4!:3)  thisfile=:'' NB. boilerplate to set the working directory
load MYDIR, 'kvtest.ijs'
)


coclass 'ra'
coinsert 'kv'
Note 'Ragged Array'
A ragged array is equivalent to a list of boxed homogeneous strings or numbers, but also allows nulls.
It is an alternative to J's usual square arrays that avoids both fills and boxes.

Implementation is through a kv that includes
`data:  a flat homogeneous array.
`lengths: an array holding the length of each item in item order.  0 is code for null.
`indexes: optional start indexes of items into flat array.  Same length as `lengths.  Performance boost for access.  Penalty for updates.
`keys: optional keyed access to items.  list of symbols equal in length to `lengths and `indexes
`cutpoints: optional boolean list similar to indexes.  Use to feed to (cutpoints u;.1 data), where u is  < or a search function
	cutpoints exclude nulls.
`disallownulls: used to remove nulls and filter out future nulls in lengths/data.
`includesnulls: some functions may have to remove nulls that exist, or warn user against use.

implementation optimization is to erase indexes on set/insert, create if empty on get, and extend on add.

Reasons to use:
padding could be difficult to undo
searching from end of "words"/strings interfered by padding.
whole word/str search that prefilters by length.
search on flat array.  Might make words Proper cased, or include terminator between strings to keep search within string boundaries.
keyed/indexed access focus.

if flat array is to be converted to list of boxed values before searching, it would be lower performance than holding boxed values.
Though C implementation/special code for unboxing, might make general "virtual boxed" search ok. 
)

Note 'Motivations/Decisions'
Motivation to make a kv based structure, adding some complications to ra to support nulls and keyed access.
kv provides an object replacement framework

Design mistake #1: including null support.  Should be a separate compatible class.
	get access is fine with nulls, but "cutpoints" access/processing doesn't.  So a null check/removal step is wasteful.





)

amend =: [` ([. ` ar) `{`] `: 6 ` (]."_) `] }~~
NB. For functions/advs that a monadic verb (\ ;.), Adverb that will convert a dyadic call into x&u : monad that the further modifier right expects.
NB. if a natural monad u is passed (instead of being called dyadically) then that u is returned.
dasM_z_ =:  ([. : (2 : 'x&u y')) a:
NB. x is optional keys (tosym format). y boxed values .
NB.ra =:   (''"_`('keys:' kv <@,@G0)@.iskv  kvadd1^:(0 < #@[) (('data:';'lengths:') kv ,@:(#&>) ,&<~ ;)) :: ((0: assertC 'values must be homogeneous')@]`G1@.iskv)
ramonad =: (('data:';'lengths:') kv ,@:(#&>) ,&<~ ;) :: (0: assertC 'values must be homogeneous')(@]) 
NB. ra =:   ramonad : (tosym@[ (('keys:' (kv <) [) kvadd1 ])   ramonad@])
ra =:   ramonad : (tosym@[ (('keys:' (kv <) [) kvadd1  (#@[ = 'lengths:' #@kvget ]) assertC 'keys and values must have same item count')   ramonad@])


NB. y is kv that holds ra.
rabuildidx1 =: (] kvset~ 'indexes:' (kv <) 'lengths:' (0 , }:)@:(+/\)@:kvget ])
rabuildidx  =: rabuildidx1^:(0 = 'indexes:' #@kvget ])(@])
rabuildcuts =: (] kvset 'cutpoints:' (kv <) ] 1:`]`('data:' (0 #~ #)@kvget [)} 'indexes:' kvget ])@rabuildidx
rachecknulls =:] kvset~ 'includesnulls:' (kv <) 0 e. 'lengths:' kvget ]  NB. if lengths include 0, then there are nulls.
NB.rakillnulls1 =: ] kvset~ ('lengths:';'indexes:') kv&>/@:(] ,&<~ [ {.~ #@]) 0 <"1@:|:@:(|:@] #~ (~: {.)) 'lengths: indexes:' tableize@kvget ]
rakillnulls1 =: (0 ~: 'lengths:' kvget ]) ([ <@# forkeyn 'keys:' [ <@# forkeyn 'indexes:' <@# forkey 'lengths:') ]
rakillnulls2 =: (('includesnulls:' kv < 0) kvset rakillnulls1)^:(1 = 'includesnulls:' +/@kvget ])
rakillnulls =: rakillnulls2@:rachecknulls  NB.bypasses/ignores "cached" null presence.
radisallownulls =: ('disallownulls:' kv < 1) kvset rakillnulls2  NB. flag to prevent future nulls.

NB. appends ra x to ra y. keys from x only included if y has keys.
raadd1 =: ('keys:' kvget [ ) (([ (0 < #@]) assertC 'keys should exist in x' [) <@,~ ]) forkeyn 'keys:' ('lengths:' kvget [ ) <@,~ forkey 'lengths:' ('data:' kvget [ ) <@,~ forkey 'data:' ]
raadd =: [`(rakillnulls@[)@.(1 = 'disallownulls:' +/@kvget ]) raadd1 ]
raaddn =: [ raadd radisallownulls@]  NB. ensure no nulls

NB. li(length index) x is table with 2 items lenght(s) index(es).  will retrieve from flat array/str y those items in y (boxed).
li =: <@(+ i.)~/"1&.|:@[ {L:0 ]
li1 =: <@(+ i.)~/"1&.|:@[(;@:) { ] NB. returns flat slices (suitable for replacing data:) instead of boxed items
rali =: li 'data:' kvget ]
rali1 =: li1 'data:' kvget ]
NB. get lenghts/indexes by index(es) or key(s) x from ra y
ramakei =: ] (] (#@[ -.~ i:)~ 'keys:' kvget [)^:(65536 = 3!:0@]) tosym~ NB. tosym leaves numbers(indexes) unchanged. returns indexes from keys or indexes
ragetli =: rabuildidx@] (] {"1 'lengths: indexes:' kvget [) ramakei 
NB. get by index(es) or key(s) x from ra y. returns boxed list of items.
NB. raget1 =:  ] ([ rali~ ] {"1 'lengths: indexes:' kvget rabuildidx@[) ] (] (#@[ -.~ i:)~ 'keys:' kvget [)^:(65536 = 3!:0@]) tosym~
raget1 =: ragetli rali ]
raget2 =: ragetli rali1 ]  NB. flat array subset of data.
raget =: (] raget1~ 'lengths:' i.@#@kvget ]) : raget1 NB. monad gets all, can be used with prefilter of lenghts/indexes to get subset.

NB.rafiltu =: 1 : 'u (( I.@[ <@raget2_ra_ ]) [ <@# forkeyn_kv_ ''keys:''   <@# forkey_kv_ ''lengths:'') rabuildidx_ra_@]'
NB. rafiltu =: 1 : 'u ([ <@# forkeyn_kv_ ''keys:'' [ <@# forkeyn_kv_ ''indexes:''  <@# forkey_kv_ ''lengths:'' ) rabuildidx_ra_@]'

NB. implement filter as raget values and possible keys, then rebuild ra.  Because lenghts/indexes need rebuild for new data anyway.

rafiltu1 =: 1 : 'u ra_ra_&>/@:(I.@[ (raget_ra_ ,&<~  [ { ''keys:'' kvget_kv_ ]) ]) ]'
rafiltu2 =: rafiltu1_ra_  kvset~ 'disallownulls:' (kv_kv_ <) 'disallownulls:'kvget_kv_ ]  NB. AV(VVV)
rafiltu =: rafiltu1  NB.should be 2 instead of 1, if ra will be added to, and original dissalownull setting should rule. That is filter argument.  
	NB. but filter implementation is a new ra.  filt functions in ra and kv leave original intact.  Expecting new ra to be blank of "rules" leaves caller free to add the rules they want without relying on original.  
	NB. rafiltu2 exists and has been defined if user wants that functionality (keep disallownulls setting).  Accidentally inserting empty keys does not "fool" kv standard behaviour. (missing key = keyvalue of null as return values)
NB.  Filter by indexes/keys.  new ra built
rafilt =: (ramakei_ra_ 1:`[`]} 0 #~ 'lengths:' #@kvget ]) rafiltu
NB. filter by length(s) provided.  useful maybe as prefilter to match.
rafiltl =:  ([ e.~ 'lengths:' kvget ]) rafiltu
NB. filter by u on cutpoints (each item apply u to return boolean value for item 1 = include in filter)
rafiltc =:  1 : '( (''cutpoints:''  kvget_kv_ ]) u (+./@)(;. 1) ''data:'' kvget_kv_ ])' rafiltu  (@:rabuildcuts_ra_)(@rakillnulls_ra_)

