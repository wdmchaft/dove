//
//  Task.h
//  Dove
//
//  Created by Michael Zink on 09.06.11.
//  Copyright 2009 Baconfeet & Associates. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Task : NSManagedObject
@property (retain) NSString *action;
@property (retain) NSDate *dueDate;
@property (retain) NSNumber *completed;

@end
