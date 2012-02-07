//
// Copyright 2011 Rich Cameron
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "RCContextManager.h"

@implementation RCContextManager

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Synthesize
////////////////////////////////////////////////////////
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize readContext       = _readContext;
@synthesize writeContext      = _writeContext;

@synthesize readQueue       = _readQueue;
@synthesize writeQueue      = _writeQueue;

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Singleton methods
////////////////////////////////////////////////////////
+ (RCContextManager *)sharedInstance
{
  static dispatch_once_t once;
  static RCContextManager *dataManagerInstance;
  dispatch_once(&once, ^ { dataManagerInstance = [[RCContextManager alloc] init]; });
  return dataManagerInstance;
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - NSObject
////////////////////////////////////////////////////////
- (void)dealloc
{
  [_readContext release];
  [_writeContext release];
  
  [__managedObjectModel release];
  [__persistentStoreCoordinator release];
  
  [super dealloc];
}

////////////////////////////////////////////////////////
- (void)saveContext
{
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.writeContext;
  if (managedObjectContext != nil)
  {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
    {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } 
  }
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - SerialQueue management
////////////////////////////////////////////////////////
- (dispatch_queue_t)readQueue
{
  if (_readQueue)
    return _readQueue;
  
  _readQueue = dispatch_queue_create("com.rcameron.datamanager.readQueue", NULL);
  
  return _readQueue;
}

////////////////////////////////////////////////////////
- (dispatch_queue_t)writeQueue
{
  if (_writeQueue)
    return _writeQueue;
  
  _writeQueue = dispatch_queue_create("com.rcameron.datamanager.writeQueue", NULL);
  
  return _writeQueue;
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Context creation
////////////////////////////////////////////////////////
- (NSManagedObjectContext *)readContext
{
#ifdef DEBUG
  if (dispatch_get_current_queue() != _readQueue)
    NSLog(@"Accessing [ContextManager readContext] on wrong dispatch_queue!");
#endif
  
  
  if (_readContext != nil)
  {
    return _readContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil)
  {
    _readContext = [[NSManagedObjectContext alloc] init];
    [_readContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [_readContext setPersistentStoreCoordinator:coordinator];
  }
  return _readContext;
}

////////////////////////////////////////////////////////

- (NSManagedObjectContext *)writeContext
{
#ifdef DEBUG
  if (dispatch_get_current_queue() != _writeQueue)
    NSLog(@"Accessing [ContextManager writeContext] on wrong dispatch_queue!");
#endif  
  
  if (_writeContext != nil)
  {
    return _writeContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil)
  {
    _writeContext = [[NSManagedObjectContext alloc] init];
    [_writeContext setPersistentStoreCoordinator:coordinator];
  }
  return _writeContext;
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Managed Object Model
////////////////////////////////////////////////////////
- (NSManagedObjectModel *)managedObjectModel
{
  if (__managedObjectModel != nil)
  {
    return __managedObjectModel;
  }
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RCContextManager" withExtension:@"momd"];
  __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  return __managedObjectModel;
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Persistent Store Coordinator
////////////////////////////////////////////////////////
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
  if (__persistentStoreCoordinator != nil)
  {
    return __persistentStoreCoordinator;
  }
  
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RCContextManager.sqlite"];
  
  NSError *error = nil;
  __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
  {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
  }    
  
  return __persistentStoreCoordinator;
}

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
#pragma mark - Application's Documents directory
////////////////////////////////////////////////////////
/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

////////////////////////////////////////////////////////
@end