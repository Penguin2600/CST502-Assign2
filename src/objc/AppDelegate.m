#import "AppDelegate.h"
#import "ClientInputThread.h"
#import <AppKit/NSButton.h>

@implementation AppDelegate


- (id) initWithName: (NSString*) aName {
   if ( (self = [super init]) ) {
      NSRect contentSize = NSMakeRect(100.0f, 150.0f, 560.0f, 320.0f);
      // allocate window
      window = [[NSWindow alloc] initWithContentRect:contentSize
                                           styleMask:NSTitledWindowMask
                                             backing:NSBackingStoreBuffered
                                               defer:YES];
      [window setTitle:@"Objective-C Chat GUI"];
      // allocate view
      view = [[NSView alloc] initWithFrame:contentSize];
      [window setContentView:view];

      //Add the buttons across the bottom of the view.
      // place the button at 20,20 (x,y) in window with width 75 and height 30
      [self addButtonWithTitle:@"Exit" target:self action:@selector(doEnd) rect:NSMakeRect(70,10,75,30)];
      [self addButtonWithTitle:@"Register" target:self action:@selector(doReg) rect:NSMakeRect(160,10,75,30)];
      [self addButtonWithTitle:@"Send" target:self action:@selector(doMsg) rect:NSMakeRect(250,10,75,30)];
      [self addButtonWithTitle:@"New" target:self action:@selector(doNewChat) rect:NSMakeRect(340,10,75,30)];
      [self addButtonWithTitle:@"Connect" target:self action:@selector(doConnect) rect:NSMakeRect(430,10,75,30)];

      // server box
      serverLab = [self addLabelWithTitle:@"Server" at:NSMakeRect(20,270,40,20)];
      [serverLab retain];

      serverTB = [self addFieldWithTitle:@"localhost:8550" at: NSMakeRect(70,270,450,25)];
      [serverTB retain];
      //subject box
      subjectLab = [self addLabelWithTitle:@"Subject" at:NSMakeRect(20,240,70,20)];
      [subjectLab retain];

      subjectTB = [self addFieldWithTitle:@"Default Chat" at:NSMakeRect(70,240,450,25)];
      [subjectTB retain];
      // chat box 
      chatLab = [self addLabelWithTitle:@"Chat" at:NSMakeRect(20,150,40,20)];
      [chatLab retain];

      chatTB = [self addFieldWithTitle:@"" at:NSMakeRect(70,100,450,130)];
      [chatTB retain];

      //subject box
      inputLab = [self addLabelWithTitle:@"Input" at:NSMakeRect(20,70,70,20)];
      [inputLab retain];

      inputTB = [self addFieldWithTitle:@"chat input" at:NSMakeRect(70,70,450,25)];
      [inputTB retain];

     //notification box
      notify = [self addLabelWithTitle:@"Not Connected" at:NSMakeRect(20,40,450,25)];
      [notify retain];
      
      host=@"localhost";
      port=@"8550";
      name=aName;
   }
   return self;
}

- (void) applicationWillFinishLaunching:(NSNotification *)notification {
   // attach the view to the window
   [window setContentView:view];
}

- (void) applicationDidFinishLaunching:(NSNotification *)notification {
   [window makeKeyAndOrderFront:self];
   }

- (void) appendChat: (NSString*) aString{
   [chatTB setStringValue:[NSString stringWithFormat:@"%s%s", [[chatTB stringValue] UTF8String], [aString UTF8String]]];
}

  //new chat subject from server
- (void) newChat: (NSString*) newSub{
   [chatTB setStringValue: @""];
   [subjectTB setStringValue: newSub];

}
  //new chat request to server
- (void) doNewChat{
   if ([clientSocket getConnected] == YES) {
   NSString * newChat = [NSString stringWithFormat:@"%s%s%s", [@"NEWC " UTF8String], [[subjectTB stringValue] UTF8String], [@"\n" UTF8String]];
   [clientSocket sendBytes:[newChat UTF8String] OfLength:[newChat length] Index:0];
  } else {
   [notify setStringValue:[NSString stringWithFormat:@"Newchat Failed, No Connection"]];
  }
}

  //unregister from server
- (void) doUnReg{
if ([clientSocket getConnected] == YES) {
   NSString * inputString = [NSString stringWithFormat:@"%s%s%s", [@"UNR " UTF8String], [name UTF8String], [@"\n" UTF8String]];
   [clientSocket sendBytes:[inputString UTF8String] OfLength:[inputString length] Index:0];
   [notify setStringValue:[NSString stringWithFormat:@"Unregistered"]];
  } else {
   [notify setStringValue:[NSString stringWithFormat:@"Unregistration Failed, No Connection"]];
  }
}
  //register with server
- (void) doReg{
   if ([clientSocket getConnected] == YES) {
   NSString * inputString = [NSString stringWithFormat:@"%s%s%s", [@"REG " UTF8String], [name UTF8String], [@"\n" UTF8String]];
   [clientSocket sendBytes:[inputString UTF8String] OfLength:[inputString length] Index:0];
   [notify setStringValue:[NSString stringWithFormat:@"Registered"]];
  } else {
   [notify setStringValue:[NSString stringWithFormat:@"Please Connect First"]];
  }
}

- (void) doMsg{
   NSString * inputString = [NSString stringWithFormat:@"%s%s%s", [@"MSG " UTF8String], [[inputTB stringValue] UTF8String], [@"\n" UTF8String]];
   [clientSocket sendBytes:[inputString UTF8String] OfLength:[inputString length] Index:0];
}

- (void) doConnect {
    if ([clientSocket getConnected] == NO) {
    // connect to the server, allocate and retain a clientSocket
    clientSocket = [[Cst502ClientSocket alloc] initWithHost: host portNumber: port];   
    [clientSocket retain];
    if([clientSocket connect]){
    //establish a locked data object for passing data between threads
    DataPipe * dataPipe = [[DataPipe  alloc] initWithResponse: @"Initialized"];
    //establish our input listener thread and start it
    ClientInputThread * inputThread = [[ClientInputThread alloc] initWithPipe: dataPipe aDelegate: self aSocket: clientSocket];
    [inputThread start];
      [notify setStringValue:[NSString stringWithFormat:@"Connected to server, Please Register"]];
    }else{ 
      [notify setStringValue:[NSString stringWithFormat:@"Failed to connect to server"]];
    }

   }
}

- (void) doEnd {
   [self doUnReg];
   [NSApp terminate:self];
   }

- (void) addButtonWithTitle: (NSString*)aTitle
                     target: (id) anObject
                     action: (SEL) anAction
                       rect: (NSRect) aRect {
      NSButton *button = [[[NSButton alloc] initWithFrame:aRect ] autorelease];
      [button setTitle:aTitle];
      [button setAction:anAction];
      [button setTarget: anObject];
      [button setButtonType:NSMomentaryPushButton];
      [button setBezelStyle:NSTexturedSquareBezelStyle];
      [[window contentView] addSubview: button];
}

- (NSTextField*) addLabelWithTitle:(NSString*) aTitle at: (NSRect) aRect {
   NSTextField* label =[[[NSTextField alloc] initWithFrame: aRect] autorelease];
   [label setSelectable: NO];
   [label setBezeled: NO];
   [label setDrawsBackground: NO];
   [label setStringValue: aTitle];
   [[window contentView] addSubview: label];
   return label;
}

- (NSTextField*) addFieldWithTitle:(NSString*) aTitle at: (NSRect) aRect {
   NSTextField* label =[[[NSTextField alloc] initWithFrame: aRect] autorelease];
   [label setSelectable: YES];
   [label setEditable: YES];
   [label setBezeled: YES];
   [label setDrawsBackground: YES];
   [label setStringValue: aTitle];
   [[window contentView] addSubview: label];
   return label;
}

- (BOOL) applicationShouldTerminate:(id) sender {
   return YES;
}

- (void)dealloc {
   // don’t forget to release allocated objects!
   [self doUnReg];
   [serverLab release];
   [view release];
   [window release];
   [super dealloc];
}

@end
