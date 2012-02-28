#import "DataPipe.h"

@implementation DataPipe

- (id) initWithResponse: (NSString*) inData {
   if ( (self = [super init]) ) {
      if ( serverResponse != inData ){
         dataLock = [[NSLock alloc] init];
         [serverResponse release];
         serverResponse = [inData retain];
      }
   }
   return self;
}

- (NSString*) getServerResponse {
   [dataLock lock];
   [dataLock unlock];
   return serverResponse;
}

- (void) setServerResponse: (NSString*) aStr{
   if ( serverResponse != aStr ){
      [dataLock lock];
      [serverResponse release];
      serverResponse = [aStr retain];
      printf("server response is: %s.\n", [serverResponse UTF8String]);
      [dataLock unlock];
   }
}

- (NSString*) getChatResponse {
   [dataLock lock];
   [dataLock unlock];
   return serverResponse;
}

- (void) setChatResponse: (NSString*) aStr{
   if ( chatResponse != aStr ){
      [dataLock lock];
      [chatResponse release];
      chatResponse = [aStr retain];
      printf("new chat is: %s.\n", [chatResponse UTF8String]);
      [dataLock unlock];
   }
}

- (void)dealloc {
   // release retained, allocated, and copied objects.
   [dataLock release];
   [serverResponse release];
   [chatResponse release];
   [super dealloc];
}

@end

