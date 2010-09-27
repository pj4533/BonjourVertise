//
//  BonjourVertiseController.h
//  BonjourVertise
//
//  Created by PJ Gray on 9/27/10.
//  Copyright 2010 Say Goodnight Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BonjourVertiseController : NSObject {

	IBOutlet NSTextField* ipAddress;
	IBOutlet NSTextField* portNumber;
	IBOutlet NSTextField* bonjourType;
	IBOutlet NSProgressIndicator* scanProgress;	
}

- (void) scanForPortWithMin:(int) minValue withMax:(int) maxValue;
- (void) portScanThread;

- (IBAction) scanClicked:(id) sender;
- (IBAction) advertiseClicked:(id) sender;

@end
