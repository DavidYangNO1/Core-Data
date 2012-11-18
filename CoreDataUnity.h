//
//  CoreDataUnity.h
//  BaiYing
//
//  Created by Yang David on 9/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;


/**
 * Core Data 数据操作通用类
 * 多线程处理
 */

@interface CoreDataUnity : NSObject

//----------获取core data 上下文--------
+(NSManagedObjectContext*)getContextForCurrentThread;

+(AppDelegate*)getGloableAppDelegate;

//----------获取插入实体----------------
+(id)getInsertEntity:(NSString*)entity;

//----------保存实体-------------------
+(bool)saveEntity;

//----------删除实体-------------
+(void)deleteManagedObject:(NSManagedObject*)entity;

+(void)deletEntityLists:(NSString*)entity withQueryText:(NSString*)queryText;

//----------通过查询条件获取实体列表-------------
+(NSArray*)getFetchEntityLists:(NSString*)entity withQueryText:(NSString*)queryText;

//----------通过查询条件获取实体列表-------------
+(NSArray*)getFetchEntityLists:(NSString*)entity withQueryText:(NSString*)queryText withSortKey:(NSString*)key withSortValue:(BOOL)value withIndex:(long)IndexOffset withPageSize:(long)pageSize;

+(NSArray*)getFetchEntityLists:(NSString *)entity withQueryText:(NSString *)queryText withSortKey:(NSString *)key withSortValue:(BOOL)value;

@end


@class  BYManagedObjectContextManager;

/**
 * 集合操作
 */
typedef enum {
    BYCollectionMax,
    ByCollectionMin,
    ByCollectionAverage,
    ByCollectionSum
}ByCollection;

/**
 * core data 实体抽象类，定义的core data实体类继承BYManagedObject，设置几个相关方法，
 * 多线程管理core data 实体操作类
 */
@interface BYManagedObject:NSManagedObject

/**
 * 实体名称
 */
+(NSString*)entityName;

/**
 * coredata名称 (.xcdatamodeld)
 */
+(NSString*)modelName;

+(NSEntityDescription*)entityDescription;

+(void)deleteStore;

+(void)commit;

+(id)newEntity;

+(id)getWithPredicate:(NSPredicate*)predicate;

+(id)getWithPredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor*)descriptor;

/**
 * 提取实体所有数据
 */
+(NSArray*)fectchAll;


/**
 * 按条件提取实体数据
 * @pram predicate  查询条件
 */
+(NSArray*)fetchWithPredicate:(NSPredicate*)predicate;

/**
 * 按条件提取实体数据 并指定排序
 * @pram predicate  查询条件
 * @pram descriptor 排序
 */
+(NSArray*)fetchWithPredicate:(NSPredicate*)predicate sortDescriptor:(NSSortDescriptor*)descriptor;


/**
 * 按条件提取实体数据 并指定排序
 * @pram predicate  查询条件
 * @pram descriptor 排序
 * @pram limit 提取数量
 */
+(NSArray *)fetchWithPredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)descriptor withLimit:(NSUInteger)limit;

// 统计实体数量
+(NSUInteger)count;

/**
 *  带条件统计实体数量
 *  @pram predicate  查询条件
 */
+(NSUInteger)countWithPredicate:(NSPredicate *)predicate;

#pragma mark - kvc 集合操作
/**
 *  获取没有重复数据数据集
 *  @pram attribute  属性
 *  @pram predicate  查询条件
 */
+(NSArray *)distinctValuesWithAttribute:(NSString *)attribute predicate:(NSPredicate *)predicate;

/**
 *  获取集合操作符字符串
 *  @pram collection 属性
 *  @pram predicate  查询条件
 */
+(NSString*)collectionToString:(ByCollection)collection;

+(NSAttributeType)attributeTypeWithKey:(NSString *)key;

+(id)collectionWithType:(ByCollection)collection key:(NSString *)key predicate:(NSPredicate *)predicate defaultValue:(id)defaultValue;

+(void)deletaAll;

#pragma mark - 删除操作
/**
 *  带条件删除
 *  @pram predicate  删除条件
 */
+(NSUInteger)deleteWithPredicate:(NSPredicate *)predicate;


/**
 *  获取线程安全的managedObjectContext
 *  @pram predicate  删除条件
 */
+(NSManagedObjectContext *)managedObjectContextForCurrentThread;

/**
 * 获取封装对managedObjectContext的管理 
 */
+(BYManagedObjectContextManager *)managedObjectContextManager;

/**
 * 是否迁移数据
 */
+(BOOL)doesRequireMigration;


-(void)delete;

-(id)clone;

-(id)objectInCurrentThreadContext;

-(NSDictionary *)serialize;

@end

#define kMergePolicy NSMergeByPropertyObjectTrumpMergePolicy

#define kBlockUpdateNotificatioin @"BlockUpdateNotificatioin"

#define kPostBlockUpdateThreshold 10

#define kDistinctUnionKey @"@distinctUnionOfObjects."

@interface BYManagedObjectContextManager : NSObject

+(BYManagedObjectContextManager*)sharedInstanceWithModelName:(NSString*)modelName;

-(id)initWithModelName:(NSString *)modelName;


-(NSManagedObjectContext *)managedObjectContextForCurrentThread;

-(void)deleteStore;

-(void)commit;

/**
 * 待处理的数据
 */
-(NSUInteger)pendingChangesCount;

-(BOOL)doesRequireMigration;

-(NSString *)applicationDocumentsDirectory;

@end



