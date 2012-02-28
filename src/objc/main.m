#import <Foundation/Foundation.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#import <Cocoa/Cocoa.h>
#import "DataPipe.h"
#import "ClientInputThread.h"
#import "AppDelegate.h"

int main(int argc, char *argv[]) {

    // create an autorelease pool
    NSAutoreleasePool * pool = [NSAutoreleasePool new];

    //handle command line args
    if (argc != 2 ) {
        printf("usage: %s username\n\n", argv[0] ); 
        exit(0);
    }

    // make sure the application singleton has been instantiated
    NSApplication * application = [NSApplication sharedApplication];
    // instantiate our application delegate
    AppDelegate * applicationDelegate = [[[AppDelegate alloc] initWithName: [NSString stringWithUTF8String: argv[1]]] autorelease];
    // assign our delegate to the NSApplication
    [application setDelegate:applicationDelegate];
        // call the run method of our application
    [application run];

    [pool release];
    // execution never gets here ..
    return 0;
}
   
