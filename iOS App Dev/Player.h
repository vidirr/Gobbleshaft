//
//  Tank.h
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/19/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//  Edited by King Gunnar and his minion Vidir.


#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Player : CCPhysicsSprite
{
    ChipmunkSpace *_space;
    
}

- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;
- (void)jumpWithPower:(CGFloat)power vector:(cpVect)vector;
- (void)massiveExplosionSithStyleForceUsageButstillAnImpulse:(CGFloat)power vector:(cpVect)vector;
@end
