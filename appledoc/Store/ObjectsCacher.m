//
//  ObjectsCacher.m
//  appledoc
//
//  Created by Tomaz Kragelj on 3.12.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Store.h"
#import "ObjectsCacher.h"

@implementation ObjectsCacher

#pragma mark - Public interface

+ (NSDictionary *)cacheTopLevelObjectsFromStore:(Store *)store interface:(GBCacheBlock)block {
	NSMutableDictionary *result = [@{} mutableCopy];
	[result addEntriesFromDictionary:[self cacheTopLevelObjectsFromArray:store.storeClasses block:block]];
	[result addEntriesFromDictionary:[self cacheTopLevelObjectsFromArray:store.storeExtensions block:block]];
	[result addEntriesFromDictionary:[self cacheTopLevelObjectsFromArray:store.storeCategories block:block]];
	[result addEntriesFromDictionary:[self cacheTopLevelObjectsFromArray:store.storeProtocols block:block]];
	return result;
}

+ (NSDictionary *)cacheMembersFromStore:(Store *)store classMethod:(GBMemberCacheBlock)classBlock instanceMethod:(GBMemberCacheBlock)instanceBlock property:(GBMemberCacheBlock)propertyBlock {
	NSMutableDictionary *result = [@{} mutableCopy];
	[result addEntriesFromDictionary:[self cacheMembersFromInterfaces:store.storeClasses classMethod:classBlock instanceMethod:instanceBlock property:propertyBlock]];
	[result addEntriesFromDictionary:[self cacheMembersFromInterfaces:store.storeExtensions classMethod:classBlock instanceMethod:instanceBlock property:propertyBlock]];
	[result addEntriesFromDictionary:[self cacheMembersFromInterfaces:store.storeCategories classMethod:classBlock instanceMethod:instanceBlock property:propertyBlock]];
	[result addEntriesFromDictionary:[self cacheMembersFromInterfaces:store.storeProtocols classMethod:classBlock instanceMethod:instanceBlock property:propertyBlock]];
	return result;
}

+ (NSDictionary *)cacheMembersFromInterface:(InterfaceInfoBase *)interface classMethod:(GBMemberCacheBlock)classBlock instanceMethod:(GBMemberCacheBlock)instanceBlock property:(GBMemberCacheBlock)propertyBlock {
	NSMutableDictionary *result = [@{} mutableCopy];
	[result addEntriesFromDictionary:[self cacheMembersFromParent:interface array:interface.interfaceClassMethods block:classBlock]];
	[result addEntriesFromDictionary:[self cacheMembersFromParent:interface array:interface.interfaceInstanceMethods block:instanceBlock]];
	[result addEntriesFromDictionary:[self cacheMembersFromParent:interface array:interface.interfaceProperties block:propertyBlock]];
	return result;
}

+ (NSDictionary *)cacheMembersFromInterface:(InterfaceInfoBase *)interface member:(GBMemberCacheBlock)block {
	return [self cacheMembersFromInterface:interface classMethod:block instanceMethod:block property:block];
}

#pragma mark - Helper methods

+ (NSDictionary *)cacheMembersFromInterfaces:(NSArray *)interfaces classMethod:(GBMemberCacheBlock)classBlock instanceMethod:(GBMemberCacheBlock)instanceBlock property:(GBMemberCacheBlock)propertyBlock {
	NSMutableDictionary *result = [@{} mutableCopy];
	[interfaces enumerateObjectsUsingBlock:^(InterfaceInfoBase *interface, NSUInteger idx, BOOL *stop) {
		[result addEntriesFromDictionary:[self cacheMembersFromInterface:interface classMethod:classBlock instanceMethod:instanceBlock property:propertyBlock]];
	}];
	return result;
}

+ (NSDictionary *)cacheTopLevelObjectsFromArray:(NSArray *)array block:(GBCacheBlock)block {
	NSMutableDictionary *result = [@{} mutableCopy];
	[array enumerateObjectsUsingBlock:^(InterfaceInfoBase *interface, NSUInteger idx, BOOL *stop) {
		[self addKeysFromArray:block(interface) forObject:interface toCache:result];
	}];
	return result;
}

+ (NSDictionary *)cacheMembersFromParent:(InterfaceInfoBase *)parent array:(NSArray *)array block:(GBMemberCacheBlock)block {
	NSMutableDictionary *result = [@{} mutableCopy];
	[array enumerateObjectsUsingBlock:^(ObjectInfoBase *obj, NSUInteger idx, BOOL *stop) {
		[self addKeysFromArray:block(parent, obj) forObject:obj toCache:result];
	}];
	return result;
}

+ (void)addKeysFromArray:(id)keys forObject:(id)object toCache:(NSMutableDictionary *)cache {
	if (!keys) return;
	if ([keys isKindOfClass:[NSArray class]]) {
		[keys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
			cache[key] = object;
		}];
	} else {
		cache[keys] = object;
	}
}

@end
