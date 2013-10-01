//
//  HudLayer.m
//  iOS App Dev
//
//  Created by HR Schoolsen on 9/29/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//  Edited by King Gunnar and his minion Vidir.

#import "HudLayer.h"

@implementation HudLayer

- (id)initWithConfiguration:(NSDictionary *)configuration
{
    self = [super init];
    if (self != nil)
    {
        score = 0;
        // create and initialize a Label
        scoreLabel = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"ArialMT" fontSize:12.0f];
        [scoreLabel setPosition:ccp(50, 300)];
        NSString *stringScore = [NSString stringWithFormat:@"Score %i", score];
        [scoreLabel setString:stringScore];
        [self addChild:scoreLabel];
    }
    
    return self;
}

-(void)updateScore : (int)val
{
    val -= 300;
    if(val > lastPosition) {
        val *= 0.1;
        score += val - lastPosition;
        lastPosition = val;
    }

    NSString *x = [NSString stringWithFormat:@"Score: %i", score];
    [scoreLabel setString:x];
}

-(void)updateScoreForBonus : (int)val
{
    score += val;
    NSString *x = [NSString stringWithFormat:@"Score: %i", score];
    [scoreLabel setString:x];
}

@end
