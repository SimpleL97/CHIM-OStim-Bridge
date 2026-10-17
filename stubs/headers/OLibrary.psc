; declaration-only header for the CI build (tools/gen_headers.py) - not part of the mod
ScriptName OLibrary
string[] Function GetAllScenes() Global Native
string[] Function GetScenesInRange(string Id, Actor[] Actors, int Distance = 0) Global Native
string Function GetRandomScene(Actor[] Actors) Global Native
string Function GetRandomFurnitureScene(Actor[] Actors, string FurnitureType) Global Native
string Function GetRandomSceneWithSceneTag(Actor[] Actors, string Tag) Global Native
string Function GetRandomSceneWithAnySceneTag(Actor[] Actors, string[] Tags) Global Native
string Function GetRandomSceneWithAnySceneTagCSV(Actor[] Actors, string Tags) Global Native
string Function GetRandomSceneWithAllSceneTags(Actor[] Actors, string[] Tags) Global Native
string Function GetRandomSceneWithAllSceneTagsCSV(Actor[] Actors, string Tags) Global Native
string Function GetRandomFurnitureSceneWithSceneTag(Actor[] Actors, string FurnitureType, string Tag) Global Native
string Function GetRandomFurnitureSceneWithAnySceneTag(Actor[] Actors, string FurnitureType, string[] Tags) Global Native
string Function GetRandomFurnitureSceneWithAnySceneTagCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native
string Function GetRandomFurnitureSceneWithAllSceneTags(Actor[] Actors, string FurnitureType, string[] Tags) Global Native
string Function GetRandomFurnitureSceneWithAllSceneTagsCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native
string Function GetRandomSceneWithSingleActorTag(Actor[] Actors, int Position, string Tag) Global Native
string Function GetRandomSceneWithAnySingleActorTag(Actor[] Actors, int Position, string[] Tags) Global Native
string Function GetRandomSceneWithAnySingleActorTagCSV(Actor[] Actors, int Position, string Tags) Global Native
string Function GetRandomSceneWithAllSingleActorTags(Actor[] Actors, int Position, string[] Tags) Global Native
string Function GetRandomSceneWithAllSingleActorTagsCSV(Actor[] Actors, int Position, string Tags) Global Native
string Function GetRandomFurnitureSceneWithSingleActorTag(Actor[] Actors, string FurnitureType, int Position, string Tag) Global Native
string Function GetRandomFurnitureSceneWithAnySingleActorTag(Actor[] Actors, string FurnitureType, int Position, string[] Tags) Global Native
string Function GetRandomFurnitureSceneWithAnySingleActorTagCSV(Actor[] Actors, string FurnitureType, int Position, string Tags) Global Native
string Function GetRandomFurnitureSceneWithAllSingleActorTags(Actor[] Actors, string FurnitureType, int Position, string[] Tags) Global Native
string Function GetRandomFurnitureSceneWithAllSingleActorTagsCSV(Actor[] Actors, string FurnitureType, int Position, string Tags) Global Native
string Function GetRandomSceneWithMultiActorTagForAny(Actor[] Actors, string[] Tags) Global Native
string Function GetRandomSceneWithMultiActorTagForAnyCSV(Actor[] Actors, string Tags) Global Native
string Function GetRandomSceneWithMultiActorTagForAll(Actor[] Actors, string[] Tags) Global Native
string Function GetRandomSceneWithMultiActorTagForAllCSV(Actor[] Actors, string Tags) Global Native
string Function GetRandomSceneWithAnyMultiActorTagForAnyCSV(Actor[] Actors, string Tags) Global Native
string Function GetRandomSceneWithAnyMultiActorTagForAllCSV(Actor[] Actors, string Tags) Global Native
string Function GetRandomSceneWithAllMultiActorTagsForAnyCSV(Actor[] Actors, string Tags) Global Native
string Function GetRandomSceneWithAllMultiActorTagsForAllCSV(Actor[] Actors, string Tags) Global Native
string Function GetRandomFurnitureSceneWithMultiActorTagForAny(Actor[] Actors, string FurnitureType, string[] Tags) Global Native
string Function GetRandomFurnitureSceneWithMultiActorTagForAnyCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native
string Function GetRandomFurnitureSceneWithMultiActorTagForAll(Actor[] Actors, string FurnitureType, string[] Tags) Global Native
string Function GetRandomFurnitureSceneWithMultiActorTagForAlLCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native
string Function GetRandomFurnitureSceneWithAnyMultiActorTagForAnyCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native
string Function GetRandomFurnitureSceneWithAnyMultiActorTagForAllCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native
string Function GetRandomFurnitureSceneWithAllMultiActorTagsForAnyCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native
string Function GetRandomFurnitureSceneWithAllMultiActorTagsForAllCSV(Actor[] Actors, string FurnitureType, string Tags) Global Native
string Function GetRandomSceneWithAnySceneTagAndAnyMultiActorTagForAnyCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native
string Function GetRandomSceneWithAllSceneTagsAndAnyMultiActorTagForAnyCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native
string Function GetRandomSceneWithAnySceneTagAndAnyMultiActorTagForAllCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native
string Function GetRandomSceneWithAllSceneTagsAndAnyMultiActorTagForAllCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native
string Function GetRandomSceneWithAnySceneTagAndAllMultiActorTagsForAnyCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native
string Function GetRandomSceneWithAllSceneTagsAndAllMultiActorTagsForAnyCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native
string Function GetRandomSceneWithAnySceneTagAndAllMultiActorTagsForAllCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native
string Function GetRandomSceneWithAllSceneTagsAndAllMultiActorTagsForAllCSV(Actor[] Actors, string SceneTags, string ActorTags) Global Native
string Function GetRandomFurnitureSceneWithAnySceneTagAndAnyMultiActorTagForAnyCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native
string Function GetRandomFurnitureSceneWithAllSceneTagsAndAnyMultiActorTagForAnyCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native
string Function GetRandomFurnitureSceneWithAnySceneTagAndAnyMultiActorTagForAllCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native
string Function GetRandomFurnitureSceneWithAllSceneTagsAndAnyMultiActorTagForAllCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native
string Function GetRandomFurnitureSceneWithAnySceneTagAndAllMultiActorTagsForAnyCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native
string Function GetRandomFurnitureSceneWithAllSceneTagsAndAllMultiActorTagsForAnyCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native
string Function GetRandomFurnitureSceneWithAnySceneTagAndAllMultiActorTagsForAllCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native
string Function GetRandomFurnitureSceneWithAllSceneTagsAndAllMultiActorTagsForAllCSV(Actor[] Actors, string FurnitureType, string SceneTags, string ActorTags) Global Native
string Function GetRandomSceneWithAction(Actor[] Actors, string Type) Global Native
string Function GetRandomSceneWithAnyAction(Actor[] Actors, string[] Types) Global Native
string Function GetRandomSceneWithAnyActionCSV(Actor[] Actors, string Types) Global Native
string Function GetRandomSceneWithAllActions(Actor[] Actors, string[] Types) Global Native
string Function GetRandomSceneWithAllActionsCSV(Actor[] Actors, string Types) Global Native
string Function GetRandomFurnitureSceneWithAction(Actor[] Actors, string FurnitureType, string Type) Global Native
string Function GetRandomFurnitureSceneWithAnyAction(Actor[] Actors, string FurnitureType, string[] Types) Global Native
string Function GetRandomFurnitureSceneWithAnyActionCSV(Actor[] Actors, string FurnitureType, string Types) Global Native
string Function GetRandomFurnitureSceneWithAllActions(Actor[] Actors, string FurnitureType, string[] Types) Global Native
string Function GetRandomFurnitureSceneWithAllActionsCSV(Actor[] Actors, string FurnitureType, string Types) Global Native
string Function GetRandomSceneWithActionForActor(Actor[] Actors, int Position, string Type) Global Native
string Function GetRandomSceneWithAnyActionForActor(Actor[] Actors, int Position, string[] Types) Global Native
string Function GetRandomSceneWithAnyActionForActorCSV(Actor[] Actors, int Position, string Types) Global Native
string Function GetRandomSceneWithAllActionsForActor(Actor[] Actors, int Position, string[] Types) Global Native
string Function GetRandomSceneWithAllActionsForActorCSV(Actor[] Actors, int Position, string Types) Global Native
string Function GetRandomFurnitureSceneWithActionForActor(Actor[] Actors, string FurnitureType, int Position, string Type) Global Native
string Function GetRandomFurnitureSceneWithAnyActionForActor(Actor[] Actors, string FurnitureType, int Position, string[] Types) Global Native
string Function GetRandomFurnitureSceneWithAnyActionForActorCSV(Actor[] Actors, string FurnitureType, int Position, string Types) Global Native
string Function GetRandomFurnitureSceneWithAllActionsForActor(Actor[] Actors, string FurnitureType, int Position, string[] Types) Global Native
string Function GetRandomFurnitureSceneWithAllActionsForActorCSV(Actor[] Actors, string FurnitureType, int Position, string Types) Global Native
string Function GetRandomSceneWithActionForTarget(Actor[] Actors, int Position, string Type) Global Native
string Function GetRandomSceneWithAnyActionForTarget(Actor[] Actors, int Position, string[] Types) Global Native
string Function GetRandomSceneWithAnyActionForTargetCSV(Actor[] Actors, int Position, string Types) Global Native
string Function GetRandomSceneWithAllActionsForTarget(Actor[] Actors, int Position, string[] Types) Global Native
string Function GetRandomSceneWithAllActionsForTargetCSV(Actor[] Actors, int Position, string Types) Global Native
string Function GetRandomFurnitureSceneWithActionForTarget(Actor[] Actors, string FurnitureType, int Position, string Type) Global Native
string Function GetRandomFurnitureSceneWithAnyActionForTarget(Actor[] Actors, string FurnitureType, int Position, string[] Types) Global Native
string Function GetRandomFurnitureSceneWithAnyActionForTargetCSV(Actor[] Actors, string FurnitureType, int Position, string Types) Global Native
string Function GetRandomFurnitureSceneWithAllActionsForTarget(Actor[] Actors, string FurnitureType, int Position, string[] Types) Global Native
string Function GetRandomFurnitureSceneWithAllActionsForTargetCSV(Actor[] Actors, string FurnitureType, int Position, string Types) Global Native
string Function GetRandomSceneWithActionForActorAndTarget(Actor[] Actors, int ActorPosition, int TargetPosition, string Type) Global Native
string Function GetRandomSceneWithAnyActionForActorAndTarget(Actor[] Actors, int ActorPosition, int TargetPosition, string[] Types) Global Native
string Function GetRandomSceneWithAnyActionForActorAndTargetCSV(Actor[] Actors, int ActorPosition, int TargetPosition, string Types) Global Native
string Function GetRandomSceneWithAllActionsForActorAndTarget(Actor[] Actors, int ActorPosition, int TargetPosition, string[] Types) Global Native
string Function GetRandomSceneWithAllActionsForActorAndTargetCSV(Actor[] Actors, int ActorPosition, int TargetPosition, string Types) Global Native
string Function GetRandomFurnitureSceneWithActionForActorAndTarget(Actor[] Actors, string FurnitureType, int ActorPosition, int TargetPosition, string Type) Global Native
string Function GetRandomFurnitureSceneWithAnyActionForActorAndTarget(Actor[] Actors, string FurnitureType, int ActorPosition, int TargetPosition, string[] Types) Global Native
string Function GetRandomFurnitureSceneWithAnyActionForActorAndTargetCSV(Actor[] Actors, string FurnitureType, int ActorPosition, int TargetPosition, string Types) Global Native
string Function GetRandomFurnitureSceneWithAllActionsForActorAndTarget(Actor[] Actors, string FurnitureType, int ActorPosition, int TargetPosition, string[] Types) Global Native
string Function GetRandomFurnitureSceneWithAllActionsForActorAndTargetCSV(Actor[] Actors, string FurnitureType, int ActorPosition, int TargetPosition, string Types) Global Native
string Function GetRandomSceneSuperloadCSV(Actor[] Actors, string FurnitureType = "", string AnySceneTag = "", string AllSceneTags = "", string SceneTagWhitelist = "", string SceneTagBlacklist = "", string AnyActorTagForAny = "", string AnyActorTagForAll = "", string AllActorTagsForAny = "", string AllActorTagsForAll = "", string ActorTagWhitelistForAny = "", string ActorTagWhitelistForAll = "", string ActorTagBlacklistForAny = "", string ActorTagBlacklistForAll = "", string AnyActionType = "", string AnyActionActor = "", string AnyActionTarget = "", string AnyActionPerformer = "", string AnyActionMatesAny = "", string AnyActionMatesAll = "", string AnyActionParticipantAny = "", string AnyActionParticipantAll = "", string AllActionTypes = "", string AllActionActors = "", string AllActionTargets = "", string AllActionPerformers = "", string AllActionMatesAny = "", string AllActionMatesAll = "", string AllActionParticipantsAny = "", string AllActionParticipantsAll = "", string ActionWhitelistTypes = "", string ActionWhitelistActors = "", string ActionWhitelistTargets = "", string ActionWhitelistPerformers = "", string ActionWhitelistMatesAny = "", string ActionWhitelistMatesAll = "", string ActionWhitelistParticipantsAny = "", string ActionWhitelistParticipantsAll = "", string ActionBlacklistTypes = "", string ActionBlacklistActors = "", string ActionBlacklistTargets = "", string ActionBlacklistPerformers = "", string ActionBlacklistMatesAny = "", string ActionBlacklistMatesAll= "", string ActionBlacklistParticipantsAny = "", string ActionBlacklistParticipantsAll = "") Global Native
