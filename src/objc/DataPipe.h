#import <Foundation/Foundation.h>

@interface DataPipe : NSObject {
   NSString *serverResponse;
   NSString *chatResponse;
   NSLock * dataLock;
}

- (id) initWithResponse: (NSString*) inData;
- (NSString*) getServerResponse;
- (void) setServerResponse: (NSString*) aStr;
- (NSString*) getChatResponse;
- (void) setChatResponse: (NSString*) aStr;

- (void) dealloc;

@end

