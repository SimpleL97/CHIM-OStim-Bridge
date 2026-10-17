; declaration-only header for the CI build (tools/gen_headers.py) - not part of the mod
ScriptName OMetadata
string Function GetName(string Id) Global Native
string[] Function ScenesToNames(string[] Ids) Global Native
bool Function IsTransition(string Id) Global Native
int Function GetDefaultSpeed(string Id) Global Native
int Function GetMaxSpeed(string Id) Global Native
int Function GetActorCount(string Id) Global Native
string Function GetAnimationId(string Id, int Index) Global Native
bool Function HasRequirement(string Id, int Position, string Requirement) Global Native
bool Function HasAnyRequirement(string Id, int Position, string[] Requirements) Global Native
bool Function HasAnyRequirementCSV(string Id, int Position, string Requirements) Global Native
bool Function HasAllRequirements(string Id, int Position, string[] Requirements) Global Native
bool Function HasAllRequirementsCSV(string Id, int Position, string Requirements) Global Native
string Function GetAutoTransitionForActor(string Id, int Position, string Type) Global Native
string[] Function GetSceneTags(string Id) Global Native
bool Function HasSceneTag(string Id, string Tag) Global Native
bool Function HasAnySceneTag(string Id, string[] Tags) Global Native
bool Function HasAnySceneTagCSV(string Id, string Tags) Global Native
bool Function HasAllSceneTags(string Id, string[] Tags) Global Native
bool Function HasAllSceneTagsCSV(string Id, string Tags) Global Native
string[] Function GetSceneTagOverlap(string Id, string[] Tags) Global Native
string[] Function GetSceneTagOverlapCSV(string Id, string Tags) Global Native
string[] Function GetActorTags(string Id, int Position) Global Native
bool Function HasActorTag(string Id, int Position, string Tag) Global Native
bool Function HasAnyActorTag(string Id, int Position, string[] Tags) Global Native
bool Function HasAnyActorTagCSV(string Id, int Position, string Tags) Global Native
bool Function HasAllActorTags(string Id, int Position, string[] Tags) Global Native
bool Function HasAllActorTagsCSV(string Id, int Position, string Tags) Global Native
string[] Function GetActorTagOverlap(string Id, int Position, string[] Tags) Global Native
string[] Function GetActorTagOverlapCSV(string Id, int Position, string Tags) Global Native
bool Function HasActions(string Id) Global Native
int Function FindAction(string Id, string Type) Global Native
int Function FindAnyAction(string Id, string[] Types) Global Native
int Function FindAnyActionCSV(string Id, string Types) Global Native
int[] Function FindActions(string Id, string Type) Global Native
int[] Function FindAllActions(string Id, string[] Types) Global Native
int[] Function FindAllActionsCSV(string Id, string Types) Global Native
int Function FindActionForActor(string Id, int Position, string Type) Global Native
int Function FindAnyActionForActor(string Id, int Position, string[] Types) Global Native
int Function FindAnyActionForActorCSV(string Id, int Position, string Types) Global Native
int[] Function FindActionsForActor(string Id, int Position, string Type) Global Native
int[] Function FindAllActionsForActor(string Id, int Position, string[] Types) Global Native
int[] Function FindAllActionsForActorCSV(string Id, int Position, string Types) Global Native
int Function FindActionForActors(string Id, int[] Positions, string Type) Global Native
int Function FindActionForActorsCSV(string Id, string Positions, string Type) Global Native
int Function FindAnyActionForActors(string Id, int[] Positions, string[] Types) Global Native
int Function FindAnyActionForActorsCSV(string Id, string Positions, string Types) Global Native
int[] Function FindActionsForActors(string Id, int[] Positions, string Type) Global Native
int[] Function FindActionsForActorsCSV(string Id, string Positions, string Type) Global Native
int[] Function FindAllActionsForActors(string Id, int[] Positions, string[] Types) Global Native
int[] Function FindAllActionsForActorsCSV(string Id, string Positions, string Types) Global Native
int Function FindActionForTarget(string Id, int Position, string Type) Global Native
int Function FindAnyActionForTarget(string Id, int Position, string[] Types) Global Native
int Function FindAnyActionForTargetCSV(string Id, int Position, string Types) Global Native
int[] Function FindActionsForTarget(string Id, int Position, string Type) Global Native
int[] Function FindAllActionsForTarget(string Id, int Position, string[] Types) Global Native
int[] Function FindAllActionsForTargetCSV(string Id, int Position, string Types) Global Native
int Function FindActionForTargets(string Id, int[] Positions, string Type) Global Native
int Function FindActionForTargetsCSV(string Id, string Positions, string Type) Global Native
int Function FindAnyActionForTargets(string Id, int[] Positions, string[] Types) Global Native
int Function FindAnyActionForTargetsCSV(string Id, string Positions, string Types) Global Native
int[] Function FindActionsForTargets(string Id, int[] Positions, string Type) Global Native
int[] Function FindActionsForTargetsCSV(string Id, string Positions, string Type) Global Native
int[] Function FindAllActionsForTargets(string Id, int[] Positions, string[] Types) Global Native
int[] Function FindAllActionsForTargetsCSV(string Id, string Positions, string Types) Global Native
int Function FindActionForPerformer(string Id, int Position, string Type) Global Native
int Function FindAnyActionForPerformer(string Id, int Position, string[] Types) Global Native
int Function FindAnyActionForPerformerCSV(string Id, int Position, string Types) Global Native
int[] Function FindActionsForPerformer(string Id, int Position, string Type) Global Native
int[] Function FindAllActionsForPerformer(string Id, int Position, string[] Types) Global Native
int[] Function FindAllActionsForPerformerCSV(string Id, int Position, string Types) Global Native
int Function FindActionForPerformers(string Id, int[] Positions, string Type) Global Native
int Function FindActionForPerformersCSV(string Id, string Positions, string Type) Global Native
int Function FindAnyActionForPerformers(string Id, int[] Positions, string[] Types) Global Native
int Function FindAnyActionForPerformersCSV(string Id, string Positions, string Types) Global Native
int[] Function FindActionsForPerformers(string Id, int[] Positions, string Type) Global Native
int[] Function FindActionsForPerformersCSV(string Id, string Positions, string Type) Global Native
int[] Function FindAllActionsForPerformers(string Id, int[] Positions, string[] Types) Global Native
int[] Function FindAllActionsForPerformersCSV(string Id, string Positions, string Types) Global Native
int Function FindActionForActorAndTarget(string Id, int ActorPosition, int TargetPosition, string Type) Global Native
int Function FindAnyActionForActorAndTarget(string Id, int ActorPosition, int TargetPosition, string[] Types) Global Native
int Function FindAnyActionForActorAndTargetCSV(string Id, int ActorPosition, int TargetPosition, string Types) Global Native
int[] Function FindActionsForActorAndTarget(string Id, int ActorPosition, int TargetPosition, string Type) Global Native
int[] Function FindAllActionsForActorAndTarget(string Id, int ActorPosition, int TargetPosition, string[] Types) Global Native
int[] Function FindAllActionsForActorAndTargetCSV(string Id, int ActorPosition, int TargetPosition, string Types) Global Native
int Function FindActionForActorsAndTargets(string Id, int[] ActorPositions, int[] TargetPositions, string Type) Global Native
int Function FindActionForActorsAndTargetsCSV(string Id, string ActorPositions, string TargetPositions, string Type) Global Native
int Function FindAnyActionForActorsAndTargets(string Id, int[] ActorPositions, int[] TargetPositions, string[] Types) Global Native
int Function FindAnyActionForActorsAndTargetsCSV(string Id, string ActorPositions, string TargetPositions, string Types) Global Native
int[] Function FindActionsForActorsAndTargets(string Id, int[] ActorPositions, int[] TargetPositions, string Type) Global Native
int[] Function FindActionsForActorsAndTargetsCSV(string Id, string ActorPositions, string TargetPositions, string Type) Global Native
int[] Function FindAllActionsForActorsAndTargets(string Id, int[] ActorPositions, int[] TargetPositions, string[] Types) Global Native
int[] Function FindAllActionsForActorsAndTargetsCSV(string Id, string ActorPositions, string TargetPositions, string Types) Global Native
int Function FindActionForMate(string Id, int Position, string Type) Global Native
int Function FindAnyActionForMate(string Id, int Position, string[] Types) Global Native
int Function FindAnyActionForMateCSV(string Id, int Position, string Types) Global Native
int[] Function FindActionsForMate(string Id, int Position, string Type) Global Native
int[] Function FindAllActionsForMate(string Id, int Position, string[] Types) Global Native
int[] Function FindAllActionsForMateCSV(string Id, int Position, string Types) Global Native
int Function FindActionForMatesAny(string Id, int[] Positions, string Type) Global Native
int Function FindActionForMatesAnyCSV(string Id, string Positions, string Type) Global Native
int Function FindAnyActionForMatesAny(string Id, int[] Positions, string[] Types) Global Native
int Function FindAnyActionForMatesAnyCSV(string Id, string Positions, string Types) Global Native
int[] Function FindActionsForMatesAny(string Id, int[] Positions, string Type) Global Native
int[] Function FindActionsForMatesAnyCSV(string Id, string Positions, string Type) Global Native
int[] Function FindAllActionsForMatesAny(string Id, int[] Positions, string[] Types) Global Native
int[] Function FindAllActionsForMatesAnyCSV(string Id, string Positions, string Types) Global Native
int Function FindActionForMatesAll(string Id, int[] Positions, string Type) Global Native
int Function FindActionForMatesAllCSV(string Id, string Positions, string Type) Global Native
int Function FindAnyActionForMatesAll(string Id, int[] Positions, string[] Types) Global Native
int Function FindAnyActionForMatesAllCSV(string Id, string Positions, string Types) Global Native
int[] Function FindActionsForMatesAll(string Id, int[] Positions, string Type) Global Native
int[] Function FindActionsForMatesAllCSV(string Id, string Positions, string Type) Global Native
int[] Function FindAllActionsForMatesAll(string Id, int[] Positions, string[] Types) Global Native
int[] Function FindAllActionsForMatesAllCSV(string Id, string Positions, string Types) Global Native
int Function FindActionForParticipant(string Id, int Position, string Type) Global Native
int Function FindAnyActionForParticipant(string Id, int Position, string[] Types) Global Native
int Function FindAnyActionForParticipantCSV(string Id, int Position, string Types) Global Native
int[] Function FindActionsForParticipant(string Id, int Position, string Type) Global Native
int[] Function FindAllActionsForParticipant(string Id, int Position, string[] Types) Global Native
int[] Function FindAllActionsForParticipantCSV(string Id, int Position, string Types) Global Native
int Function FindActionForParticipantsAny(string Id, int[] Positions, string Type) Global Native
int Function FindActionForParticipantsAnyCSV(string Id, string Positions, string Type) Global Native
int Function FindAnyActionForParticipantsAny(string Id, int[] Positions, string[] Types) Global Native
int Function FindAnyActionForParticipantsAnyCSV(string Id, string Positions, string Types) Global Native
int[] Function FindActionsForParticipantsAny(string Id, int[] Positions, string Type) Global Native
int[] Function FindActionsForParticipantsAnyCSV(string Id, string Positions, string Type) Global Native
int[] Function FindAllActionsForParticipantsAny(string Id, int[] Positions, string[] Types) Global Native
int[] Function FindAllActionsForParticipantsAnyCSV(string Id, string Positions, string Types) Global Native
int Function FindActionForParticipantsAll(string Id, int[] Positions, string Type) Global Native
int Function FindActionForParticipantsAllCSV(string Id, string Positions, string Type) Global Native
int Function FindAnyActionForParticipantsAll(string Id, int[] Positions, string[] Types) Global Native
int Function FindAnyActionForParticipantsAllCSV(string Id, string Positions, string Types) Global Native
int[] Function FindActionsForParticipantsAll(string Id, int[] Positions, string Type) Global Native
int[] Function FindActionsForParticipantsAllCSV(string Id, string Positions, string Type) Global Native
int[] Function FindAllActionsForParticipantsAll(string Id, int[] Positions, string[] Types) Global Native
int[] Function FindAllActionsForParticipantsAllCSV(string Id, string Positions, string Types) Global Native
int Function FindActionSuperloadCSVv2(string Id, string ActorPositions = "", string TargetPositions = "", string PerformerPositions = "", string MatePositionsAny = "", string MatePositionsAll = "", string ParticipantPositionsAny = "", string ParticipantPositionsAll = "", string Types = "", string AnyActionTag = "", string AllActionTags = "", string ActionTagWhitelist = "", string ActionTagBlacklist = "", string AnyCustomIntRecord = "", string AllCustomIntRecords = "", string AnyCustomFloatRecord = "", string allCustomFloatRecords = "", string anyCustomStringRecord = "", string allCustomStringRecords = "", string AnyCustomIntListRecord = "", string AllCustomIntListRecords = "", string AnyCustomFloatListRecord = "", string AllCustomFloatListRecords = "", string AnyCustomStringListRecord = "", string AllCustomStringListRecords = "") Global Native
int[] Function FindActionsSuperloadCSVv2(string Id, string ActorPositions = "", string TargetPositions = "", string PerformerPositions = "", string MatePositionsAny = "", string MatePositionsAll = "", string ParticipantPositionsAny = "", string ParticipantPositionsAll = "", string Types = "", string AnyActionTag = "", string AllActionTags = "", string ActionTagWhitelist = "", string ActionTagBlacklist = "", string AnyCustomIntRecord = "", string AllCustomIntRecords = "", string AnyCustomFloatRecord = "", string allCustomFloatRecords = "", string anyCustomStringRecord = "", string allCustomStringRecords = "", string AnyCustomIntListRecord = "", string AllCustomIntListRecords = "", string AnyCustomFloatListRecord = "", string AllCustomFloatListRecords = "", string AnyCustomStringListRecord = "", string AllCustomStringListRecords = "") Global Native
string[] Function GetActionTypes(string Id) Global Native
string Function GetActionType(string Id, int Index) Global Native
int[] Function GetActionActors(string Id) Global Native
int Function GetActionActor(string Id, int Index) Global Native
int[] Function GetActionTargets(string Id) Global Native
int Function GetActionTarget(string Id, int Index) Global Native
int[] Function GetActionPerformers(string Id) Global Native
int Function GetActionPerformer(string Id, int Index) Global Native
string[] Function GetActionTags(string Id, int Index) Global Native
string[] Function GetAllActionsTags(string Id) Global Native
bool Function HasActionTag(string Id, int Index, string Tag) Global Native
bool Function HasActionTagOnAny(string Id, string Tag) Global Native
bool Function HasAnyActionTag(string Id, int Index, string[] Tags) Global Native
bool Function HasAnyActionTagCSV(string Id, int Index, string Tags) Global Native
bool Function HasAnyActionTagOnAny(string Id, string[] Tags) Global Native
bool Function HasAnyActionTagOnAnyCSV(string Id, string Tags) Global Native
bool Function HasAllActionTags(string Id, int Index, string[] Tags) Global Native
bool Function HasAllActionTagsCSV(string Id, int Index, string Tags) Global Native
bool Function HasAllActionTagsOnAny(string Id, string[] Tags) Global Native
bool Function HasAllActionTagsOnAnyCSV(string Id, string Tags) Global Native
bool Function HasAllActionTagsOverAll(string Id, string[] Tags) Global Native
bool Function HasAllActionTagsOverAllCSV(string Id, string Tags) Global Native
string[] Function GetActionTagOverlap(string Id, int Index, string[] Tags) Global Native
string[] Function GetActionTagOverlapCSV(string Id, int Index, string Tags) Global Native
string[] Function GetActionTagOverlapOverAll(string Id, string[] Tags) Global Native
string[] Function GetActionTagOverlapOverAllCSV(string Id, string Tags) Global Native
bool Function HasCustomActionActorInt(string Id, int Index, string Record) Global Native
int Function GetCustomActionActorInt(string Id, int Index, string Record, int Fallback = 0) Global Native
bool Function IsCustomActionActorInt(string Id, int Index, string Record, int Value) Global Native
bool Function HasCustomActionActorFloat(string Id, int Index, string Record) Global Native
float Function GetCustomActionActorFloat(string Id, int Index, string Record, float Fallback = 0.0) Global Native
bool Function IsCustomActionActorFloat(string Id, int Index, string Record, float Value) Global Native
bool Function HasCustomActionActorString(string Id, int Index, string Record) Global Native
string Function GetCustomActionActorString(string Id, int Index, string Record, string Fallback = "") Global Native
bool Function IsCustomActionActorString(string Id, int Index, string Record, string Value) Global Native
bool Function HasCustomActionActorIntList(string Id, int Index, string Record) Global Native
int[] Function GetCustomActionActorIntList(string Id, int Index, string Record) Global Native
bool Function CustomActionActorIntListContains(string Id, int Index, string Record, int Value) Global Native
bool Function CustomActionActorIntListContainsAny(string Id, int Index, string Record, int[] Values) Global Native
bool Function CustomActionActorIntListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native
bool Function CustomActionActorIntListContainsAll(string Id, int Index, string Record, int[] Values) Global Native
bool Function CustomActionActorIntListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native
int[] Function GetCustomActionActorIntListOverlap(string Id, int Index, string Record, int[] Values) Global Native
int[] Function GetCustomActionActorIntListOverlapCSV(string Id, int Index, string Record, string Values) Global Native
bool Function HasCustomActionActorFloatList(string Id, int Index, string Record) Global Native
float[] Function GetCustomActionActorFloatList(string Id, int Index, string Record) Global Native
bool Function CustomActionActorFloatListContains(string Id, int Index, string Record, float Value) Global Native
bool Function CustomActionActorFloatListContainsAny(string Id, int Index, string Record, float[] Values) Global Native
bool Function CustomActionActorFloatListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native
bool Function CustomActionActorFloatListContainsAll(string Id, int Index, string Record, float[] Values) Global Native
bool Function CustomActionActorFloatListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native
float[] Function GetCustomActionActorFloatListOverlap(string Id, int Index, string Record, float[] Values) Global Native
float[] Function GetCustomActionActorFloatListOverlapCSV(string Id, int Index, string Record, string Values) Global Native
bool Function HasCustomActionActorStringList(string Id, int Index, string Record) Global Native
string[] Function GetCustomActionActorStringList(string Id, int Index, string Record) Global Native
bool Function CustomActionActorStringListContains(string Id, int Index, string Record, string Value) Global Native
bool Function CustomActionActorStringListContainsAny(string Id, int Index, string Record, string[] Values) Global Native
bool Function CustomActionActorStringListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native
bool Function CustomActionActorStringListContainsAll(string Id, int Index, string Record, string[] Values) Global Native
bool Function CustomActionActorStringListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native
string[] Function GetCustomActionActorStringListOverlap(string Id, int Index, string Record, string[] Values) Global Native
string[] Function GetCustomActionActorStringListOverlapCSV(string Id, int Index, string Record, string Values) Global Native
bool Function HasCustomActionTargetInt(string Id, int Index, string Record) Global Native
int Function GetCustomActionTargetInt(string Id, int Index, string Record, int Fallback = 0) Global Native
bool Function IsCustomActionTargetInt(string Id, int Index, string Record, int Value) Global Native
bool Function HasCustomActionTargetFloat(string Id, int Index, string Record) Global Native
float Function GetCustomActionTargetFloat(string Id, int Index, string Record, float Fallback = 0.0) Global Native
bool Function IsCustomActionTargetFloat(string Id, int Index, string Record, float Value) Global Native
bool Function HasCustomActionTargetString(string Id, int Index, string Record) Global Native
string Function GetCustomActionTargetString(string Id, int Index, string Record, string Fallback = "") Global Native
bool Function IsCustomActionTargetString(string Id, int Index, string Record, string Value) Global Native
bool Function HasCustomActionTargetIntList(string Id, int Index, string Record) Global Native
int[] Function GetCustomActionTargetIntList(string Id, int Index, string Record) Global Native
bool Function CustomActionTargetIntListContains(string Id, int Index, string Record, int Value) Global Native
bool Function CustomActionTargetIntListContainsAny(string Id, int Index, string Record, int[] Values) Global Native
bool Function CustomActionTargetIntListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native
bool Function CustomActionTargetIntListContainsAll(string Id, int Index, string Record, int[] Values) Global Native
bool Function CustomActionTargetIntListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native
int[] Function GetCustomActionTargetIntListOverlap(string Id, int Index, string Record, int[] Values) Global Native
int[] Function GetCustomActionTargetIntListOverlapCSV(string Id, int Index, string Record, string Values) Global Native
bool Function HasCustomActionTargetFloatList(string Id, int Index, string Record) Global Native
float[] Function GetCustomActionTargetFloatList(string Id, int Index, string Record) Global Native
bool Function CustomActionTargetFloatListContains(string Id, int Index, string Record, float Value) Global Native
bool Function CustomActionTargetFloatListContainsAny(string Id, int Index, string Record, float[] Values) Global Native
bool Function CustomActionTargetFloatListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native
bool Function CustomActionTargetFloatListContainsAll(string Id, int Index, string Record, float[] Values) Global Native
bool Function CustomActionTargetFloatListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native
float[] Function GetCustomActionTargetFloatListOverlap(string Id, int Index, string Record, float[] Values) Global Native
float[] Function GetCustomActionTargetFloatListOverlapCSV(string Id, int Index, string Record, string Values) Global Native
bool Function HasCustomActionTargetStringList(string Id, int Index, string Record) Global Native
string[] Function GetCustomActionTargetStringList(string Id, int Index, string Record) Global Native
bool Function CustomActionTargetStringListContains(string Id, int Index, string Record, string Value) Global Native
bool Function CustomActionTargetStringListContainsAny(string Id, int Index, string Record, string[] Values) Global Native
bool Function CustomActionTargetStringListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native
bool Function CustomActionTargetStringListContainsAll(string Id, int Index, string Record, string[] Values) Global Native
bool Function CustomActionTargetStringListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native
string[] Function GetCustomActionTargetStringListOverlap(string Id, int Index, string Record, string[] Values) Global Native
string[] Function GetCustomActionTargetStringListOverlapCSV(string Id, int Index, string Record, string Values) Global Native
bool Function HasCustomActionPerformerInt(string Id, int Index, string Record) Global Native
int Function GetCustomActionPerformerInt(string Id, int Index, string Record, int Fallback = 0) Global Native
bool Function IsCustomActionPerformerInt(string Id, int Index, string Record, int Value) Global Native
bool Function HasCustomActionPerformerFloat(string Id, int Index, string Record) Global Native
float Function GetCustomActionPerformerFloat(string Id, int Index, string Record, float Fallback = 0.0) Global Native
bool Function IsCustomActionPerformerFloat(string Id, int Index, string Record, float Value) Global Native
bool Function HasCustomActionPerformerString(string Id, int Index, string Record) Global Native
string Function GetCustomActionPerformerString(string Id, int Index, string Record, string Fallback = "") Global Native
bool Function IsCustomActionPerformerString(string Id, int Index, string Record, string Value) Global Native
bool Function HasCustomActionPerformerIntList(string Id, int Index, string Record) Global Native
int[] Function GetCustomActionPerformerIntList(string Id, int Index, string Record) Global Native
bool Function CustomActionPerformerIntListContains(string Id, int Index, string Record, int Value) Global Native
bool Function CustomActionPerformerIntListContainsAny(string Id, int Index, string Record, int[] Values) Global Native
bool Function CustomActionPerformerIntListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native
bool Function CustomActionPerformerIntListContainsAll(string Id, int Index, string Record, int[] Values) Global Native
bool Function CustomActionPerformerIntListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native
int[] Function GetCustomActionPerformerIntListOverlap(string Id, int Index, string Record, int[] Values) Global Native
int[] Function GetCustomActionPerformerIntListOverlapCSV(string Id, int Index, string Record, string Values) Global Native
bool Function HasCustomActionPerformerFloatList(string Id, int Index, string Record) Global Native
float[] Function GetCustomActionPerformerFloatList(string Id, int Index, string Record) Global Native
bool Function CustomActionPerformerFloatListContains(string Id, int Index, string Record, float Value) Global Native
bool Function CustomActionPerformerFloatListContainsAny(string Id, int Index, string Record, float[] Values) Global Native
bool Function CustomActionPerformerFloatListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native
bool Function CustomActionPerformerFloatListContainsAll(string Id, int Index, string Record, float[] Values) Global Native
bool Function CustomActionPerformerFloatListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native
float[] Function GetCustomActionPerformerFloatListOverlap(string Id, int Index, string Record, float[] Values) Global Native
float[] Function GetCustomActionPerformerFloatListOverlapCSV(string Id, int Index, string Record, string Values) Global Native
bool Function HasCustomActionPerformerStringList(string Id, int Index, string Record) Global Native
string[] Function GetCustomActionPerformerStringList(string Id, int Index, string Record) Global Native
bool Function CustomActionPerformerStringListContains(string Id, int Index, string Record, string Value) Global Native
bool Function CustomActionPerformerStringListContainsAny(string Id, int Index, string Record, string[] Values) Global Native
bool Function CustomActionPerformerStringListContainsAnyCSV(string Id, int Index, string Record, string Values) Global Native
bool Function CustomActionPerformerStringListContainsAll(string Id, int Index, string Record, string[] Values) Global Native
bool Function CustomActionPerformerStringListContainsAllCSV(string Id, int Index, string Record, string Values) Global Native
string[] Function GetCustomActionPerformerStringListOverlap(string Id, int Index, string Record, string[] Values) Global Native
string[] Function GetCustomActionPerformerStringListOverlapCSV(string Id, int Index, string Record, string Values) Global Native
int Function GetCustomSceneActorIntMin(string Id, int Position, string Record, int Fallback = 0) Global Native
int Function GetCustomSceneActorIntMax(string Id, int Position, string Record, int Fallback = 0) Global Native
int Function GetCustomSceneActorIntSum(string Id, int Position, string Record, int StartValue = 0) Global Native
int Function GetCustomSceneActorIntProduct(string Id, int Position, string Record, int StartValue = 1) Global Native
float Function GetCustomSceneActorFloatMin(string Id, int Position, string Record, float Fallback = 0.0) Global Native
float Function GetCustomSceneActorFloatMax(string Id, int Position, string Record, float Fallback = 0.0) Global Native
float Function GetCustomSceneActorFloatSum(string Id, int Position, string Record, float StartValue = 0.0) Global Native
float Function GetCustomSceneActorFloatProduct(string Id, int Position, string Record, float StartValue = 1.0) Global Native
int Function FindActionSuperloadCSV(string Id, string ActorPositions = "", string TargetPositions = "", string PerformerPositions = "", string MatePositionsAny = "", string MatePositionsAll = "", string ParticipantPositionsAny = "", string ParticipantPositionsAll = "", string Types = "")
EndFunction
int[] Function FindActionsSuperloadCSV(string Id, string ActorPositions = "", string TargetPositions = "", string PerformerPositions = "", string MatePositionsAny = "", string MatePositionsAll = "", string ParticipantPositionsAny = "", string ParticipantPositionsAll = "", string Types = "")
EndFunction
