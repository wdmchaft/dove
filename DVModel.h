//
//  DVModel.h
//  Dove
//
//  Created by Michael Zink on 09.06.12.
//  Copyright 2009 Baconfeet & Associates. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>


static NSString *DVApplicationSupportFolder = nil;
static NSManagedObjectModel *DVManagedObjectModel = nil;
static NSManagedObjectContext *DVManagedObjectContext = nil;

@interface DVModel : NSObject

+ (NSString *)applicationSupportFolder;
+ (void)initApplicationSupportFolder;
+ (NSManagedObjectModel *)managedObjectModel;
+ (void)initManagedObjectModel;
+ (NSManagedObjectContext *)managedObjectContext;
+ (void)initManagedObjectContext;

@end