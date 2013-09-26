//
//  Game.h
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/17/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "InputLayer.h"

@class Player;
@class Goal;
@interface GameScene : CCScene <InputLayerDelegate>
{
    CGSize _winSize;
    NSDictionary *_configuration;
    CCLayerGradient *_skyLayer;
    CGFloat _windSpeed;
    Player *_tank;
    Goal *_goal;
    ChipmunkSpace *_space;
    ccTime _accumulator;
    CCParallaxNode *_parallaxNode;
    CCParticleSystemQuad *_splashParticles;
    CCNode *_gameNode;
    CCPhysicsDebugNode *_debugNode;
    BOOL _followTank;
    CGFloat _landscapeWidth;
    CGFloat _caveWidth;
}

@end
