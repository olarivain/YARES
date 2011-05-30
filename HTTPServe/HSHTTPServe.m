//
//  HTTPServe.m
//  HTTPServe
//
//  Created by Kra on 2/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

#import "HSHTTPServe.h"
#import "HSHTTPConnection.h"
#import "HSRequestHandlerRegistry.h"

static void HTTPServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);

@interface HSHTTPServe(private)
- (void) initializeHTTPServer;
- (void) initializeBonjour;
- (void) stopHTTPServer;
- (void) stopBonjour;
- (void)handleNewConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr;
- (void) addConnection: (HSHTTPConnection*) connection;
- (void) removeConnection: (HSHTTPConnection*) connection;
@end

@implementation HSHTTPServe

- (id)initWithPort: (int) listenPort
{
  return [self initWithPort: listenPort bonjourEnabled: TRUE];
}

- (id)initWithPort: (int) listenPort bonjourEnabled: (BOOL) bonjour
{
  self = [super init];
  if (self) 
  {
    bonjourEnabled = bonjour;
    port = listenPort <= 0 ? 0 : listenPort;
    connections = [[NSMutableArray alloc] init];
    handlerRegistry = [[HSRequestHandlerRegistry alloc] init];
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount: 10];
  }
  
  return self;
}

- (void)dealloc
{
  [self stop];  
  [handlerRegistry release];
  [operationQueue release];
  [super dealloc];
}

#pragma mark - Start/stop methods
- (void) start
{
  [self initializeHTTPServer];
  [handlerRegistry autoregister];
  
  if(bonjourEnabled)
  {
    [self initializeBonjour];
  }
  
  NSLog(@"HTTP Server up and running on port %i, bonjour enabled: %i", port, bonjourEnabled);
}

- (void) initializeHTTPServer
{
  // gotta love all the C code. Taken from Apple samples, cleaned up not to leak as much as my granny.
  CFSocketContext socketCtxt = {0, self, NULL, NULL, NULL};
  ipv4socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&HTTPServerAcceptCallBack, &socketCtxt);
  ipv6socket = CFSocketCreate(kCFAllocatorDefault, PF_INET6, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&HTTPServerAcceptCallBack, &socketCtxt);
  
  if (NULL == ipv4socket || NULL == ipv6socket) 
  {
    NSLog(@"Error: Could not allocate CFSockets.");
    if (ipv4socket)
    {
      CFRelease(ipv4socket); 
    }
    if (ipv6socket)
    {
      CFRelease(ipv6socket);
    }
    ipv4socket = NULL;
    ipv6socket = NULL;
    return;
  }
  
  int yes = 1;
  setsockopt(CFSocketGetNative(ipv4socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
  setsockopt(CFSocketGetNative(ipv6socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
  
  // set up the IPv4 endpoint; if port is 0, this will cause the kernel to choose a port for us
  struct sockaddr_in addr4;
  memset(&addr4, 0, sizeof(addr4));
  addr4.sin_len = sizeof(addr4);
  addr4.sin_family = AF_INET;
  addr4.sin_port = htons(port);
  addr4.sin_addr.s_addr = htonl(INADDR_ANY);
  NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
  
  if (kCFSocketSuccess != CFSocketSetAddress(ipv4socket, (CFDataRef)address4)) 
  {
    NSLog(@"Error: Could not set IPv4 socket address.");
    if (ipv4socket)
    {
      CFRelease(ipv4socket);
    }
    if (ipv6socket)
    {
      CFRelease(ipv6socket);
    }
    ipv4socket = NULL;
    ipv6socket = NULL;
    return;
  }
  
  if (port == 0) 
  {
    // now that the binding was successful, we get the port number 
    // -- we will need it for the v6 endpoint and for the NSNetService
    NSData *addr = [(NSData *)CFSocketCopyAddress(ipv4socket) autorelease];
    memcpy(&addr4, [addr bytes], [addr length]);
    port = ntohs(addr4.sin_port);
  }
  
  // set up the IPv6 endpoint
  struct sockaddr_in6 addr6;
  memset(&addr6, 0, sizeof(addr6));
  addr6.sin6_len = sizeof(addr6);
  addr6.sin6_family = AF_INET6;
  addr6.sin6_port = htons(port);
  memcpy(&(addr6.sin6_addr), &in6addr_any, sizeof(addr6.sin6_addr));
  NSData *address6 = [NSData dataWithBytes:&addr6 length:sizeof(addr6)];
  
  if (kCFSocketSuccess != CFSocketSetAddress(ipv6socket, (CFDataRef)address6)) 
  {
    NSLog(@"Error: Could not set IPv6 socket address.");
    if (ipv4socket)
    {
      CFRelease(ipv4socket);
    }
    
    if (ipv6socket)
    {
      CFRelease(ipv6socket);
    }
    ipv4socket = NULL;
    ipv6socket = NULL;
    return;
  }
  
  // set up the run loop sources for the sockets
  CFRunLoopRef cfrl = CFRunLoopGetCurrent();
  CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, ipv4socket, 0);
  CFRunLoopAddSource(cfrl, source4, kCFRunLoopCommonModes);
  CFRelease(source4);
  
  CFRunLoopSourceRef source6 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, ipv6socket, 0);
  CFRunLoopAddSource(cfrl, source6, kCFRunLoopCommonModes);
  CFRelease(source6);
}

- (void) initializeBonjour
{
  NSString *hostname = [[NSHost currentHost] localizedName];
  NSString *serviceName = [NSString stringWithFormat:@"iServe-%@", hostname];
  netService = [[NSNetService alloc] initWithDomain:@"local." type:@"_http._tcp" name: serviceName port: port];
  [netService setDelegate: self];
  
  [netService publish];
}

- (void) stop 
{
  [self stopHTTPServer];
  if(bonjourEnabled)
  {
    [self stopBonjour];
  }
}

- (void) stopHTTPServer
{
  [handlerRegistry unregisterRequestHandlers];
  [netService stop];
  [netService release];
  netService = nil;
  CFSocketInvalidate(ipv4socket);
  CFSocketInvalidate(ipv6socket);
  CFRelease(ipv4socket);
  CFRelease(ipv6socket);
  ipv4socket = NULL;
  ipv6socket = NULL;

}
- (void) stopBonjour
{
  // Why would you stop bonjour? Honnestly?
  // TODO figure out how to stop the announcement.
}

#pragma mark - Connection management
- (void) addConnection: (HSHTTPConnection*) connection
{
  @synchronized(connections)
  {
    if([connections containsObject: connection])
    {
      return;
    }
  
    [connections addObject: connection];
  }
}

- (void) removeConnection: (HSHTTPConnection*) connection
{
  @synchronized(connections)
  {
    if(![connections containsObject: connection])
    {
      return;
    }
  
    [connections removeObject: connection];
  }  
}

- (void)handleNewConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr 
{
  // GCD this, so we can process multiple in parallel
  [operationQueue addOperationWithBlock:^(void) {
    HSHTTPConnection *connection = [[[HSHTTPConnection alloc] initWithPeerAddress:addr inputStream:istr outputStream:ostr forServer:self andRegistry:handlerRegistry] autorelease];
    if( connection ) 
    {
      [self addConnection: connection];
    }
    [connection processRequest];
  }];
}

- (void) connectionHandled: (HSHTTPConnection*) connection
{
  [self removeConnection: connection];
}

#pragma mark - NSNetServiceDelegate methods
- (void) netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
  NSLog(@"Could not start net service:");
  for(NSString *key in errorDict)
  {
    NSObject *value = [errorDict valueForKey:key];
    NSLog(@"Error: %@ : %@", key, value);
  }
  NSLog(@"NSNetService didNotPublish");
}

- (void) netServiceDidPublish:(NSNetService *)sender
{
  NSLog(@"Bonjour service published.");
}

@end


#pragma mark - Socket callback
// This function is called by CFSocket when a new connection comes in.
// We gather some data here, and convert the function call to a method
// invocation on TCPServer.
static void HTTPServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) 
{
  HSHTTPServe *server = (HSHTTPServe *)info;
  if (kCFSocketAcceptCallBack == type) 
  {  
    // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
    CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
    uint8_t name[SOCK_MAXADDRLEN];
    socklen_t namelen = sizeof(name);
    NSData *peer = nil;
    if (0 == getpeername(nativeSocketHandle, (struct sockaddr *)name, &namelen)) 
    {
      peer = [NSData dataWithBytes:name length:namelen];
    }
    
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
    if (readStream && writeStream) 
    {
      CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
      CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
      [server handleNewConnectionFromAddress:peer inputStream:(NSInputStream *)readStream outputStream:(NSOutputStream *)writeStream];
    } else 
    {
      // on any failure, need to destroy the CFSocketNativeHandle 
      // since we are not going to use it any more
      close(nativeSocketHandle);
    }
    if (readStream)
    {
      CFRelease(readStream); 
    }
    if (writeStream)
    {
      CFRelease(writeStream); 
    }
  }
}
