//
//  Task.h
//  Dove
//
//  Created by Michael Zink on 09.06.11.
//  Copyright 2009 Baconfeet & Associates. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Task : NSManagedObject {
}
@property (retain) NSString *action;
@property (retain) NSDate *dueDate;
// Both NSNumber and BOOL fail here. BOOL won't even compile (saying "property
// 'completed' with 'retain' attribute must be of object type"), and NSNumber
// produces the runtime error shown in DVModel.m
// I am pretty sure my main question is what type should completed be?
@property (retain) NSNumber *completed;
@end
