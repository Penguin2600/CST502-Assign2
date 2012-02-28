#import <Foundation/Foundation.h>
#import "DataPipe.h"
#import "Cst502Socket.h"
#import "AppDelegate.h"

@interface ClientInputThread : NSThread {
   DataPipe * theData;
   AppDelegate * appDel;
   Cst502ClientSocket * cSock;
}

- (id) initWithPipe: (DataPipe*) aData aDelegate: (AppDelegate*) adel aSocket: (Cst502ClientSocket*) asock;
- (void) main;
- (DataPipe*) theData;
- (void) setTheData:(DataPipe*) aString;
- (void) setAppDel: (AppDelegate*) adel;
- (void) setSock: (Cst502ClientSocket*) aSock;
- (void) print;
- (void) dealloc;

@end

