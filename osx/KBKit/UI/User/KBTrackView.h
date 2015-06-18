//
//  KBTrackView.h
//  Keybase
//
//  Created by Gabriel on 1/26/15.
//  Copyright (c) 2015 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <KBAppKit/KBAppKit.h>
#import "KBRPC.h"

#import "KBUserTrackStatus.h"

typedef void (^KBTrackCompletion)(BOOL track); // track is NO if skipped

@interface KBTrackView : YOView

@property (readonly) KBButton *untrackButton;

- (void)setTrackStatus:(KBUserTrackStatus *)trackStatus skipable:(BOOL)skipable completion:(KBTrackCompletion)completion;

- (void)setTrackAction:(KBTrackAction)trackAction error:(NSError *)error;

- (void)clear;

@end
