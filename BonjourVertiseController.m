//
//  BonjourVertiseController.m
//  BonjourVertise
//
//  Created by PJ Gray on 9/27/10.
//  Copyright 2010 Say Goodnight Software. All rights reserved.
//

#import "BonjourVertiseController.h"
#import "dns_sd.h"
#include <arpa/inet.h>
#include <ifaddrs.h> 
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

@implementation BonjourVertiseController

- (NSString*) getHostnameWithIP:(const char*) inIPAddress {
    const char *port = NULL;
    int socktype = SOCK_STREAM;
	
    struct addrinfo hints;
    struct addrinfo* res = NULL;
    int error;
	
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = socktype;
    hints.ai_flags = 0;
	
    error = getaddrinfo(inIPAddress, port, &hints, &res);
	
    if (error) {
        fprintf(stderr, "sock_addrinfo: error=%d: %s\n",
                error, gai_strerror(error));
		return 0;
    }
	
    if (res) {
		char hostbuf[NI_MAXHOST] = "???";
        error = getnameinfo(res->ai_addr, res->ai_addrlen,
                            hostbuf, sizeof(hostbuf), NULL, 0, 0);
        freeaddrinfo(res);
		
		return [NSString stringWithUTF8String:hostbuf];
    }
	return 0;
}

- (void) scanForPortWithMin:(int) minValue withMax:(int) maxValue {
	[scanProgress setMinValue:minValue];
	[scanProgress setMaxValue:maxValue];
	[scanProgress setDoubleValue:minValue];
	[scanProgress startAnimation: self];
	int i;
	const char* ipaddress = [[ipAddress stringValue] UTF8String];
	for (i=minValue;i<maxValue;i++) {
		int theSocket;
		[scanProgress setDoubleValue:i];
		struct sockaddr_in serverAddress;
		
		if ( (theSocket = socket( AF_INET, SOCK_STREAM, 0 )) < 0 ) {
			NSLog(@"socket error");
		} 
		
		bzero( &serverAddress, sizeof(serverAddress) );
		serverAddress.sin_family = AF_INET;
		inet_pton( AF_INET, ipaddress, &serverAddress.sin_addr );
		serverAddress.sin_port = htons( i );
		
		
		if ( connect( theSocket, (struct sockaddr *)&serverAddress, sizeof(serverAddress)) >= 0 ) {
			[portNumber setStringValue:[NSString stringWithFormat:@"%d",i]];
			close(theSocket);
			break;
		}
	}
	[scanProgress stopAnimation: self];
}

- (void) portScanThread {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // Top-level pool
	[self scanForPortWithMin:65000 withMax:65535];  // typical range for iPhone
	[self scanForPortWithMin:49000 withMax:65000];  // typical range for iPad
	[pool release];
}

- (IBAction) scanClicked:(id) sender {
	[NSThread detachNewThreadSelector:@selector(portScanThread) toTarget:self withObject:nil];
}

- (IBAction) advertiseClicked:(id) sender {
	
	DNSServiceRef register_svc;
    DNSServiceErrorType err;
	NSString* hostname = [self getHostnameWithIP:[[ipAddress stringValue] UTF8String]];
	err = DNSServiceRegister(&register_svc,
                             0 ,
                             0 ,
                             [hostname UTF8String],
                             [[bonjourType stringValue] UTF8String],
                             NULL,
                             [hostname UTF8String],
                             htons([portNumber intValue]),
                             0,
                             NULL,
                             NULL,
                             NULL);
	
	if (err != kDNSServiceErr_NoError) {
        NSLog(@"error in DNSServiceRegister");
    }
}

@end
