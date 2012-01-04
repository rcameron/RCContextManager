# RCContextManager #
RCContextManager is a simple manager for Core Data reading and writing.

Usage
=====
Read via the readQueue and readContext

```objective-c
dispatch_async([[RCContextManager sharedInstance] readQueue], ^{
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
```

Write via the writeQueue and writeContext

```objective-c
dispatch_async([[RCContextManager sharedInstance] writeQueue], ^{
      MyObject *myObject = (MyObject *)[[[RCContextManager sharedInstance] writeContext] existingObjectWithID:selectedId error:nil];
      
      if (myObject) {
        [[[RCContextManager sharedInstance] writeContext] deleteObject:myObject];
        
        error = nil;
        if (![[[RCContextManager sharedInstance] writeContext] save:&error])
          NSLog(@"error = %@", [error  localizedDescription]);
      }
    });
```

