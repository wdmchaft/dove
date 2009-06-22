#import <Foundation/Foundation.h>
#import "DoveEngine.h"
#import "Task.h"


int main (int argc, const char * argv[]) {
	objc_startCollectorThread();
	
	if ([DoveEngine applicationSupportFolder] == nil) {
		NSLog(@"Could not find application support folder.\nExiting...");
		exit(1);
	}
	
	NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
	
	NSManagedObjectContext *moc = [DoveEngine managedObjectContext];
	NSManagedObjectModel *mom = [DoveEngine managedObjectModel];
	
	NSEntityDescription *taskEntity = [[mom entitiesByName] objectForKey:@"Task"];
	
	// For form: ./dove -new "Thing to do" -due today -tags "example,test"
	if ([args stringForKey:@"new"]) {
		NSString *dueDate = [args stringForKey:@"due"];
		// Currently, tags must be separated only by commas, no spaces
		NSArray *tags = [[args stringForKey:@"tags"]
						 componentsSeparatedByString:@","];
		Task *newTask = [[Task alloc] initWithEntity:taskEntity
					  insertIntoManagedObjectContext:moc];
		newTask.action = [args stringForKey:@"new"];
		if ([dueDate length] > 0) {
			newTask.dueDate = [NSDate dateWithNaturalLanguageString:dueDate];
		}
		// newTask.tags = tags; ?
		NSLog(@"%@", newTask);
		
		NSError *error = nil;
		if (![moc save:&error]) {
			NSLog(@"Error while saving: %@",
				  ([error localizedDescription] != nil) ? [error localizedDescription]
				  : @"Unknown error");
			exit(1);
		}
	}
	
	// Yes, these ifs are separate, so you can simultaneously call two commands.
	if ([args stringForKey:@"search"]) {
		NSString *searchTerm = [args stringForKey:@"search"];
		
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:taskEntity];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
											initWithKey:@"dueDate" ascending:YES];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		
		if ([searchTerm isEqualToString:@"*"]) {
			NSPredicate *search = [NSPredicate
								   predicateWithFormat:@"(action contains[cd] %@)", searchTerm];
			[request setPredicate:search];
		}
		
		NSError *error = nil;
		NSArray *tasks = [moc executeFetchRequest:request error:&error];
		if ((error != nil) || (tasks == nil)) {
			NSLog(@"Error while fetching tasks: %@",
				  ([error localizedDescription] != nil) ? [error localizedDescription]
				  : @"Unknown error");
			exit(1);
		}
		
		Task *task = [[Task alloc] initWithEntity:taskEntity insertIntoManagedObjectContext:moc];
		NSString *c = [[NSString init] alloc];
		for (task in tasks) {
			if (task.completed) {
				c = [NSString stringWithString:@"x"];
			} else {
				c = [NSString stringWithString:@" "];
			}
			NSLog(@"[%@] %@ (due %@)", c, task.action, task.dueDate);
		}
	}
	
	return 0;
}
