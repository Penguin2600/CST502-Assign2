#import <Cocoa/Cocoa.h>
#import <AppKit/NSTextField.h>
#import "Cst502Socket.h"
#import "DataPipe.h"


@interface AppDelegate : NSObject {
   NSWindow * window;
   NSView * view;
   NSString * host;
   NSString * port;
   NSString * name;
   NSTextField *serverLab, *subjectLab, *chatLab, *inputLab, *notify;
   NSTextField *serverTB, *subjectTB, *chatTB, *inputTB;
   Cst502ClientSocket * clientSocket;
}

- initWithName: (NSString*) aName;
- (void) applicationWillFinishLaunching:(NSNotification *)notification;
- (void) applicationDidFinishLaunching:(NSNotification *)notification;
- (void) addButtonWithTitle: (NSString*) aTitle target: (id) anObject action: (SEL) anAction rect: (NSRect) aRect;
- (NSTextField*) addLabelWithTitle:(NSString*) aTitle at: (NSRect) aRect;
- (NSTextField*) addFieldWithTitle:(NSString*) aTitle at: (NSRect) aRect;

- (BOOL) applicationShouldTerminate:(id) sender;
- (void) appendChat: (NSString*) aString;
- (void) newChat: (NSString*) newSub;
- (void) doNewChat;
- (void) doConnect;
- (void) doMsg;
- (void) doReg;
- (void) doUnReg;
- (void) doEnd;
- (void) dealloc;
@end
