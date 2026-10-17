; declaration-only header for the CI build (tools/gen_headers.py) - not part of the mod
scriptname PapyrusUtil Hidden
int Function GetVersion() Global Native
int Function GetScriptVersion() Global
EndFunction
Actor[] Function ActorArray(int size, Actor filler = none) Global Native
Actor[] Function ResizeActorArray(Actor[] ArrayValues, int toSize, Actor filler = none) Global Native
ObjectReference[] Function ObjRefArray(int size, ObjectReference filler = none) Global Native
ObjectReference[] Function ResizeObjRefArray(ObjectReference[] ArrayValues, int toSize, ObjectReference filler = none) Global Native
float[] Function PushFloat(float[] ArrayValues, float push) Global Native
int[] Function PushInt(int[] ArrayValues, int push) Global Native
string[] Function PushString(string[] ArrayValues, string push) Global Native
Form[] Function PushForm(Form[] ArrayValues, Form push) Global Native
Alias[] Function PushAlias(Alias[] ArrayValues, Alias push) Global Native
Actor[] Function PushActor(Actor[] ArrayValues, Actor push) Global Native
ObjectReference[] Function PushObjRef(ObjectReference[] ArrayValues, ObjectReference push) Global Native
float[] Function RemoveFloat(float[] ArrayValues, float ToRemove) Global Native
int[] Function RemoveInt(int[] ArrayValues, int ToRemove) Global Native
string[] Function RemoveString(string[] ArrayValues, string ToRemove) Global Native
Form[] Function RemoveForm(Form[] ArrayValues, Form ToRemove) Global Native
Alias[] Function RemoveAlias(Alias[] ArrayValues, Alias ToRemove) Global Native
Actor[] Function RemoveActor(Actor[] ArrayValues, Actor ToRemove) Global Native
ObjectReference[] Function RemoveObjRef(ObjectReference[] ArrayValues, ObjectReference ToRemove) Global Native
float[] Function RemoveDupeFloat(float[] ArrayValues) Global Native
int[] Function RemoveDupeInt(int[] ArrayValues) Global Native
string[] Function RemoveDupeString(string[] ArrayValues) Global Native
Form[] Function RemoveDupeForm(Form[] ArrayValues) Global Native
Alias[] Function RemoveDupeAlias(Alias[] ArrayValues) Global Native
Actor[] Function RemoveDupeActor(Actor[] ArrayValues) Global Native
ObjectReference[] Function RemoveDupeObjRef(ObjectReference[] ArrayValues) Global Native
float[] Function GetDiffFloat(float[] ArrayValues1, float[] ArrayValues2, bool CompareBoth = false, bool IncludeDupes = false) Global Native
int[] Function GetDiffInt(int[] ArrayValues1, int[] ArrayValues2, bool CompareBoth = false, bool IncludeDupes = false) Global Native
string[] Function GetDiffString(string[] ArrayValues1, string[] ArrayValues2, bool CompareBoth = false, bool IncludeDupes = false) Global Native
Form[] Function GetDiffForm(Form[] ArrayValues1, Form[] ArrayValues2, bool CompareBoth = false, bool IncludeDupes = false) Global Native
Alias[] Function GetDiffAlias(Alias[] ArrayValues1, Alias[] ArrayValues2, bool CompareBoth = false, bool IncludeDupes = false) Global Native
Actor[] Function GetDiffActor(Actor[] ArrayValues1, Actor[] ArrayValues2, bool CompareBoth = false, bool IncludeDupes = false) Global Native
ObjectReference[] Function GetDiffObjRef(ObjectReference[] ArrayValues1, ObjectReference[] ArrayValues2, bool CompareBoth = false, bool IncludeDupes = false) Global Native
float[] Function GetMatchingFloat(float[] ArrayValues1, float[] ArrayValues2) Global Native
int[] Function GetMatchingInt(int[] ArrayValues1, int[] ArrayValues2) Global Native
string[] Function GetMatchingString(string[] ArrayValues1, string[] ArrayValues2) Global Native
Form[] Function GetMatchingForm(Form[] ArrayValues1, Form[] ArrayValues2) Global Native
Alias[] Function GetMatchingAlias(Alias[] ArrayValues1, Alias[] ArrayValues2) Global Native
Actor[] Function GetMatchingActor(Actor[] ArrayValues1, Actor[] ArrayValues2) Global Native
ObjectReference[] Function GetMatchingObjRef(ObjectReference[] ArrayValues1, ObjectReference[] ArrayValues2) Global Native
int Function CountFloat(float[] ArrayValues, float EqualTo) Global Native
int Function CountInt(int[] ArrayValues, int EqualTo) Global Native
int Function CountBool(bool[] ArrayValues, bool EqualTo) Global Native
int Function CountString(string[] ArrayValues, string EqualTo) Global Native
int Function CountForm(Form[] ArrayValues, Form EqualTo) Global Native
int Function CountAlias(Alias[] ArrayValues, Alias EqualTo) Global Native
int Function CountActor(Actor[] ArrayValues, Actor EqualTo) Global Native
int Function CountObjRef(ObjectReference[] ArrayValues, ObjectReference EqualTo) Global Native
float[] Function MergeFloatArray(float[] ArrayValues1, float[] ArrayValues2, bool RemoveDupes = false) Global Native
int[] Function MergeIntArray(int[] ArrayValues1, int[] ArrayValues2, bool RemoveDupes = false) Global Native
string[] Function MergeStringArray(string[] ArrayValues1, string[] ArrayValues2, bool RemoveDupes = false) Global Native
Form[] Function MergeFormArray(Form[] ArrayValues1, Form[] ArrayValues2, bool RemoveDupes = false) Global Native
Alias[] Function MergeAliasArray(Alias[] ArrayValues1, Alias[] ArrayValues2, bool RemoveDupes = false) Global Native
Actor[] Function MergeActorArray(Actor[] ArrayValues1, Actor[] ArrayValues2, bool RemoveDupes = false) Global Native
ObjectReference[] Function MergeObjRefArray(ObjectReference[] ArrayValues1, ObjectReference[] ArrayValues2, bool RemoveDupes = false) Global Native
float[] Function SliceFloatArray(float[] ArrayValues, int StartIndex, int EndIndex = -1) Global Native
int[] Function SliceIntArray(int[] ArrayValues, int StartIndex, int EndIndex = -1) Global Native
string[] Function SliceStringArray(string[] ArrayValues, int StartIndex, int EndIndex = -1) Global Native
Form[] Function SliceFormArray(Form[] ArrayValues, int StartIndex, int EndIndex = -1) Global Native
Alias[] Function SliceAliasArray(Alias[] ArrayValues, int StartIndex, int EndIndex = -1) Global Native
Actor[] Function SliceActorArray(Actor[] ArrayValues, int StartIndex, int EndIndex = -1) Global Native
ObjectReference[] Function SliceObjRefArray(ObjectReference[] ArrayValues, int StartIndex, int EndIndex = -1) Global Native
Function SortIntArray(int[] ArrayValues, bool descending = false) Global Native
Function SortFloatArray(float[] ArrayValues, bool descending = false) Global Native
Function SortStringArray(string[] ArrayValues, bool descending = false) Global Native
string[] Function ClearEmpty(string[] ArrayValues) Global
EndFunction
Form[] Function ClearNone(Form[] ArrayValues) Global
EndFunction
int Function CountFalse(bool[] ArrayValues) Global
EndFunction
int Function CountTrue(bool[] ArrayValues) Global
EndFunction
int Function CountNone(Form[] ArrayValues) Global
EndFunction
string[] Function StringSplit(string ArgString, string Delimiter = ",") Global Native
string Function StringJoin(string[] Values, string Delimiter = ",") Global Native
int Function AddIntValues(int[] Values) Global Native
float Function AddFloatValues(float[] Values) Global Native
int Function ClampInt(int value, int min, int max) Global Native
float Function ClampFloat(float value, float min, float max) Global Native
int Function WrapInt(int value, int end, int start = 0) Global Native
float Function WrapFloat(float value, float end, float start = 0.0) Global Native
int Function SignInt(bool doSign, int value) Global Native
float Function SignFloat(bool doSign, float value) Global Native
bool[] Function ResizeBoolArray(bool[] ArrayValues, int toSize, bool filler = false) Global
EndFunction
bool[] Function PushBool(bool[] ArrayValues, bool push) Global
EndFunction
bool[] Function RemoveBool(bool[] ArrayValues, bool ToRemove) Global
EndFunction
bool[] Function MergeBoolArray(bool[] ArrayValues1, bool[] ArrayValues2, bool RemoveDupes = false) Global
EndFunction
bool[] Function SliceBoolArray(bool[] ArrayValues, int StartIndex, int EndIndex = -1) Global
EndFunction
float[] Function FloatArray(int size, float filler = 0.0) Global
EndFunction
int[] Function IntArray(int size, int filler = 0) Global
EndFunction
bool[] Function BoolArray(int size, bool filler = false) Global
EndFunction
string[] Function StringArray(int size, string filler = "") Global
EndFunction
Form[] Function FormArray(int size, Form filler = none) Global
EndFunction
Alias[] Function AliasArray(int size, Alias filler = none) Global
EndFunction
float[] Function ResizeFloatArray(float[] ArrayValues, int toSize, float filler = 0.0) Global
EndFunction
int[] Function ResizeIntArray(int[] ArrayValues, int toSize, int filler = 0) Global
EndFunction
string[] Function ResizeStringArray(string[] ArrayValues, int toSize, string filler = "") Global
EndFunction
Form[] Function ResizeFormArray(Form[] ArrayValues, int toSize, Form filler = none) Global
EndFunction
Alias[] Function ResizeAliasArray(Alias[] ArrayValues, int toSize, Alias filler = none) Global
EndFunction
