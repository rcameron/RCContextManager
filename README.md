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
    
    [self setArray:[[[RCContextManager sharedInstance] readContext] executeFetchRequest:fetchRequest error:nil]];
    
    [fetchRequest release];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
      [self.tableView reloadData];
    });
});
```

Write via the writeQueue and writeContext

```objective-c
dispatch_async([[RCContextManager sharedInstance] writeQueue], ^{
      MyObject *anObject = (MyObject *)[[[RCContextManager sharedInstance] writeContext] existingObjectWithID:selectedId error:nil];
      
      if (anObject) {
        [[[RCContextManager sharedInstance] writeContext] deleteObject:anObject];
        [[[RCContextManager sharedInstance] writeContext] save:nil];
      }
    });
```

Logging
=======
When the debug flag is set, instances where a context is accessed via the wrong queue will be logged to the console.
