RCContextManager is a simple handler for Core Data reading and writing.

Usage
=====
Read via the readQueue and readContext

````dispatch_async([[RCContextManager sharedInstance] readQueue], ^{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"myEntity" 
                                              inManagedObjectContext:[[RCContextManager sharedInstance] readContext]];
    [fetchRequest setEntity:entity];
    
    __block NSError *error;
    
    [self setArray:[[[RCContextManager sharedInstance] readContext] executeFetchRequest:fetchRequest error:&error]];
    
    [fetchRequest release];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
      [self.tableView reloadData];
    });
    });
````