coclass 'kv'
assertC =: 2 : '] [ v (13!:8^:((0 e. ])`(12"_))) u'
lr_z_ =: 3 : '5!:5 < ''y'''
NB. utilities to clean/modify/process data
mdef =: 2 : 'n&u : u'  NB. monad default parameter n to dyad u
dtb =:  ] #~  +./\.@:~: mdef ' '  NB. used to clean fills, if data gets dirty before turning into boxed. works with numeric fills fill atom is dyad param.
cut =: ([: -.&a: <;._2@,~) mdef ' '
numerify =: 0&".^:(2 = 3!:0)
linearize =: (, $~ 1 -.~ $)
maybenum =: 0&".^:(] -:&linearize ":@:numerify) NB. for mixed string/num boxed values will convert strings that can be into numbers.
standardnull =: (''"_)^:(0 e. $)


kvkeys =: G0 =: 0 {:: ]
kvvals =: G1 =: 1 {:: ]

ss =: {{ ' '&cut m }}
bb =: 1 : 'dltb each (''`''&cut) m'

Note 'kv features'
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
)

kvEMPTY =: 2$ <,.i.0 NB. for reference. use kvbulk instead of set on empty
tosym =: ( s: :: ])@:(cut :: ]) (@]) NB. string transformed to boxes cut on space.  Boxes transformed to symbols. symbols unchanged.
NB. filters dict for unique keys keeping the last value associated to a key (last add/set wins)
kvuniquify =: (] {~L:_1  (] i: ~.)@:G0) ^: ( (#@~. < #)@:G0) NB. optimize for presumed unique.
NB. returns a kv from list keys and values. keys transformed into symbols and shaped as num,1.  If values a list, also shaped num,1 so that future adds will create fills if they are longer than atoms.
kvbulk1 =: (,.^:(1 = #@$)@] ,&<~ ] =&# assertC 'keys and values must have same item count' (] $~ 1 ,~ #)@:tosym@[ )
kvbulk =:   kvbulk1 (kvuniquify@:)  NB. choice of functions, permits unique or non-unique implmentations.

NB.   ' '&cut(&.>)`(".(&.>))"0 ' as ` 3' bb NB. cuts first on ` ' '&cut for first, ". for 2nd box

NB. DSL to simplify passing keys ` values as a one line string.  
NB. keys and values are separated by a `
NB. default key processing is cut on space.  Use gerund param to override it. keyprocessfunction`u instead of u
NB. u will apply to values string to generate value items. Examples:
NB.		". will turn numeric.  supports expressions such as 10 3 $ i.30 to make 10 items.
NB.		';'&cut will make string items. (keeps leading/trailing spaces)
NB.		maybenum@:(';'&cut) will cut on ; and then turn any items that can be into numbers.
NB. Any boxed values created by DSL, will attempt to be unboxed into items if no error.  So if all strings, will automatically be turned into padded items.
kvdsL =: (cut`) 1 : 0 ((kvbulk&.>(<@)/(>@)(>@)(f.))@:) 
'`k val' =. _2 {. m
NB.(k @:G0 ,&< (> :: ])@:val@:G1)@:(dltb each@:('`'&cut)) f. 
(k @:G0 ,&< (> :: ])@:val@:G1) ((@(_2&{.)) ,~ tosym L:0(^:(0 <#))@:(_2 &}.) )@:(dltb each@:('`'&cut)) f. 
)
NB. allows "upgrade" of value structure when new items are incompatible with existing ones.
append =: , :: (, <"_1) :: ((<"_1)@[ , ]) :: ([ , <"_1@]) :: (<"_1@[ , <"_1@]) (,.@:)
NB. append items from kv x into kv y.  1verb ommits uniquify step.
kvadd1 =: append~ L:_1
kvadd =: kvuniquify@:kvadd1  NB. adds and updates uniquify
kvaddL =: kvdsL@[ kvadd ]  NB. adverb (AVV) that uses DSL to process x string. see kvdsL for u param.
NB.ex: 	   ' gg fr` 133 15' ". kvaddL ' as fr' kvbulk 33 5


NB. if kv keys are static, saving indexes may speed access. x is list of numeric indices, kv y is filtered by index list x
NB. kv keys and values are static for purposes of functions that access keys or values in order to 
kvi =: { L:_1 NB. filter by index  G0@kvi retrieves keys, if x is computed from values (G1), then this is a keysfromvalues function.
kvdi =: ] kvi~ [ -.~ i.@#@G0  NB. del by index
NB.x are keys boxed or ' '&cut formatted string. kv y has items removed that match keys x.
kvdel =:  ] kvdi~ G0 i: ,.@tosym@[  NB. if kv is dirty (not unique), del will undo last duplicate add
kvdeld =: ] ([ kvsetd~ (linearize each)@}:@]  kvbulk&.>(<@)/(>@)(>@)@:(, <@<) >@{:@] kvdel [ kvd~ }:@]) (,.@tosym@dltb each @:('`'&cut)(linearize@) :: (,.@tosym each@](linearize@) )@[)
NB. deep del matches kvd x format below:
NB. gets values by keys in x from kv y.  if any x not found, then omit from result. if no x found return i.0
kv =: (G1 {~ G0 (#@[ -.~ i:) ,.@tosym@[)(linearize@)((> :: ])@)NB. if values are all atomic, then returns atom or list of atoms. BUGf: if items are all unpadded chars then will concatenate them.
NB. filters kv y by keys in x
kvf =: (] {~ L:_1 G0 (#@[ -.~ i:) ,.@tosym@[)
NB. deep get (kvd) will tunnel into sub dicts. x is list of boxes or string cut first on ` then on space inside each box. left to right boxes specify top down keys
kvd =: (<@] ] F.. (kv &.>) (,.@tosym@dltb each @:('`'&cut)(linearize@) :: (,.@tosym each@](linearize@)) )@[)((> :: ])@)  NB. strange value error bug calling localed from base related to F.. ?
kvd =: (<@]  kv &.>/@:(,~ |.) (,.@tosym@dltb each @:('`'&cut)(linearize@) :: (,.@tosym each@](linearize@)) )@[)((> :: ])@)

NB. kvf uses lastkey value to filter.  Allowing all keys filter allows expansion of use beyond dictionary. 
NB. duplicate keys allow undo, and having firstkeyindict contain value for field1 as a compound value structure, 2ndkeyindict holds field2 value...
NB. THe /. (key) dyad function is a powerful J paradigm permitted by kvfall multiple key copy structure.
kvfall =: ] #~ L:_1 tosym~ ,@:(+./^:(1 < #))@:(="0 _) G0
NB. delete all instead of last keys x from kv y.  When non unique internals are relied upon.
kvdelall=: ] #~ L:_1 tosym~ ,@:-.@:(+./^:(1 < #))@:(="0 _) G0

NB. optimized to keep unique(ish) status, set will update in place those keys that are found, and add1 keys not found.
NB. merging kv x into kv y.  will not check for nulls in kv x
NB. IMPLEMENTED: extra err check to use boxed x values before kvadd resorted to. kvadd would trigger if attempting incompatible update on CURRENTLY unboxed kv y values.
NB. TOCONSIDER: kvadd or kvadd1 should never be backstop to update.  Match full append backstops
kvupdate2 =: (G0 ,&< <"_1@:G1~`(i:~&G0)`(G1)}) NB. internal error handling.  try again with boxed x items.
kvupdate =: (G0 ,&< G1~`(i:~&G0)`(G1)}) :: kvupdate2 :: kvadd NB. requires keys present.  Error assumes rare incompatible type.
kvupdate1 =: (G0 ,&< G1~`(i:~&G0)`(G1)}) :: kvupdate2 :: kvadd1 NB. will keep "ununique structure" on error. kvadd will uniquify.

kvset =:  (([ kvdel~ -.&G0) kvupdate^:(0 <  #@G0~)  ([ kvf~ -.&G0) kvadd1^:(0 <  #@G0~) ] ) 
kvset1 =:  ([ kvdel~ -.&G0) kvupdate1^:(0 <  #@G0~)  ([ kvf~ -.&G0) kvadd1^:(0 <  #@G0~) ] NB. ensures ununique properties if they exist (due to error handling in update which includes uniquify if updating to incompatible type that requires box promotion)
kvsetL =: kvdsL@[ kvset ]  NB. AVV adverb uses DSL to create x kv from string.
NB. set at depth1 key1 kvbulk keys;values will set keys and values at depth of key1. 
NB.	if x is hierarchy of key1 kvbulk key2 kvbulk keys;values then key2 will have its value replaced by keys;values... instead of set(update/add) operation at depth.
NB.TODO: 	Having set work at unlimited depth will require extra leading boxes in x similar to kvd
kvsetd =: (] kvset~ linearize@G0~ (kvbulk <) ,@:>@G1~ kvset G0~ kv ])
NB. ADV optimize kv function once kv m is static.  resulting function is monadic for keys to retrieve.  Returned function embeds full kv inside it. Not sure if special code for (m i: ]) so not using.
kvO =: 1 : 'm =. kvuniquify m label_. (((G1 m) {~  (# G0 m) -.~ (G0  m)&i:)@:,.@tosym (linearize@)) f.'  


coclass 'kvtest'
coinsert 'kv'
pD_z_ =: (1!:2&2) : (] [ (1!:2&2)@:(,&<)) 
NB.pDr =: pD@:('    ' , ":)"1@:":

NB.AmbiD =: 1 : 'u [ ''    '' pDr@, u lrX'
myattr =: tosym 'sorted unique foreignkey foreignval'
pD d=: ('nums' kvbulk < 'field2 field3' kvbulk > 1 ; 0 1 0 0)   kvadd  ' descF' kvf 'descF field2' kvbulk 2 $ < myattr kvbulk  _1 0 0 0
'set on empty dict.  using gerund dsL call' pD 'dicts1 dicts2' kvbulk ,. (< kvEMPTY) kvset~ each ';'&cut`cut kvdsL each ('asdf`v' ; '2nd dict key with embedded spaces ` v2')
'transform numeric array with a symbol list into a dictionary ']&pD myattr kvbulk 'nums ` field2' kvd d
'dictionary to values' pD ,@kvvals myattr kvbulk 'nums ` field2' kvd d

 d =: ('strs' kvbulk < cut kvdsL 'str1 str2 str3`g asdf xcvb')  kvset d
NB. 'manual deep update of strs`str1`ggg
 ((< 'str1 `ggg ' cut kvsetL 'strs' kv d) kvbulk~ 'strs') kvset d
NB. ]&pD ((< 'str1 `ggg ' cut kvsetL 'strs' kv d) kvbulk~ 'strs')  d kvset~ 'strs' kvbulk 
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

NB. x keys in range of 0 to y. numeric symbols associated with same numeric value.
bench =: 4 : 0 
'create ?.x$y keys/vals ignoring duplicates' pD timespacex 'a =. (kvbulk1~ ":) ? x$y'
'uniquify on last step' pD timespacex 'kvuniquify a'
'30 keys' pD k =. ": ? 30 $ y
'uniquify and optimize' pD timespacex 'aO =. a kvO'
'random 30key optimized access' pD timespacex 'aO k'
'same 30key unoptimized access' pD timespacex 'k kv a'
'matches' pD k (aO@[ -: kv)a
aO k
)
pD 'bench_kvtest_~ 100000 for optimizations and timimgs. 1000000 bench_kvtest_ 50000 for greater contrast'