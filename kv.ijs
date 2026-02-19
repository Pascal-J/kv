coclass 'kv'

NB. ═══════════════════════════════════════════════════════════════════════════
NB. ASSERTION CONJUNCTION
NB. ═══════════════════════════════════════════════════════════════════════════
NB. assertC: Assertion conjunction with custom error message.
NB.   Form: u assertC'msg' v   ──  Applies (v y) or (x v y), then asserts (u result).
NB.   Mechanism: 13!:8 signals error 12 when (0 e. u-result) is true.
NB.   The ^: conditional executes error only on assertion failure.
NB.   Final ] returns the original noun post-assertion.
assertC =: 2 : '] [ v (13!:8^:((0 e. ])`(12"_))) u'

NB. lr: Linear representation of a named entity.
NB.   5!:5 returns the textual definition of the name stored in boxed y.
lr_z_ =: 3 : '5!:5 < ''y'''

NB. ═══════════════════════════════════════════════════════════════════════════
NB. GENERAL UTILITIES
NB. ═══════════════════════════════════════════════════════════════════════════
NB. utilities to clean/modify/process data

NB. mdef: Monad-default conjunction. Converts dyad u to monad using default n.
NB.   Result: n&u when called monadically; u when called dyadically.
NB.   Pattern: Creates verbs with optional left arguments.
mdef =: 2 : 'n&u : u'  NB. monad default parameter n to dyad u

NB. dtb: Delete trailing blanks (or other fill atoms).
NB.   +./\. computes reverse running OR, identifying positions with
NB.   any non-fill character at or after that position.
NB.   ~: tests inequality against fill atom (default space).
NB.   Works for numeric fills when fill atom provided as dyadic x.
dtb =:  ] #~  +./\.@:~: mdef ' '  NB. used to clean fills, if data gets dirty before turning into boxed. works with numeric fills fill atom is dyad param.

NB. cut: Split string on delimiter (default space), removing empties.
NB.   <;._2 performs sequential cut on frets (delimiter marks end of segment).
NB.   ,~ appends delimiter to ensure final segment is captured.
NB.   -.&a: filters out empty boxes that arise from consecutive delimiters.
cut =: ([: -.&a: <;._2@,~) mdef ' '

NB. numerify: Convert string to number if y is a literal (type 2).
NB.   3!:0 returns internal type; 2 = literal.
NB.   0&". parses string as J expression, defaulting to 0 on failure.
NB.   ^: conditional applies conversion only to strings.
numerify =: 0&".^:(2 = 3!:0)@]

NB. linearize: Remove all singleton dimensions from shape.
NB.   Reshapes to ($ y) with 1s filtered out. Flattens spurious axes.
NB.   Essential for normalizing shapes before kv operations.
linearize =: (, $~ 1 -.~ $)@]  NB. remove all 1 dimensions.

NB. tableize: Coerce to rank-2 (table) by collapsing leading dimensions.
NB.   ,: ensures at least rank 1 (itemize), then ,/ merges excess dimensions.
NB.   Unlike ,. which removes trailing dims, this preserves last dimension width.
tableize =:  ,/^:(2 < #@$)@,: NB. set shape count to 2, but opposed to ,., remove leading dimensions

NB. maybenum: Conditionally numerify boxed strings that represent valid numbers.
NB.   Tests if string equals its round-trip through ":@:numerify.
NB.   linearize normalizes shapes before comparison to handle padding.
NB.   dltb strips leading/trailing whitespace first.
maybenum =: 0&".^:(] -:&linearize ":@:numerify)@dltb NB. for mixed string/num boxed values will convert strings that can be into numbers.

NB. standardnull: Normalize empty arrays to canonical empty string form.
NB.   Any array with 0 in shape is semantically empty (like i.0).
NB.   Returns '' for empty, otherwise identity.
standardnull =: (''"_)^:(0 e. $) NB. any 0s in shape equivalent to i.0

NB. Mifnull: Monad-if-null adverb. Applies u monadically when x is empty string.
NB.   @. is agenda (conditional verb selection).
NB.   Tests x for '' (null string), selects u@] (monad) or u (dyad).
Mifnull =: 1 : ' u`(u@])@.('''' -: [)' NB. monad application if x is null.  y null will still apply to null


NB. ═══════════════════════════════════════════════════════════════════════════
NB. KV ACCESSOR UTILITIES
NB. ═══════════════════════════════════════════════════════════════════════════
NB. G0, G1, G2: Generic box accessors (0th, 1st, 2nd element).
NB.   kvkeys/kvvals are semantic aliases for kv structure.
NB.   kv structure: (keys ; values) where keys are symbols, values are data.
kvkeys =: G0 =: 0 {:: ]
kvvals =: G1 =: 1 {:: ]
G2 =: 2 {:: ]

NB. ss: Space-separated string cutter. Adverb creating verb from string m.
NB.   Returns boxed list of words.
ss =: {{ ' '&cut m }}

NB. bb: Backtick-separated string cutter with trim.
NB.   dltb each strips whitespace from each segment after cutting on backtick.
bb =: 1 : 'dltb each (''`''&cut) m'

Note 'kv/dictionary definition'
A datastructure such that when provided with a list of keys a get function will retrieve 
  the latest value associated with that key as a result of latest set/add/del operations that could have modified that associated value. 
If a requested retrival key has no associated value, then nothing is returned, (unless kvgetf version where nulls will be returned for missing keys)
  where in a list of requested keys, nothing combined with other requested values is the list of the other values.

If a user only uses set/del modifiers after loading or optimizing to a unique dictionary, then the dictionary will remain in unique state.
  a user may use special add1 function to place kv in non-unique state.  get and filter will still operate as if unique.
  in non unique mode, filtall and delall will affect multiple values.  set/del/get operate on last key occurrence + related value.

keys are stored as a table of symbols.  Values as a table of numeric, string, or boxed values.  Table width for simplest keys and values is 1.
This allows multikey keys or metainfo after first key.  Allows inverted table or associated array datastructures.
Boxed values permit embedded keyed dictionaries.
	keyed data/value access is similar to J locale access to data/functions. OOP without classes is application for kv
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
	x right argument to get/del is a boxed list of symbol keys or keys as strings/boxes that will be autoconverted to symbols
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

NB. ═══════════════════════════════════════════════════════════════════════════
NB. KV CORE CONSTRUCTORS
NB. ═══════════════════════════════════════════════════════════════════════════

NB. kvEMPTY: Canonical empty dictionary constant.
NB.   Structure: 2 boxes, each containing a 0×1 table (,.i.0).
NB.   Use kv for bulk creation rather than set on empty.
kvEMPTY =: 2$ <,.i.0 NB. for reference. use kv (bulk) instead of set on empty

NB. tosym: Universal symbol converter with cascading fallbacks.
NB.   Processing pipeline: cut string → box → symbolize.
NB.   :: provides fallback on error: tries cut first, then passes symbols through.
NB.   (@]) ensures right argument flows through the pipeline.
NB.   Handles: strings (cut then symbolize), boxes (symbolize), symbols (identity).
tosym =: ( s: :: ])@:(cut :: ]) (@]) NB. string transformed to boxes cut on space.  Boxes transformed to symbols. symbols unchanged. 

NB. kvuniquify: Deduplicate keys, keeping last occurrence (last-write-wins).
NB.   i: finds LAST index of each unique key (vs i. which finds first).
NB.   ~. extracts unique keys; (] i: ~.) finds their last positions.
NB.   {~L:_1 indexes at infinite box depth (both keys and values).
NB.   ^: conditional skips if already unique (count equals unique count).
NB. filters dict for unique keys keeping the last value associated to a key (last add/set wins)
kvuniquify =: (] {~L:_1  (] i: ~.)@:G0) ^: ( (#@~. < #)@:G0)  NB. optimize for presumed unique.

NB. NOTE: Line 106 appears to be a truncated duplicate of kvuniquify
NB. filters dict for unique keys keeping the last va.)@:G0) ^: ( (#@~. < #)@:G0) NB. optimize for presumed unique.

NB. kv1: Core kv constructor (permits duplicates).
NB.   Validates: key count must equal value count (assertC).
NB.   tosym converts x (keys) to symbols, then reshapes to (n,1) table.
NB.   Values reshaped to table via ,.^:(1=#@$) when rank is 1.
NB.   ,&<~ boxes both and concatenates: (boxed-values) , (boxed-keys) → (keys;values).
NB. returns a kv from list keys and values. keys transformed into symbols and shaped as num,1.  If values a list, also shaped num,1 so that future adds will create fills if they are longer than atoms.
kv1 =: (,.^:(1 = #@$)@] ,&<~ ] =&# assertC 'keys and values must have same item count' (] $~ 1 ,~ #)@:tosym@[ )

NB. kv: Primary kv constructor with automatic deduplication.
NB.   Composes kv1 with kvuniquify to ensure unique keys.
NB.   This is the standard entry point for creating dictionaries.
kv =:   kv1 (kvuniquify@:)  NB. choice of functions, permits unique or non-unique implmentations.

NB. expandy: Adverb to broadcast scalar y to match x count.
NB.   When x and y counts differ, reshapes y to x's count via ,: (itemize).
NB.   Useful for scalar extension in bulk operations.
expandy =: 1 : '[ u ((,:@] $~ #@[)^:(~:&#))' NB. if x and y count don't agree, reshape y to match x count, assuming that y is a single item
NB.   ' '&cut(&.>)`(".(&.>))"0 ' as ` 3' bb NB. cuts first on ` ' '&cut for first, ". for 2nd box

NB. ═══════════════════════════════════════════════════════════════════════════
NB. DSL (DOMAIN SPECIFIC LANGUAGE) SUPPORT
NB. ═══════════════════════════════════════════════════════════════════════════
NB. DSL to simplify passing keys ` values as a one line string.  
NB. keys and values are separated by a `
NB. default key processing is cut on space.  Use gerund param to override it. keyprocessfunction`u instead of u
NB. u will apply to values string to generate value items. Examples:
NB.		". will turn numeric.  supports expressions such as 10 3 $ i.30 to make 10 items.
NB.		';'&cut will make string items. (keeps leading/trailing spaces)
NB.		maybenum@:(';'&cut) will cut on ; and then turn any items that can be into numbers.
NB. Any boxed values created by DSL, will attempt to be unboxed into items if no error.  So if all strings, will automatically be turned into padded items.

NB. kvdsL: DSL adverb for creating kv from backtick-separated string.
NB.   Parses "keys ` values" format where:
NB.     - Default key parser: ;: (J tokenizer, allowing J words as keys)
NB.     - Value parser: provided as adverb argument m
NB.   Gerund form `k val` allows custom key parser before backtick.
NB.   _2&{. takes last 2 elements (handles optional leading key processors).
NB.   (> :: ]) attempts unboxing of values; falls back to boxed on error.
NB.   f. fixes the definition, freezing the parsed result.
kvdsL =: (;:`) 1 : 0 ((kv&.>(<@)/(>@)(>@)(f.))@:) NB. embedded multiline adverb
'`k val' =. _2 {. m
NB.(k @:G0 ,&< (> :: ])@:val@:G1)@:(dltb each@:('`'&cut)) f. 
(k @:G0 ,&< (> :: ])@:val@:G1) ((@(_2&{.)) ,~ tosym L:0(^:(0 <#))@:(_2 &}.) )@:(dltb each@:('`'&cut)) f. 
)

NB. itdsl: Inverted table DSL parser for values.
NB.   Parses field values separated by `;`, with nested `:` or space separators.
NB.   Pipeline: cut on `;` → maybenum each → handle nested structure.
NB.   ':'&cut^:(2=3!:0) cuts on `:` only for strings.
NB.   {.^:(2<#@$)each truncates excess dimensions per field.
NB.   Designed for structured data like: "field1;field2;field3" where fields may contain sublists.
NB. verb arguments to kvdsL to create inverted tables. keys=field names. keys ` tabledata still separated by `
NB. itdsl has values for each key separated by ;  and within each string field by : or space (assumes more than 1 value ie. if only 1 string value with : at end will fail (and use space separator))
NB. use with kvdsL kvsetL kvaddL
itdsl =:  cut &>^:(1 = #)@(':'&cut)^:(2 = 3!:0)(>@:)@(,.^:(2 ~: 3!:0))@maybenum each@(';'&cut)( {.^:(2< #@$)each@:)

NB. ═══════════════════════════════════════════════════════════════════════════
NB. KV APPEND / ADD OPERATIONS
NB. ═══════════════════════════════════════════════════════════════════════════

NB. append: Robust concatenation with automatic boxing promotion.
NB.   Cascading :: fallbacks handle type incompatibilities:
NB.   1. Direct , (concatenate) – works for compatible types
NB.   2. Box x items (<"_1@[) then concatenate
NB.   3. Concatenate to boxed y (<"_1@])
NB.   4. Box both sides
NB.   (,.@:) ensures table shape (column vector) output.
NB. allows "upgrade" of value structure when new items are incompatible with existing ones.
append =: , :: (, <"_1) :: ((<"_1)@[ , ]) :: ([ , <"_1@]) :: (<"_1@[ , <"_1@]) (,.@:)

NB. kvadd1: Append kv x to kv y without deduplication.
NB.   append~ swaps arguments (y append x) for proper concatenation order.
NB.   L:_1 applies at infinite depth (to both keys and values boxes).
NB.   ^:(0<#@G0@[) guards against empty x dictionary.
NB.   Preserves duplicates – enables undo semantics (del removes last).
NB. append items from kv x into kv y.  1verb ommits uniquify step.
kvadd1 =: append~ L:_1(^:(0 <#@G0@[))  NB. guard against empty x dictionary.

NB. kvadd: Append with deduplication. Standard add operation.
kvadd =: kvuniquify@:kvadd1  NB. adds and updates uniquify

NB. kvaddL: DSL adverb for add. Parses x string, adds to y dictionary.
kvaddL =: kvdsL@[ kvadd ]  NB. adverb (AVV) that uses DSL to process x string. see kvdsL for u param.

NB. kvadd1L: DSL adverb for add without deduplication.
kvadd1L =: kvdsL@[ kvadd1 ]  NB. adverb (AVV) that uses DSL to process x string. see kvdsL for u param.

NB. kvinsert: Insert kv at specific index position.
NB.   x format: (keys kv values),< insertindex (3 boxes total).
NB.   Does NOT uniquify – later duplicate keys still win on get.
NB.   Index arithmetic: (0..insert-1), (new items), (insert..end).
NB.   G0/G1/G2 extract count, position, and new items from compound x.
NB. manipulate the key/value order by inserting x: (ks kv vs),< atindexpoint (3 boxes).  Does not uniquify. if keys exist later than insert point, those values are still "official" (get result)
kvinsert =: (}:@[ kvadd1 ]) ([ kvi~ (i.@(G1 + G2) ([ {~ (-@G1 }. [ }.~  G0),~ (G2 (+ i.) G1),~ G0 {. [ ) ])) G2~ ([ , ((<: G1) *. 0 < [) assertC 'indexat must be between 0 and count of kvitems') ,&#&G0
NB.ex: 	   ' gg fr` 133 15' ". kvaddL ' as fr' kvbulk 33 5

NB. kvaddm: Add missing keys only. Merges defaults without overwriting.
NB.   Filters x to keys NOT in y (#~ -.@:e.&G0), then adds.
NB.   Critical for function parameter decomposition with defaults.
NB. very useful for function call decomposition where some parameters may be missing from dict, but default values are needed.
	NB.  'a b c d' =. 'certainA maybeB certainC maybeD' kvgetb '('maybeB maybeD' kv bdefaultval , defaultval) kvaddm y NB. y is dict
NB. or         'a b c d' =. G1 'certainA maybeB certainC maybeD' kvfilt '('maybeB maybeD' kv bdefaultval , defaultval) kvaddm y NB. y is dict
NB. or improved with nulls as defaults:  'a b c d' =. 'a b c d' kvgetf y
kvaddm =: (] kvadd1~ [ kvfilt~ ([ #~ -.@:e.)&G0) NB.add only if key is missing.  x is dict of new keys new vals. y is dict to update

NB. ═══════════════════════════════════════════════════════════════════════════
NB. KV INDEX-BASED ACCESS
NB. ═══════════════════════════════════════════════════════════════════════════
NB. if kv keys are static, saving indexes may speed access. x is list of numeric indices, kv y is filtered by index list x
NB. kv keys and values are static for purposes of functions that access keys or values in order to 

NB. kvi: Filter kv by numeric index list.
NB.   { L:_1 applies selection at infinite box depth (keys and values).
NB.   Enables index-based access when keys are static (faster than lookup).
NB.   G0@kvi retrieves keys at those indices – useful for keys-from-values patterns.
kvi =: { L:_1 NB. filter by index  G0@kvi retrieves keys, if x is computed from values (G1), then this is a keysfromvalues function.

NB. kvdi: Delete by index. Returns kv with items at indices x removed.
NB.   Computes complement indices (all except x) then applies kvi.
kvdi =: ] kvi~ [ -.~ i.@#@G0  NB. del by index

NB. ═══════════════════════════════════════════════════════════════════════════
NB. KV DELETE OPERATIONS
NB. ═══════════════════════════════════════════════════════════════════════════

NB. kvdel: Delete keys x from kv y (last occurrence if duplicates exist).
NB.   i: finds LAST index of each key (vs i. for first).
NB.   ,.@tosym normalizes x to column of symbols.
NB.   Enables undo semantics: delete reveals previous value if duplicates exist.
NB.x are keys boxed or ' '&cut formatted string. kv y has items removed that match keys x.
kvdel =:  ] kvdi~ G0 i: ,.@tosym@[  NB. if kv is dirty (not unique), del will undo last duplicate add

NB. kvdeld: Deep delete. Traverses nested kv structure.
NB.   x is path: 'level1`level2`targetkey' or boxed list.
NB.   Deletes at deepest level, rolls up changes through ancestor path.
NB.   }:@] extracts path prefix; >@{:@] extracts target key.
NB.   kvsetd propagates the modified nested structure back up.
NB. deep del matches kvd x format below: last key in list operates at deepest point in path.  result rolled up into path described by previous keys.
kvdeld =: ] ([ kvsetd~ (linearize each)@}:@]  kv&.>(<@)/(>@)(>@)@:(, <@<) >@{:@] kvdel [ kvgetd~ }:@]) (,.@tosym@dltb each @:('`'&cut)(linearize@) :: (,.@tosym each@](linearize@) )@[)

NB. ═══════════════════════════════════════════════════════════════════════════
NB. KV GET / RETRIEVE OPERATIONS
NB. ═══════════════════════════════════════════════════════════════════════════

NB. kvget: Retrieve values for keys x from kv y.
NB.   i: finds last index of each key (last-write-wins semantics).
NB.   (#@[ -.~ ...) filters out "not found" indices (index = key count).
NB.   Returns atoms/lists when possible via (>::]) unboxing attempt.
NB.   linearize removes singleton dimensions from result.
NB.   BUG NOTE: Atomic unpadded chars may concatenate unexpectedly.
NB. gets values by keys in x from kv y.  if any x not found, then omit from result. if no x found return i.0
kvget =: (G1 {~ G0 (#@[ -.~ i:) ,.@tosym@[)(linearize@)((> :: ])@)NB. if values are all atomic, then returns atom or list of atoms. BUGf: if items are all unpadded chars then will concatenate them.

NB. kvgetb: Get values without unboxing attempt. Returns boxed values.
NB.   Safer than kvget when value structure must be preserved.
kvgetb =: (G1 {~ G0 (#@[ -.~ i:) ,.@tosym@[)(linearize@)  NB. do not attempt unboxing.

NB. kvgetf: Get with fill for missing keys.
NB.   Missing keys return i.0 (empty numeric) as placeholder.
NB.   Uses kvaddm to inject defaults (a: fills) for missing keys before get.
NB.   Ensures result count matches request count.
kvgetf =: ([ kvgetb ] kvaddm~  a: (] ,&< [ ,.@:#~ #@]) ,.@tosym@[) NB. missing keys still return filled with values (i.0)  no attempt to unbox.
NB. when attempting multikey get, ensure that any possible missing keys are at end of list, or use kvfilt instead.  'key1 missing key2 missing2' as x will return 2 keys without indication of which values correspond to found keys.

NB. kvfilt: Filter kv y by keys x. Returns kv subset (both keys and values).
NB.   Unlike kvget which returns only values, kvfilt returns dictionary structure.
NB.   {~L:_1 selects at infinite depth (both keys and values boxes).
NB. filters kv y by keys in x
kvfilt =: (] {~ L:_1 G0 (#@[ -.~ i:) ,.@tosym@[)

NB. kvfne: Filter out empty values (except duplicate key entries).
NB.   (a: ~: G1) identifies non-empty value positions.
NB.   ~.@:(#~,) keeps unique keys where value is non-empty.
NB.   Useful for cleaning sparse dictionaries.
kvfne =: (kvfilt~ G0 ~.@:(#~,) a: ~: G1)  NB. filter out non empty values.  except if empty value is a duplicate entry.

NB. ═══════════════════════════════════════════════════════════════════════════
NB. STRING MATCHING AND QUERY UTILITIES
NB. ═══════════════════════════════════════════════════════════════════════════

NB. padstrmatch: Match unpadded strings against padded table.
NB.   Padded tables have trailing spaces; this finds matches despite padding.
NB.   Concatenates search strings to table, checks if any tail elements match heads.
NB.   ';'&cut :: ] handles both semicolon-separated and plain string input.
padstrmatch =: -@#@:(';'&cut :: ])@[ (}. e. {.) (] , >@:(';'&cut :: ])@[) NB. when strings padded, this function allows matching with (unpadded x) with padded version (in y).
NB. padstrmatch =: -@#@[ (}. e. {.) (] , >@[) NB. when strings padded, this function allows matching with (unpadded x) with padded version (in y).

NB. kvQ: Query filter adverb. Filters kv where predicate u is true.
NB.   u operates on full dictionary, returns boolean mask.
NB.   I.@ finds true indices; kvi"1 filters values; kv~ reconstructs.
NB.   AVV pattern: result is verb operating on kv dictionaries.
kvQ =: ((I.@) kvi"1 G1) kv~ linearize@:G0  NB. AVV for boolean function u (visible to full dict), filter dic where u is true.

NB. ═══════════════════════════════════════════════════════════════════════════
NB. DEEP GET OPERATIONS
NB. ═══════════════════════════════════════════════════════════════════════════
NB. deep get (kvd) will tunnel into sub dicts. x is list of boxes or string cut first on ` then on space inside each box. left to right boxes specify top down keys

NB. kvgetd: Deep get through nested kv structure.
NB.   x is path: 'level1`level2`key' or boxed path list.
NB.   F.. or /: fold operations traverse the path, applying kvget at each level.
NB.   |. reverses path for right-to-left fold execution.
NB.   (>::]) attempts final unboxing of retrieved value.
NB. NOTE: Original F.. version had locale-related bugs; replaced with fold version.
kvgetd =: (<@] ] F.. (kvget &.>) (,.@tosym@dltb each @:('`'&cut)(linearize@) :: (,.@tosym each@](linearize@)) )@[)((> :: ])@)  NB. strange value error bug calling localed from base related to F.. ?
kvgetd =: (<@]  kvget &.>/@:(,~ |.) (,.@tosym@dltb each @:('`'&cut)(linearize@) :: (,.@tosym each@](linearize@)) )@[)((> :: ])@)

NB. ═══════════════════════════════════════════════════════════════════════════
NB. INVERTED TABLE DISPLAY
NB. ═══════════════════════════════════════════════════════════════════════════

NB. itdisp1: Display kv as inverted table for selected fields.
NB.   <"_1@G0 boxes individual keys; kvget retrieves their values.
NB.   ,: (laminate) creates 2-row display: keys on top, values below.
NB.   boxopen"_1 ensures values are boxed for uniform display.
itdisp1 =: <"_1@G0@:tosym ,: boxopen"_1@kvget NB. displays kv as inverted table (for fields x). for all fields use: (G0 itdisp ])
itdisp1 =: ((<"_1)@G0 ,: linearize@:(boxopen"_1)@:G1)@:kvfilt NB. displays kv as inverted table (for fields x). for all fields use: (G0 itdisp ])

NB. itdisp: Display all fields as inverted table.
itdisp =: G0 itdisp1 ]

NB. ═══════════════════════════════════════════════════════════════════════════
NB. FILTER ALL / DELETE ALL (NON-UNIQUE MODE)
NB. ═══════════════════════════════════════════════════════════════════════════
NB. kvf uses lastkey value to filter.  Allowing all keys filter allows expansion of use beyond dictionary. 
NB. duplicate keys allow undo, and having firstkeyindict contain value for field1 as a compound value structure, 2ndkeyindict holds field2 value...
NB. THe /. (key) dyad function is a powerful J paradigm permitted by kvfall multiple key copy structure.

NB. kvfiltall: Filter returning ALL occurrences of key (not just last).
NB.   ="0 _ compares each search key against all stored keys.
NB.   +./^:(1<#) reduces multiple matches with OR.
NB.   #~L:_1 applies boolean mask at infinite depth.
NB.   Useful when non-unique mode is intentionally used.
kvfiltall =: ] #~ L:_1 tosym~ ,@:(+./^:(1 < #))@:(="0 _) G0

NB. kvdelall: Delete ALL occurrences of keys x (not just last).
NB.   -.@ inverts the mask from kvfiltall logic.
NB.   For non-unique internals where all duplicates should be removed.
NB. delete all instead of last keys x from kv y.  When non unique internals are relied upon.
kvdelall=: ] #~ L:_1 tosym~ ,@:-.@:(+./^:(1 < #))@:(="0 _) G0

NB. ═══════════════════════════════════════════════════════════════════════════
NB. KV UPDATE / SET OPERATIONS
NB. ═══════════════════════════════════════════════════════════════════════════
NB. optimized to keep unique(ish) status, set will update in place those keys that are found, and add1 keys not found.
NB. merging kv x into kv y.  will not check for nulls in kv x
NB. IMPLEMENTED: extra err check to use boxed x values before kvadd resorted to. kvadd would trigger if attempting incompatible update on CURRENTLY unboxed kv y values.
NB. TOCONSIDER: kvadd or kvadd1 should never be backstop to update.  Match full append backstops

NB. kvupdate2: Update fallback with automatic boxing of x values.
NB.   Uses J's dyadic } (amend) with gerund form:
NB.     selector`index`target }: new values at computed indices.
NB.   i:~&G0 finds positions of x keys in y keys.
NB.   <"_1@:G1~ boxes x values for type compatibility.
kvupdate2 =: (G0 ,&< <"_1@:G1~`(i:~&G0)`(G1)}) NB. internal error handling.  try again with boxed x items.

NB. kvupdate: Update existing keys in-place with cascading fallbacks.
NB.   Primary: direct amend (requires compatible types).
NB.   Fallback 1: kvupdate2 (box x values).
NB.   Fallback 2: kvadd (full append + uniquify on type mismatch).
kvupdate =: (G0 ,&< G1~`(i:~&G0)`(G1)}) :: kvupdate2 :: kvadd NB. requires keys present.  Error assumes rare incompatible type.

NB. kvupdate1: Update variant preserving non-unique structure on error.
NB.   Falls back to kvadd1 (no uniquify) instead of kvadd.
kvupdate1 =: (G0 ,&< G1~`(i:~&G0)`(G1)}) :: kvupdate2 :: kvadd1 NB. will keep "ununique structure" on error. kvadd will uniquify.

NB. kvset: Full merge operation: update existing + add new keys.
NB.   Three-phase operation:
NB.   1. Delete keys from y that are in x but shouldn't be overwritten (-.&G0)
NB.   2. Update keys that exist in both x and y
NB.   3. Add keys from x that don't exist in y
NB.   ^:(0<#@G0~) guards against empty subsets.
kvset =:  (([ kvdel~ -.&G0) kvupdate^:(0 <  #@G0~)  ([ kvfilt~ -.&G0) kvadd1^:(0 <  #@G0~) ] ) 

NB. kvset1: Set variant preserving non-unique structure.
kvset1 =:  ([ kvdel~ -.&G0) kvupdate1^:(0 <  #@G0~)  ([ kvfilt~ -.&G0) kvadd1^:(0 <  #@G0~) ] NB. ensures ununique properties if they exist (due to error handling in update which includes uniquify if updating to incompatible type that requires box promotion)

NB. kvsetL: DSL adverb for set. Parses x string as kv, sets into y.
kvsetL =: kvdsL@[ kvset ]  NB. AVV adverb uses DSL to create x kv from string.

NB. kvsetd: Deep set at nested path.
NB.   Retrieves existing nested kv at path, applies set, stores result back.
NB.   linearize@G0~ extracts key path; kv< wraps modification for storage.
NB.   Recursive structure: get nested → modify → set nested.
NB. set at depth1 key1 kvbulk keys;values will set keys and values at depth of key1. 
NB.	if x is hierarchy of key1 kvbulk key2 kvbulk keys;values then key2 will have its value replaced by keys;values... instead of set(update/add) operation at depth.
NB.TODO: 	Having set work at unlimited depth will require extra leading boxes in x similar to kvd
kvsetd =: (] kvset~ linearize@G0~ (kv <) ,@:>@G1~ kvset G0~ kvget ])

NB. ═══════════════════════════════════════════════════════════════════════════
NB. KV OPTIMIZATION AND VALIDATION
NB. ═══════════════════════════════════════════════════════════════════════════

NB. kvO: Optimization adverb. Freezes kv m for faster repeated access.
NB.   Embeds full kv inside resulting verb definition via f. (fix).
NB.   Resulting monad: y (keys) → values from embedded dictionary.
NB.   Trades memory for speed when dictionary is static.
NB. ADV optimize kv function once kv m is static.  resulting function is monadic kvget for keys to retrieve.  Returned function embeds full kv inside it. Not sure if special code for (m i: ]) so not using.
kvO =: 1 : 'm =. kvuniquify m label_. (((G1 m) {~  (# G0 m) -.~ (G0  m)&i:)@:,.@tosym (linearize@)) f.'  

NB. iskv: Validate kv structure.
NB.   Checks: 2 boxes, keys are symbols (type 65536), table-shaped (rank 2).
NB.   (1 <: L.) ensures at least 1 level of boxing.
NB.   :: 0 returns 0 (false) on any error.
NB. count = 2, boxed, box0 contains symbols shaped as table.
iskv =: (( (2 = #@$) *. 65536 = 3!:0)@G0 *. (1 <: L.)*. 2 = #)(@]) :: 0  NB. just checking keys shaped as table.

NB. ═══════════════════════════════════════════════════════════════════════════
NB. FORKEY CONJUNCTION
NB. ═══════════════════════════════════════════════════════════════════════════

NB. forkey: Conjunction for key-specific transformation.
NB.   Form: (x u forkey'keyname' kv) – applies dyad u to value at key.
NB.   Pipeline: get key value → apply u with x → set result back.
NB.   Enables functional updates to nested kv structures.
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


NB. forkeyn: Null-guarded forkey variant.
NB.   Only applies transformation if key exists (non-null get result).
NB.   ^:(0<n#@kvget]) guards execution on non-empty retrieval.
NB. variant that only updates if key does not return null. n(ull guarded)
forkeyn =: 2 : '(] kvset~ n kv [ u n kvget ])^:(0 < n #@kvget ])'

NB. kvtest: Load and run test suite.
NB.   Sets MYDIR to directory of current file using 4!:4 (name index)
NB.   and 4!:3 (script names). Loads kvtest.ijs from same directory.
NB. call test code.  y ignored.
kvtest =: 3 : 0
MYDIR =: getpath_j_  '\/' rplc~ > (4!:4<'thisfile'){(4!:3)  thisfile=:'' NB. boilerplate to set the working directory
load MYDIR, 'kvtest.ijs'
)


NB. ═══════════════════════════════════════════════════════════════════════════
NB. ═══════════════════════════════════════════════════════════════════════════
NB. RAGGED ARRAY CLASS (ra)
NB. ═══════════════════════════════════════════════════════════════════════════
NB. ═══════════════════════════════════════════════════════════════════════════
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

NB. ═══════════════════════════════════════════════════════════════════════════
NB. RA UTILITIES
NB. ═══════════════════════════════════════════════════════════════════════════

NB. amend: Generalized structural amend using 6-element gerund form.
NB.   `:6 is the gerund tie for complex amendments.
NB.   Structure: [selector`indexer`arrayfn`retriever`default`modifier].
NB.   Implements ar (array reference) with amend semantics.
amend =: [` ([. ` ar) `{`] `: 6 ` (]."_) `] }~~

NB. dasM: Dyad-as-Monad converter for modifiers expecting monadic verbs.
NB.   For adverbs like \ or ;. that require monadic u.
NB.   Converts dyadic call to monad via x&u binding.
NB.   Pattern: (x dasM u modifier) → applies modifier to (x&u).
NB. For functions/advs that a monadic verb (\ ;.), Adverb that will convert a dyadic call into x&u : monad that the further modifier right expects.
NB. if a natural monad u is passed (instead of being called dyadically) then that u is returned.
dasM_z_ =:  ([. : (2 : 'x&u y')) a:

NB. ═══════════════════════════════════════════════════════════════════════════
NB. RA CONSTRUCTORS
NB. ═══════════════════════════════════════════════════════════════════════════

NB. ramonad: Core ra constructor (monadic form).
NB.   Input: boxed list of homogeneous items (strings or numbers).
NB.   Creates kv with 'data:' (flattened ;) and 'lengths:' (#&> each item).
NB.   Assertion ensures homogeneity – all items must be same type.
NB. x is optional keys (tosym format). y boxed values .
NB.ra =:   (''"_`('keys:' kv <@,@G0)@.iskv  kvadd1^:(0 < #@[) (('data:';'lengths:') kv ,@:(#&>) ,&<~ ;)) :: ((0: assertC 'values must be homogeneous')@]`G1@.iskv)
ramonad =: (('data:';'lengths:') kv ,@:(#&>) ,&<~ ;) :: (0: assertC 'values must be homogeneous')(@]) 

NB. ra: Full ra constructor (ambivalent: monad or dyad).
NB.   Monad: creates ra from boxed values.
NB.   Dyad: x is keys (tosym format), y is boxed values.
NB.   Validates key count equals value count before adding 'keys:' field.
NB.   kvadd1 appends keys kv to base data/lengths kv.
NB. ra =:   ramonad : (tosym@[ (('keys:' (kv <) [) kvadd1 ])   ramonad@])
ra =:   ramonad : (tosym@[ (('keys:' (kv <) [) kvadd1  (#@[ = 'lengths:' #@kvget ]) assertC 'keys and values must have same item count')   ramonad@])


NB. ═══════════════════════════════════════════════════════════════════════════
NB. RA INDEX BUILDING AND MAINTENANCE
NB. ═══════════════════════════════════════════════════════════════════════════

NB. rabuildidx1: Build start indices from lengths (unconditional).
NB.   +/\ computes cumulative sum of lengths.
NB.   (0,}:) prepends 0 and drops last (converts lengths to start positions).
NB.   kvset updates 'indexes:' field in ra kv.
NB. y is kv that holds ra.
rabuildidx1 =: (] kvset~ 'indexes:' (kv <) 'lengths:' (0 , }:)@:(+/\)@:kvget ])

NB. rabuildidx: Build indices only if not present.
NB.   ^:(0=...) conditional: only builds if 'indexes:' is empty/missing.
NB.   Lazy evaluation – indices built on first access, not on creation.
rabuildidx  =: rabuildidx1^:(0 = 'indexes:' #@kvget ])(@])

NB. rabuildcuts: Build cutpoint boolean mask for ;. operations.
NB.   Cutpoints mark start of each item in flat data array.
NB.   1: at index positions, 0: elsewhere.
NB.   Used with (cutpoints u;.1 data) for item-wise operations.
rabuildcuts =: (] kvset 'cutpoints:' (kv <) ] 1:`]`('data:' (0 #~ #)@kvget [)} 'indexes:' kvget ])@rabuildidx

NB. rachecknulls: Check and flag presence of null items.
NB.   Null = item with length 0 in 'lengths:' field.
NB.   Sets 'includesnulls:' boolean flag in ra.
NB.   0 e. lengths tests if any zero-length items exist.
rachecknulls =:] kvset~ 'includesnulls:' (kv <) 0 e. 'lengths:' kvget ]  NB. if lengths include 0, then there are nulls.

NB. ═══════════════════════════════════════════════════════════════════════════
NB. RA NULL HANDLING
NB. ═══════════════════════════════════════════════════════════════════════════

NB. rakillnulls1: Remove null items (length=0) from ra structure.
NB.   Filters lengths, indexes, and keys by (0 ~: lengths) mask.
NB.   forkeyn applies filter only if field exists (null-guarded).
NB.   <@# boxes the filtered result for kv storage.
NB.rakillnulls1 =: ] kvset~ ('lengths:';'indexes:') kv&>/@:(] ,&<~ [ {.~ #@]) 0 <"1@:|:@:(|:@] #~ (~: {.)) 'lengths: indexes:' tableize@kvget ]
rakillnulls1 =: (0 ~: 'lengths:' kvget ]) ([ <@# forkeyn 'keys:' [ <@# forkeyn 'indexes:' <@# forkey 'lengths:') ]

NB. rakillnulls2: Conditional null removal based on flag.
NB.   Only removes if 'includesnulls:' is 1 (true).
NB.   Clears flag after removal.
rakillnulls2 =: (('includesnulls:' kv < 0) kvset rakillnulls1)^:(1 = 'includesnulls:' +/@kvget ])

NB. rakillnulls: Full null removal with fresh null check.
NB.   Bypasses cached flag – always checks and removes.
rakillnulls =: rakillnulls2@:rachecknulls  NB.bypasses/ignores "cached" null presence.

NB. radisallownulls: Set disallow flag and remove existing nulls.
NB.   Prevents future null insertions.
radisallownulls =: ('disallownulls:' kv < 1) kvset rakillnulls2  NB. flag to prevent future nulls.

NB. ═══════════════════════════════════════════════════════════════════════════
NB. RA ADD OPERATIONS
NB. ═══════════════════════════════════════════════════════════════════════════

NB. raadd1: Append ra x to ra y (core operation).
NB.   Concatenates 'data:', 'lengths:', and optionally 'keys:' fields.
NB.   forkeyn handles optional keys – only appends if y has keys.
NB.   assertC validates x has keys if y has keys.
NB.   <@,~ boxes concatenated result for kv storage.
NB. appends ra x to ra y. keys from x only included if y has keys.
raadd1 =: ('keys:' kvget [ ) (([ (0 < #@]) assertC 'keys should exist in x' [) <@,~ ]) forkeyn 'keys:' ('lengths:' kvget [ ) <@,~ forkey 'lengths:' ('data:' kvget [ ) <@,~ forkey 'data:' ]

NB. raadd: Add with null handling based on disallownulls flag.
NB.   If y disallows nulls, removes nulls from x first.
raadd =: [`(rakillnulls@[)@.(1 = 'disallownulls:' +/@kvget ]) raadd1 ]

NB. raaddn: Add ensuring no nulls in target.
NB.   Sets disallownulls on target before adding.
raaddn =: [ raadd radisallownulls@]  NB. ensure no nulls

NB. ═══════════════════════════════════════════════════════════════════════════
NB. RA ACCESS BY LENGTH/INDEX
NB. ═══════════════════════════════════════════════════════════════════════════

NB. li: Extract items from flat array using length/index table.
NB.   x: 2-column table of (length, startindex) pairs.
NB.   Computes (start + i.length) for each row, then selects from y.
NB.   &.|: transposes for row-wise operation, then transposes back.
NB.   {L:0 selects at base level, returning boxed items.
NB. li(length index) x is table with 2 items lenght(s) index(es).  will retrieve from flat array/str y those items in y (boxed).
li =: <@(+ i.)~/"1&.|:@[ {L:0 ]

NB. li1: Flat slice extraction (unboxed concatenation).
NB.   Like li but returns flat array of selected elements.
NB.   ;@: unboxes and concatenates – suitable for replacing 'data:' field.
li1 =: <@(+ i.)~/"1&.|:@[(;@:) { ] NB. returns flat slices (suitable for replacing data:) instead of boxed items

NB. rali: Extract items from ra's data field using length/index pairs.
rali =: li 'data:' kvget ]

NB. rali1: Flat extraction from ra's data field.
rali1 =: li1 'data:' kvget ]

NB. ═══════════════════════════════════════════════════════════════════════════
NB. RA KEY/INDEX RESOLUTION
NB. ═══════════════════════════════════════════════════════════════════════════

NB. ramakei: Convert keys or indices to numeric indices.
NB.   If x is symbols (type 65536), looks up in 'keys:' field.
NB.   If x is numeric, passes through unchanged (tosym leaves numbers alone).
NB.   (#@[-.~i:) finds last index, filtering "not found" values.
NB. get lenghts/indexes by index(es) or key(s) x from ra y
ramakei =: ] (] (#@[ -.~ i:)~ 'keys:' kvget [)^:(65536 = 3!:0@]) tosym~ NB. tosym leaves numbers(indexes) unchanged. returns indexes from keys or indexes

NB. ragetli: Get length/index pairs for keys or indices x.
NB.   Returns 2-column table from 'lengths:' and 'indexes:' fields.
NB.   Builds index if needed via rabuildidx.
ragetli =: rabuildidx@] (] {"1 'lengths: indexes:' kvget [) ramakei 

NB. ═══════════════════════════════════════════════════════════════════════════
NB. RA GET OPERATIONS
NB. ═══════════════════════════════════════════════════════════════════════════

NB. raget1: Get items by key(s) or index(es). Returns boxed list.
NB.   Resolves x to length/index pairs, extracts via rali.
NB. get by index(es) or key(s) x from ra y. returns boxed list of items.
NB. raget1 =:  ] ([ rali~ ] {"1 'lengths: indexes:' kvget rabuildidx@[) ] (] (#@[ -.~ i:)~ 'keys:' kvget [)^:(65536 = 3!:0@]) tosym~
raget1 =: ragetli rali ]

NB. raget2: Get items as flat concatenated array.
raget2 =: ragetli rali1 ]  NB. flat array subset of data.

NB. raget: Ambivalent get (monad: all items; dyad: selected items).
NB.   Monad creates full index range from 'lengths:' count.
NB.   Useful for converting ra back to boxed list.
raget =: (] raget1~ 'lengths:' i.@#@kvget ]) : raget1 NB. monad gets all, can be used with prefilter of lenghts/indexes to get subset.

NB. ═══════════════════════════════════════════════════════════════════════════
NB. RA FILTER OPERATIONS
NB. ═══════════════════════════════════════════════════════════════════════════

NB.rafiltu =: 1 : 'u (( I.@[ <@raget2_ra_ ]) [ <@# forkeyn_kv_ ''keys:''   <@# forkey_kv_ ''lengths:'') rabuildidx_ra_@]'
NB. rafiltu =: 1 : 'u ([ <@# forkeyn_kv_ ''keys:'' [ <@# forkeyn_kv_ ''indexes:''  <@# forkey_kv_ ''lengths:'' ) rabuildidx_ra_@]'

NB. implement filter as raget values and possible keys, then rebuild ra.  Because lenghts/indexes need rebuild for new data anyway.

NB. rafiltu1: Filter adverb. Boolean u selects items to keep.
NB.   I.@ converts boolean mask to indices of true values.
NB.   Extracts selected items and keys, rebuilds fresh ra.
NB.   NOTE: Creates new ra structure (original unchanged).
rafiltu1 =: 1 : 'u ra_ra_&>/@:(I.@[ (raget_ra_ ,&<~  [ { ''keys:'' kvget_kv_ ]) ]) ]'

NB. rafiltu2: Filter preserving disallownulls setting from original.
rafiltu2 =: rafiltu1_ra_  kvset~ 'disallownulls:' (kv_kv_ <) 'disallownulls:'kvget_kv_ ]  NB. AV(VVV)

NB. rafiltu: Standard filter adverb (uses rafiltu1).
NB.   Design decision: new ra has clean state; caller adds rules as needed.
rafiltu =: rafiltu1  NB.should be 2 instead of 1, if ra will be added to, and original dissalownull setting should rule. That is filter argument.  
	NB. but filter implementation is a new ra.  filt functions in ra and kv leave original intact.  Expecting new ra to be blank of "rules" leaves caller free to add the rules they want without relying on original.  
	NB. rafiltu2 exists and has been defined if user wants that functionality (keep disallownulls setting).  Accidentally inserting empty keys does not "fool" kv standard behaviour. (missing key = keyvalue of null as return values)

NB. rafilt: Filter by specific indices or keys.
NB.   Creates boolean mask with 1s at specified positions.
NB.   1:`[`]}... uses amend to place 1s at ramakei-resolved indices.
NB.  Filter by indexes/keys.  new ra built
rafilt =: (ramakei_ra_ 1:`[`]} 0 #~ 'lengths:' #@kvget ]) rafiltu

NB. rafiltl: Filter by length(s). Keeps items with length in x.
NB.   Useful as prefilter before string matching.
NB. filter by length(s) provided.  useful maybe as prefilter to match.
rafiltl =:  ([ e.~ 'lengths:' kvget ]) rafiltu

NB. rafiltc: Filter by cutpoint-based predicate u.
NB.   u applied to each segment via ;.1 (infix cut on cutpoints).
NB.   +./@ reduces segment result to single boolean per item.
NB.   Requires rabuildcuts and rakillnulls preprocessing (cutpoints exclude nulls).
NB. filter by u on cutpoints (each item apply u to return boolean value for item 1 = include in filter)
rafiltc =:  1 : '( (''cutpoints:''  kvget_kv_ ]) u (+./@)(;. 1) ''data:'' kvget_kv_ ])' rafiltu  (@:rabuildcuts_ra_)(@rakillnulls_ra_)
