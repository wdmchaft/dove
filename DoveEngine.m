//
//  DoveEngine.m
//  Dove
//
//  Created by Michael Zink on 09.06.12.
//  Copyright 2009 Baconfeet & Associates. All rights reserved.
//

#import "DoveEngine.h"


@implementation DoveEngine

+ (void)initialize {
	if (!DVApplicationSupportFolder) {
		[self initApplicationSupportFolder];
	}
	if (!DVManagedObjectModel) {
		[self initManagedObjectModel];
	}
	if (!DVManagedObjectContext) {
		[self initManagedObjectContext];
	}
}

+ (void)initApplicationSupportFolder {
	NSArray *paths = NSSearchPathForDirectoriesInDomains
		(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
	DVApplicationSupportFolder = [basePath stringByAppendingPathComponent:@"Dove"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory = NO;
	if (![fileManager fileExistsAtPath:DVApplicationSupportFolder isDirectory:&isDirectory]) {
		if (![fileManager createDirectoryAtPath:DVApplicationSupportFolder attributes:nil]) {
			DVApplicationSupportFolder = nil;
		}
	}
	else {
		if (!isDirectory) {
			DVApplicationSupportFolder = nil;
		}
	}
}

+ (NSString *)applicationSupportFolder {
	return DVApplicationSupportFolder;
}

+ (void)initManagedObjectModel {
	DVManagedObjectModel = [[NSManagedObjectModel alloc] init];
	
	// Task entity
	NSEntityDescription *taskEntity = [[NSEntityDescription alloc] init];
	[taskEntity setName:@"Task"];
	[taskEntity setManagedObjectClassName:@"Task"];
	
	NSAttributeDescription *actionAttr = [[NSAttributeDescription alloc] init];
	[actionAttr setName:@"action"];
	[actionAttr setAttributeType:NSStringAttributeType];
	[actionAttr setOptional:NO];
	
	NSAttributeDescription *dueDateAttr = [[NSAttributeDescription alloc] init];
	[dueDateAttr setName:@"dueDate"];
	[dueDateAttr setAttributeType:NSDateAttributeType];
	[dueDateAttr setOptional:YES];
	
	NSAttributeDescription *completedAttr = [[NSAttributeDescription alloc] init];
	[completedAttr setName:@"completed"];
	[completedAttr setAttributeType:NSBooleanAttributeType];
	[completedAttr setDefaultValue:NO];
	[completedAttr setOptional:YES];
	
	NSArray *taskProperties = [NSArray arrayWithObjects:actionAttr, dueDateAttr, completedAttr, nil];
	[taskEntity setProperties:taskProperties];
	
	// Tag entity
	NSEntityDescription *tagEntity = [[NSEntityDescription alloc] init];
	[tagEntity setName:@"Tag"];
	[tagEntity setManagedObjectClassName:@"Tag"];
	
	NSAttributeDescription *nameAttr = [[NSAttributeDescription alloc] init];
	[nameAttr setName:@"name"];
	[nameAttr setAttributeType:NSStringAttributeType];
	[nameAttr setOptional:NO];
	
	NSArray *tagProperties = [NSArray arrayWithObject:nameAttr];
	[tagEntity setProperties:tagProperties];
	
	[DVManagedObjectModel setEntities:[NSArray arrayWithObjects:taskEntity, tagEntity, nil]];
}

+ (NSManagedObjectModel *)managedObjectModel {
	return DVManagedObjectModel;
}

+ (void)initManagedObjectContext {
	DVManagedObjectContext = [[NSManagedObjectContext alloc] init];
	
	// Store configuration
	NSString *STORE_TYPE = NSSQLiteStoreType;
	NSString *STORE_FILENAME = @"Dove.dovelibrary";
	
	NSPersistentStoreCoordinator *coordinator =
	[[NSPersistentStoreCoordinator alloc]
	 initWithManagedObjectModel:[self managedObjectModel]];
	[DVManagedObjectContext setPersistentStoreCoordinator:coordinator];
	
	NSURL *url = [NSURL fileURLWithPath:[[self applicationSupportFolder]
										 stringByAppendingPathComponent:STORE_FILENAME]];
	NSError *error;
	NSPersistentStore *newStore = [coordinator
								   addPersistentStoreWithType:STORE_TYPE
								   configuration:nil
								   URL:url
								   options:nil
								   error:&error];
	if (newStore == nil) {
		NSLog(@"Store configuration failure\n%@", [error localizedDescription]);
	}
}

+ (NSManagedObjectContext *)managedObjectContext {
	return DVManagedObjectContext;
}

@end
