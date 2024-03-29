//
//  AppDelegate.m
//  bugbag
//
//  Created by Robin Lu on 3/23/14.
//  Copyright (c) 2014 Robin Lu. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)createDoc:(id)sender {
    NSError *error = nil;
    CBLDatabase *database1 = [[CBLManager sharedInstance] databaseNamed:@"test1" error:nil];
    CBLDatabase *database2 = [[CBLManager sharedInstance] databaseNamed:@"test2" error:nil];
    NSURL *url = [NSURL URLWithString:@"http://test:abc123@localhost:4984/test"];
    
    CBLReplication *pusher1 = [database1 createPushReplication:url];
    pusher1.continuous = false;
    
    CBLReplication *pusher2 = [database2 createPushReplication:url];
    pusher2.continuous = false;

    NSString *docID = @"lost";
    CBLDocument *doc1;
    // create the document in database 1
    doc1 = [database1 documentWithID:docID];;
    NSMutableDictionary *docProperty1 = [@{@"key": @"v1.1", @"channels":@[@"public"]} mutableCopy];
    [doc1 putProperties:docProperty1 error:nil];
    docProperty1 = [doc1.properties mutableCopy];

    // create the document in database 2
    CBLDocument *doc2;
    doc2 = [database2 documentWithID:docID];;
    NSMutableDictionary *docProperty2 = [@{@"key": @"v1.2", @"channels":@[@"public"]} mutableCopy];
    [doc2 putProperties:docProperty2 error:&error];
    if (error) {
        NSLog(@"ERROR:%@", error);
        return;
    }
    docProperty2 = [doc2.properties mutableCopy];
    
    // sync
    [self runReplication:pusher1];
    [self runReplication:pusher2];
    
    docProperty1[@"key"] = @"v2.1";
    [doc1 putProperties:docProperty1 error:nil];
    docProperty1 = [doc1.properties mutableCopy];
    [self runReplication:pusher1];

    // create more conflicts
    docProperty2[@"key"] = @"2.2";
    [doc2 putProperties:docProperty2 error:nil];
    docProperty2 = [doc2.properties mutableCopy];
    docProperty2[@"key"] = @"3.2";
    [doc2 putProperties:docProperty2 error:nil];
    docProperty2 = [doc2.properties mutableCopy];
    
    // resolve conflict again
    [self runReplication:pusher2];
}

- (IBAction)sync:(id)sender {
    CBLDatabase *database1 = [[CBLManager sharedInstance] databaseNamed:@"test1" error:nil];
    CBLDatabase *database2 = [[CBLManager sharedInstance] databaseNamed:@"test2" error:nil];
    CBLDatabase *database3 = [[CBLManager sharedInstance] databaseNamed:@"test3" error:nil];
    NSURL *url = [NSURL URLWithString:@"http://test:abc123@localhost:4984/test"];
    CBLReplication *puller1 = [database1 createPullReplication:url];
    CBLReplication *puller2 = [database2 createPullReplication:url];
    CBLReplication *puller3 = [database3 createPullReplication:url];
    [self runReplication:puller1];
    [self runReplication:puller2];
    [self runReplication:puller3];
}

- (void)runReplication:(CBLReplication*)repl
{
    [repl start];
    NSDate* timeout = [NSDate dateWithTimeIntervalSinceNow: 2];
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
                             beforeDate: timeout];
    while (repl.running) {
        if (![[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
                                     beforeDate: timeout]) {
            break;
        }
    }
    ;
    [repl stop];
}

@end
