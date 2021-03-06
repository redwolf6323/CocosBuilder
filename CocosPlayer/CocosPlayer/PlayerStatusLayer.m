//
//  PlayerStatusLayer.m
//  CocosPlayer
//
//  Created by Viktor Lidholt on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerStatusLayer.h"
#import "CCBReader.h"
#import "AppController.h"
#import "ServerController.h"

static PlayerStatusLayer* sharedPlayerStatusLayer = NULL;

@implementation PlayerStatusLayer

+ (PlayerStatusLayer*) sharedInstance
{
    return sharedPlayerStatusLayer;
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    sharedPlayerStatusLayer = self;
    
    return self;
}

- (void) updatePairingLabel
{
    NSString* pairing = [[NSUserDefaults standardUserDefaults] objectForKey:@"pairing"];
    
    if (!pairing) pairing = @"Auto";
    lblPair.string = pairing;
}

- (void) didLoadFromCCB
{
    [lblStatus setString:kCCBStatusStringWaiting];
    [self updatePairingLabel];
}

- (void) setStatus:(NSString*)status
{
    [lblStatus setString:status];
    
    // Hide instructions if connected
    lblInstructions.visible = ![status isEqualToString:kCCBStatusStringConnected];
}


- (void) onEnter
{
    [super onEnter];
    
    // Update status of buttons
    
    // Enable Run & Reset btn if main.js exists
    NSString* mainJSPath = [[CCBReader ccbDirectoryPath] stringByAppendingPathComponent:@"main.js"];
    BOOL mainExist = [[NSFileManager defaultManager] fileExistsAtPath:mainJSPath];
    btnRun.isEnabled = mainExist;
    btnReset.isEnabled = mainExist;
}

- (void) pressedRun:(id)sender
{
    [[AppController appController] runJSApp];
}

- (void) pressedReset:(id)sender
{
}

- (void) pressedPair:(id)sender
{
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Pair Device" message:@"Enter a 4 digit pairing number (use the same number in CocosBuilder)" delegate:self cancelButtonTitle:@"Remove" otherButtonTitles:@"Set Pairing", nil] autorelease];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField* textField = [alert textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.delegate = self;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* pairing = NULL;
    if (buttonIndex == 1)
    {
        UITextField* textField = [alertView textFieldAtIndex:0];
        pairing = textField.text;
        if ([pairing isEqualToString:@""]) pairing = NULL;
    }
    
    if (pairing)
    {
        [[NSUserDefaults standardUserDefaults] setObject:pairing forKey:@"pairing"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pairing"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updatePairingLabel];
    [[AppController appController] updatePairing];
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 
{
    // Validate string length
    NSUInteger newLength = [theTextField.text length] + [string length] - range.length;
    if (newLength > 4) return NO;
    
    // Make sure it only uses numbers
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if (![myCharSet characterIsMember:c]) {
            return NO;
        }
    }
    
    return YES;
}

@end
