//
//  DVModel.m
//  Dove
//
//  Created by Michael Zink on 09.06.12.
//  Copyright 2009 Baconfeet & Associates. All rights reserved.
//

#import "DVModel.h"


@implementation DVModel

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
	NSLog(@"The application support folder is being found...");
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
	NSLog(@"The application support folder is being used!");
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
	
	// This is where the problems occur. See the errors from runtime below.
	[DVManagedObjectModel setEntities:[NSArray arrayWithObjects:taskEntity, tagEntity]];
	
	/*
	2009-06-19 20:07:16.861 dove[19582:10b] The application support folder is being found...
	2009-06-19 20:07:16.870 dove[19582:10b] *** -[NSAttributeDescription _setManagedObjectModel:]: unrecognized selector sent to instance 0x101a700
	2009-06-19 20:07:16.871 dove[19582:10b] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '*** -[NSAttributeDescription _setManagedObjectModel:]: unrecognized selector sent to instance 0x101a700'
	2009-06-19 20:07:16.872 dove[19582:10b] Stack: (
													2455761067,
													2456124987,
													2455790250,
													2455783596,
													2455783794,
													2508869246,
													12224,
													10559,
													2456111288,
													2456105529,
													2456172246,
													10422
	)
	Trace/BPT trap
	*/
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
