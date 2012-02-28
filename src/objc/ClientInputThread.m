#import "ClientInputThread.h"

#define MAXDATASIZE 4096

@implementation ClientInputThread

- (id) initWithPipe: (DataPipe*) aData aDelegate: (AppDelegate*) adel aSocket: (Cst502ClientSocket*) asock {
   if ( (self = [super init]) ) {
      [self setTheData: aData];
      [self setAppDel: adel];
      [self setSock: asock];
   }
   return self;
}

- (void) main {
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   char * buf = malloc(MAXDATASIZE);
   NSString* returnStr;				       //prepare space for the server's response
   while ( YES ) {
       returnStr = [cSock receiveBytes: buf maxBytes:MAXDATASIZE beginAt:0]; //read in the server response

       if([returnStr hasPrefix:@"SRS"]){               // if its a server response then send it to our data pipe.
          [theData setServerResponse: returnStr];
       }else if ([returnStr hasPrefix:@"NEWC"]){               // if its a new chat then set our fields/
          [self->appDel newChat: [returnStr substringFromIndex:6]]; 
       }else{
          //[theData setServerResponse: returnStr];    // otherwise send it to our gui.
          [self->appDel appendChat: returnStr]; //
       }
   }
   [pool release];
}

- (DataPipe*) theData {
   return [theData getServerResponse];
}

- (void) setTheData: (DataPipe*) aData {
   if (self->theData != aData){
      [self->theData release];
      self->theData = [aData retain];
   }
}

- (void) setAppDel: (AppDelegate*) adel {
   if (self->appDel != adel){
      [self->appDel release];
      self->appDel = [adel retain];
   }
}

- (void) setSock: (Cst502ClientSocket*) aSock {
   if (self->cSock != aSock){
      [self->cSock release];
      self->cSock = [aSock retain];
   }
}

- (void) print {
   printf("Print: Thread is alive");
}

- (void)dealloc {
   // release retained, allocated, and copied objects.
   [theData release];
   [super dealloc];
}

@end

