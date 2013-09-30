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
#import "ScoreManager.h"
#import "HudLayer.h"
#import "Collectible.h"

@class Player;
@class Goal;
@interface GameScene : CCScene <InputLayerDelegate>
{
    CGSize _winSize;
    NSDictionary *_configuration;
    CCLayerGradient *_skyLayer;
    Player *_player;
    Goal *_goal;
    ChipmunkSpace *_space;
    ccTime _accumulator;
    CCParallaxNode *_parallaxNode;
    CCParticleSystemQuad *_explosionParticles;
    CCNode *_gameNode;
    CCPhysicsDebugNode *_debugNode;
    BOOL _followPlayer;
    CGFloat _landscapeWidth;
    HudLayer *_hudLayer;
    NSMutableArray *_collectiblesArray;
    BOOL isGameOver;
    
}

@end
