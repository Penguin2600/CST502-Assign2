#import "Cst502Socket.h"
#define PORT "4444"

// get sockaddr, IPv4 or IPv6:
void *get_in_addr(struct sockaddr *sa){
    if (sa->sa_family == AF_INET) {
        return &(((struct sockaddr_in*)sa)->sin_addr);
    }
    return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

@implementation Cst502ServerSocket

- (id) initWithPort: (NSString*) port{
   self = [super init];
   int ret = 0;
   memset(&hints, 0, sizeof hints);
   hints.ai_family = AF_INET;
   hints.ai_socktype = SOCK_STREAM;
   hints.ai_flags = AI_PASSIVE; // use my IP
   const char* portStr = [port UTF8String];
   if ((rv = getaddrinfo(NULL, portStr, &hints, &servinfo)) != 0) {
      fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
      ret = 1;
   }else{
      for(p = servinfo; p != NULL; p = p->ai_next) {
         if ((sockfd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP))==-1){
            perror("server: socket create error");
            continue;
         }
         if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {

         close(sockfd);

            perror("server: bind error");
            continue;
         }
         break;
      }
      if (p == NULL)  {
         fprintf(stderr, "server: failed to bind\n");
         ret = 2;
      }else{
         freeaddrinfo(servinfo); // all done with this structure
         if (listen(sockfd, BACKLOG) == -1) {
            perror("server: listen error");
            ret = 3;
         }
      }
      if (ret == 0){
         return self;
      } else {
         return nil;
      }
   }
}

- (BOOL) accept {
   BOOL ret = YES;

   new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size);

   if (new_fd == -1) {
      perror("server: accept error");
      ret = NO;
   }
   connected = ret;
   return ret;
}

- (int) sendBytes: (char*) byteMsg OfLength: (int) msgLength Index: (int) at{
   int ret = send(new_fd, byteMsg, msgLength, 0);
   if(ret == -1){
      NSLog(@"error sending bytes");
   }
   return ret;
}

- (NSString* ) receiveBytes: (char*) byteMsg
                   maxBytes: (int) max
                    beginAt: (int) at {
   int ret = recv(new_fd, byteMsg, max-1, at);
   if(ret == -1){
      NSLog(@"server error receiving bytes");
   }
   byteMsg[ret+at] = '\0';
   NSString * retStr = [NSString stringWithUTF8String: byteMsg];
   return retStr;
}

- (BOOL) close{

   close(new_fd);

   connected = NO;
   return YES;
}

- (void) dealloc {

   close(sockfd);

   [super dealloc];
}

@end

@implementation Cst502ClientSocket

//Init, takes in 2 strings (host,port) and retains them
- (id) initWithHost: (NSString*) host portNumber: (NSString*) port {	
   self = [super init];
   hostName = host;
   [hostName retain];
   portNum = port;
   [portNum retain];
   return self;
}

- (BOOL) connect {
   connected = YES;			//bool connected TRUE
   memset(&hints, 0, sizeof hints);	//fill struct addrinfo hints with 0
   hints.ai_family = PF_INET;		//set the protocol family to INET (IP)
   hints.ai_socktype = SOCK_STREAM;     //set socket type to TCP

   //try to establish a host address given a text string
   if ((returnVal = getaddrinfo([hostName UTF8String], [portNum UTF8String], &hints, &servinfo)) != 0) {
      fprintf(stderr, "client error getting host address: %s\n",
              gai_strerror(returnVal));
      connected = NO;
   }

   // loop through all the results from above and build a socket with the first we can
   for(p = servinfo; p != NULL; p = p->ai_next) {
      if ((sockfd = socket(p->ai_family,p->ai_socktype,p->ai_protocol)) == -1){
         perror("client error creating socket");
         connected = NO;
         continue;
      }

      //try and connect!
      int callret = connect(sockfd, p->ai_addr, p->ai_addrlen);

      if (callret == -1) {	//if our connection fails
         close(sockfd);		//kill the socket
         inet_ntop(p->ai_family, get_in_addr((struct sockaddr *)p->ai_addr), s, sizeof s);//get text ip address from binary.
         printf("client failed to connect to %s\n", s); 				  //alert the user
         connected = NO;
         continue;
      }

      break;

   }
   if (p == NULL) {
      printf("client failed to connect\n");
      connected = NO;
   }else{

      inet_ntop(p->ai_family, get_in_addr((struct sockaddr *)p->ai_addr),s, sizeof s); //get text ip address from binary.
      printf("client connected to %s\n", s);                                           //we connected!

      connected = YES;
   }
   return connected;
}

- (int) sendBytes: (char*) byteMsg OfLength: (int) msgLength Index: (int) index{
   int ret = send(sockfd, byteMsg, msgLength, 0); 		//sockets method to send
   if(ret == -1){
      NSLog(@"client error sending bytes");
   }
   return ret;
}

- (NSString*) receiveBytes: (char*) byteMsg maxBytes: (int) max beginAt: (int) index {
   int ret = recv(sockfd, byteMsg, max-1, index); 		//sockets method to recieve
   if(ret == -1){
      NSLog(@"client error receiving bytes");
   }
   byteMsg[ret+index] = '\0'; 					//terminate the return string with a Null
   NSString * retStr = [NSString stringWithUTF8String: byteMsg];//return an NSString
   return retStr;
}

- (BOOL) getConnected{
   return connected;
}

- (BOOL) close{
   connected = NO;
   return YES;
}

- (void) dealloc {
   [hostName release];
   [portNum release];
   [super dealloc];
}

@end

