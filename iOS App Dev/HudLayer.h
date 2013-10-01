//
//  HudLayer.h
//  iOS App Dev
//
//  Created by HR Schoolsen on 9/29/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//  Edited by King Gunnar and his minion Vidir.


#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface HudLayer : CCLayer
{
    CCLabelTTF *scoreLabel;
    int score;
    int lastPosition;
}

- (id)initWithConfiguration:(NSDictionary *)configuration;

-(void)updateScore : (int)val;
-(void)updateScoreForBonus : (int)val;

@end
