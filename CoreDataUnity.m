//
//  ChatUnity.m
//  BaiYing
//
//  Created by Yang David on 9/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreDataUnity.h"
#import "AppDelegate.h"

#define modelKey @"BaiYing"

@class BYManagedObject;


@implementation CoreDataUnity

+(NSString*)modelName{
    
    return modelKey;
}

+(NSManagedObjectContext*)getContextForCurrentThread{
   
    return [[self managedObjectContextManager]managedObjectContextForCurrentThread];
   // return [[self getGloableAppDelegate] managedObjectContext];
}

+(BYManagedObjectContextManager*)managedObjectContextManager{
    
    return [BYManagedObjectContextManager sharedInstanceWithModelName:[self modelName]];
}

+(AppDelegate*)getGloableAppDelegate{
    
    AppDelegate * app=[[UIApplication sharedApplication]delegate];
    return app;
}

+(id)getInsertEntity:(NSString*)entity{
    
    return [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:[self getContextForCurrentThread]];
    
}

+(bool)saveEntity{
    
    [[self managedObjectContextManager]commit];
    return true;
    /*
    NSError * error;
    if (![[self getContext] save:&error]) {
        NSLog(@"save chat event error:%@",error);
        return false;
    }*/
    return true;

}


+(void)deleteManagedObject:(NSManagedObject*)entity{
    
    [[self getContextForCurrentThread]deleteObject:entity];
}

+(void)delete:(NSManagedObjectContext*)context{
    
    [context delete:self];
}

+(void)deletEntityLists:(NSString*)entity withQueryText:(NSString*)queryText{
    
    NSArray * list =[self getFetchEntityLists:entity withQueryText:queryText];
    
    //[list makeObjectsPerformSelector:@selector(delete:) withObject:[self getContextForCurrentThread]];
    for (NSManagedObject * obj in list) {
        [self deleteManagedObject:obj];
    }
}


+(NSFetchRequest*)getFetchEntity:(NSString*)entity{
    
    NSFetchRequest * request =[[[NSFetchRequest alloc]init]autorelease];
    
    NSEntityDescription * entityDes =[NSEntityDescription entityForName:entity inManagedObjectContext:[self getContextForCurrentThread]];
    
    [request setEntity:entityDes];
    
    return request;
    
    
    
}
//----------通过查询条件获取实体列表-------------
+(NSArray*)getFetchEntityLists:(NSString*)entity withQueryText:(NSString*)queryText{
    
    NSFetchRequest * request = [self getFetchEntity:entity];
    [self configPredicate:request withQuery:queryText];
    NSArray * list =[self executeTetch:request];
    return list;
}

//----------通过查询条件获取实体列表-------------
+(NSArray*)getFetchEntityLists:(NSString*)entity withQueryText:(NSString*)queryText withSortKey:(NSString*)key withSortValue:(BOOL)value withIndex:(long)IndexOffset withPageSize:(long)pageSize{
    
   
    NSFetchRequest * request = [self getFetchEntity:entity];
    
    if (queryText!=nil) {
        
        [self configPredicate:request withQuery:queryText];
    }
    
    
    [self configRequestSorted:request withSortKey:key withSortValue:value];
       
    [self configRequestFetchArgs:request withIndex:IndexOffset withPageSize:pageSize];
    
    return [self executeTetch:request];
    
}

+(NSArray*)executeTetch:(NSFetchRequest*)request{
    
    NSError * error;
    NSArray * list =[[self getContextForCurrentThread]executeFetchRequest:request error:&error];
    return list!=nil?list:nil;
}


+(void)configPredicate:(NSFetchRequest*)request withQuery:(NSString*)query{

    NSPredicate * pred =[NSPredicate predicateWithFormat:query];
    [request setPredicate:pred];
}

+(void)configRequestFetchArgs:(NSFetchRequest*)request withIndex:(long)IndexOffset withPageSize:(long)pageSize{
    
    [request setFetchLimit:pageSize];
    [request setFetchOffset:IndexOffset * pageSize];
}

+(void)configRequestSorted:(NSFetchRequest*)request withSortKey:(NSString*)key withSortValue:(BOOL)value{
    
     NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:value];
     NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptor release];
    [sortDescriptors release];

}

+(NSArray*)getFetchEntityLists:(NSString *)entity withQueryText:(NSString *)queryText
                   withSortKey:(NSString *)key withSortValue:(BOOL)value{
    
    NSFetchRequest * request = [self getFetchEntity:entity];
    
    [self configPredicate:request withQuery:queryText];
    
    [self configRequestSorted:request withSortKey:key withSortValue:value];
    
    return [self executeTetch:request];
    
}

@end


@implementation BYManagedObject

/**
 * 实体名称
 */
+(NSString*)entityName{
    
    NSLog(@"You must implement an entityName class method in your entity subclass. or Aborting.");
    abort();
}

/**
 * coredata名称 (.xcdatamodeld)
 */
+(NSString*)modelName{
    
    NSLog(@"You must implement a modelName class method in your entity subclass.  or Aborting.");
	abort();
}

+(void)deleteStore{
    
    [[self managedObjectContextManager]deleteStore];
}

+(NSEntityDescription*)entityDescription{
    
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:[self managedObjectContextForCurrentThread]];
}

+(void)commit{
    [[self managedObjectContextManager]commit];
}

+(id)newEntity{
    
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:[self managedObjectContextForCurrentThread]];
}

+(id)getWithPredicate:(NSPredicate *)predicate{
   
    NSArray * results = [self fetchWithPredicate:predicate];
    
    if (results.count>0) {
        return [results objectAtIndex:0];
    }
    return nil;
}

+(id)getWithPredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)descriptor{
    
    NSArray * results = [self fetchWithPredicate:predicate sortDescriptor:descriptor];
    if (results.count>0) {
        return  [results objectAtIndex:0];
    }
    return nil;
}


+(NSArray*)fectchAll{
    
    return [self fetchWithPredicate:nil];
}

+(NSArray*)fetchWithPredicate:(NSPredicate *)predicate{
    
    return [self fetchWithPredicate:predicate sortDescriptor:nil];
}

+(NSArray*)fetchWithPredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)descriptor{
    
    return [self fetchWithPredicate:predicate sortDescriptor:descriptor
                          withLimit:0];
}

+(NSArray*)fetchWithPredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)descriptor withLimit:(NSUInteger)limit{
    
    NSFetchRequest * fetch =[[[NSFetchRequest alloc]init]autorelease];
    
    if (predicate) {
        [fetch setPredicate:predicate];
    }
    
    if (descriptor) {
        [fetch setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    }
    if (limit>0) {
        [fetch setFetchLimit:limit];
    }
    
    
    return [[self managedObjectContextForCurrentThread] executeFetchRequest:fetch error:nil];
}

+(NSUInteger)count{
    return [self countWithPredicate:nil];
}

+(NSUInteger)countWithPredicate:(NSPredicate *)predicate{
    
    NSFetchRequest * fetch =[[[NSFetchRequest alloc]init]autorelease];
    [fetch setEntity:[self entityDescription]];
    
    if (predicate) {
        [fetch setPredicate:predicate];
    }
    
    return [[self managedObjectContextForCurrentThread] countForFetchRequest:fetch error:nil];
}
+(NSArray*)distinctValuesWithAttribute:(NSString *)attribute predicate:(NSPredicate *)predicate{
    
    NSArray * items =[self fetchWithPredicate:predicate];
    
    NSString * keyPath =[kDistinctUnionKey stringByAppendingString:attribute];
    return [[items valueForKey:keyPath] sortedArrayUsingSelector:@selector(compare:)];
    
}

+(NSString*)collectionToString:(ByCollection)collection{
    
    switch(collection) {
        case BYCollectionMax:
            return @"max:";
        case ByCollectionMin:
            return @"min:";
		case ByCollectionAverage:
            return @"average:";
		case ByCollectionSum:
			return @"sum:";
        default:
            [NSException raise:NSGenericException format:@"Unexpected FormatType."];
    }

}

+(NSAttributeType)attributeTypeWithKey:(NSString *)key{
    
    NSEntityDescription * entity =[self entityDescription];
    
    NSDictionary * properties =[entity propertiesByName];
    
    NSAttributeDescription * attribute =[properties objectForKey:key];
    
    return [attribute attributeType];
}

+(id)collectionWithType:(ByCollection)collection key:(NSString *)key predicate:(NSPredicate *)predicate defaultValue:(id)defaultValue{
    
    NSFetchRequest * fetch =[[[NSFetchRequest alloc]init]autorelease];
    
    if (predicate) {
        [fetch setPredicate:predicate];
    }
    
    NSString * collectionString =[self  collectionToString:collection];
    
    NSAttributeType attributeType =[self attributeTypeWithKey:key];
    
    NSEntityDescription * entity =[self entityDescription];
    
    [fetch setEntity:entity];
    
    [fetch setResultType:NSDictionaryResultType];
    
    NSExpression * keyPathExpression =[NSExpression expressionForKeyPath:key];
    NSExpression * expression = [NSExpression expressionForFunction:collectionString arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription * expressionDescri =[[[NSExpressionDescription alloc]init] autorelease];
    [expressionDescri setName:key];
    [expressionDescri setExpression:expression];
    [expressionDescri setExpressionResultType:attributeType];
    
    [fetch setPropertiesToFetch:[NSArray arrayWithObject:expressionDescri]];
    
    NSError * error;
    NSArray * objects =[[self managedObjectContextForCurrentThread] executeFetchRequest:fetch error:&error];
    
    id returnValue = nil;
	if ((objects != nil) && ([objects count] > 0) ) {
		returnValue = [[objects lastObject] valueForKey:key];
	}
	
	if (returnValue == nil) {
		returnValue = defaultValue;
	}
	
	
	return returnValue;
    
}

+(void)deletaAll{
    [self deleteWithPredicate:nil];
}

+(NSUInteger)deleteWithPredicate:(NSPredicate *)predicate{
    
    NSArray * itemsToDelete = [self fetchWithPredicate:predicate];
    [itemsToDelete makeObjectsPerformSelector:@selector(delete)];
    return [itemsToDelete count];
    
}

+(NSManagedObjectContext*)managedObjectContextForCurrentThread{
    
    return [[self managedObjectContextManager] managedObjectContextForCurrentThread];
}

+(BYManagedObjectContextManager*)managedObjectContextManager{
   
    return [BYManagedObjectContextManager sharedInstanceWithModelName:[self modelName]];
}

+(BOOL)doesRequireMigration{
    return [[self managedObjectContextManager]doesRequireMigration];
}

-(void)delete{
    
    [[self managedObjectContext] delete:self];
    
}
-(id)clone{
    
    NSEntityDescription *entityDescription = [self entity];
	NSString *entityName = [entityDescription name];
	NSManagedObject *cloned = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self managedObjectContext]];
	
    for (NSString *attr in [entityDescription attributesByName]) {
        [cloned setValue:[self valueForKey:attr] forKey:attr];
    }
	
    return cloned;

}

-(id)objectInCurrentThreadContext{
    
    NSManagedObjectContext * currentMoc =[[self class] performSelector:@selector(managedObjectContextForCurrentThread)];
    return [currentMoc objectWithID:self.objectID];
    
}

-(NSDictionary*)serialize{
   
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	for (NSString *key in [[self entity] attributesByName]) {
		id value = [self valueForKey:key];
		
		if (value != nil) {
			[dict setObject:value forKey:key];
		}
	}
	return dict;
}

@end



@interface BYManagedObjectContextManager()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContextForMainThread;

@property (nonatomic, retain) NSMutableDictionary *managedObjectContexts;

@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) NSString *modelName;

+(NSMutableDictionary *)sharedInstances;

-(void)discardManagedObjectContext;

-(NSString *)storePath;

-(NSURL *)storeURL;

-(NSString *)databaseName;

-(void)mocDidSave:(NSNotification *)saveNotification;

@end

@implementation BYManagedObjectContextManager

@synthesize managedObjectContextForMainThread;
@synthesize managedObjectContexts;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;
@synthesize modelName;

-(void)dealloc{
    [self setManagedObjectContextForMainThread:nil];
    [self setManagedObjectContexts:nil];
    [self setManagedObjectModel:nil];
    [self setPersistentStoreCoordinator:nil];
    [self setModelName:nil];
    [super dealloc];
}


+(BYManagedObjectContextManager *)sharedInstanceWithModelName:(NSString *)modelName {
    if ([[self sharedInstances] objectForKey:modelName] == nil) {
        BYManagedObjectContextManager *contextManager = [[[BYManagedObjectContextManager alloc] initWithModelName:modelName]autorelease];
        [[self sharedInstances] setObject:contextManager forKey:modelName];
    }
	
    return [[self sharedInstances] objectForKey:modelName];
}

+(NSMutableDictionary *)sharedInstances {
    static dispatch_once_t once;
    static NSMutableDictionary *sharedInstances;
    dispatch_once(&once, ^ {
        sharedInstances = [[NSMutableDictionary alloc] init];
    });
    return sharedInstances;
}


-(id)initWithModelName:(NSString *)_modelName {
    if (self=[super init]) {
        self.modelName = _modelName;
    }
    return self;
}

-(NSMutableDictionary *)managedObjectContexts {
	if (managedObjectContexts == nil) {
		self.managedObjectContexts = [NSMutableDictionary dictionary];
	}
	return managedObjectContexts;
}

// flush and reset the database.
-(void)deleteStore {
    
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	
	if (persistentStoreCoordinator == nil) {
		NSString *storePath = [self storePath];
		
		if ([fm fileExistsAtPath:storePath] && [fm isDeletableFileAtPath:storePath]) {
			[fm removeItemAtPath:storePath error:&error];
		}
		
	} else {
		NSPersistentStoreCoordinator *storeCoordinator = [self persistentStoreCoordinator];
		
		for (NSPersistentStore *store in [storeCoordinator persistentStores]) {
			NSURL *storeURL = store.URL;
			NSString *storePath = storeURL.path;
			[storeCoordinator removePersistentStore:store error:&error];
			
			if ([fm fileExistsAtPath:storePath] && [fm isDeletableFileAtPath:storePath]) {
				[fm removeItemAtPath:storePath error:&error];
			}
		}
	}
	
	self.managedObjectContextForMainThread = nil;
	self.managedObjectContexts = nil;
	self.managedObjectModel = nil;
	self.persistentStoreCoordinator = nil;
	
	[[BYManagedObjectContextManager sharedInstances] removeObjectForKey:[self modelName]];
}

-(NSUInteger)pendingChangesCount {
    
	NSManagedObjectContext *moc = [self managedObjectContextForCurrentThread];
	
	NSSet *updated  = [moc updatedObjects];
	NSSet *deleted  = [moc deletedObjects];
	NSSet *inserted = [moc insertedObjects];
	
	return [updated count] + [deleted count] + [inserted count];
}

-(void)commit {
	
 	NSManagedObjectContext *moc = [self managedObjectContextForCurrentThread];
	NSError *error = nil;
	
	if ([self pendingChangesCount] > kPostBlockUpdateThreshold) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kBlockUpdateNotificatioin object:nil];
	}
	
	if ([moc hasChanges] && ![moc save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
	[self discardManagedObjectContext];
}


-(NSManagedObjectContext *)managedObjectContextForMainThread {
	if (managedObjectContextForMainThread == nil) {
		
        NSAssert([NSThread isMainThread], @"Must be instantiated on main thread.");
        
		self.managedObjectContextForMainThread = [[[NSManagedObjectContext alloc] init]autorelease];
		[managedObjectContextForMainThread setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
		[managedObjectContextForMainThread setMergePolicy:kMergePolicy];
	}
	
	return managedObjectContextForMainThread;
}

-(NSManagedObjectContext *)managedObjectContextForCurrentThread {
	NSThread *thread = [NSThread currentThread];
	
	if ([thread isMainThread]) {
		return [self managedObjectContextForMainThread];
	}
	
	NSString *threadKey = [NSString stringWithFormat:@"%p", thread];
    
    if ( [self.managedObjectContexts objectForKey:threadKey] == nil ) {
		
        NSManagedObjectContext *threadContext = [[[NSManagedObjectContext alloc] init]autorelease];
        [threadContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
		[threadContext setMergePolicy:kMergePolicy];
		
        [self.managedObjectContexts setObject:threadContext forKey:threadKey];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(mocDidSave:)
													 name:NSManagedObjectContextDidSaveNotification
												   object:threadContext];
    }
    
	return [self.managedObjectContexts objectForKey:threadKey];
}

-(void)discardManagedObjectContext {
	NSString *threadKey = [NSString stringWithFormat:@"%p", [NSThread currentThread]];
	NSManagedObjectContext *threadContext = [self.managedObjectContexts objectForKey:threadKey];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:threadContext];
	[self.managedObjectContexts removeObjectForKey:threadKey];
}

-(NSManagedObjectModel *)managedObjectModel {
	if (managedObjectModel == nil) {
		NSString *modelPath = [[NSBundle mainBundle] pathForResource:self.modelName ofType:@"momd"];
		NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
		
		self.managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]autorelease];
	}
	
	return managedObjectModel;
}


-(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
	if (persistentStoreCoordinator == nil) {
		
		NSString *storePath = [self storePath];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		if (![fileManager fileExistsAtPath:storePath]) {
			NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:[self databaseName] ofType:nil];
			
			if ([fileManager fileExistsAtPath:defaultStorePath]) {
				[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
			}
		}
		
		NSURL *storeURL = [self storeURL];
		NSError *error = nil;
		
		self.persistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]]autorelease];
		
		NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
								 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
		
		if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
	
	return persistentStoreCoordinator;
}

-(void)mocDidSave:(NSNotification *)saveNotification {
    if ([NSThread isMainThread]) {
            
        [[self managedObjectContextForMainThread] mergeChangesFromContextDidSaveNotification:saveNotification];
    } else {
        [self performSelectorOnMainThread:@selector(mocDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
}

-(BOOL)doesRequireMigration {
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self storePath]]) {
		NSError *error;
		NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:[self storeURL] error:&error];
		return ![[self managedObjectModel] isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
	} else {
		return NO;
	}
}


-(NSString *)storePath {
	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[self databaseName]];
}

-(NSURL *)storeURL {
	return [NSURL fileURLWithPath:[self storePath]];
}

-(NSString *)databaseName {
    return [NSString stringWithFormat:@"%@.sqlite", [self.modelName lowercaseString]];
}

-(NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
