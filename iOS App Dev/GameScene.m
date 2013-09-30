//
//  Game.m
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/17/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//  Edited by KingVidir and his minion Gunnar.

#import "GameScene.h"
#import "Player.h"
#import "InputLayer.h"
#import "ChipmunkAutoGeometry.h"
#import "Goal.h"
#import "SimpleAudioEngine.h"
#import "HudLayer.h"
#import "Collectible.h"
#import "GameOverScene.h"

@implementation GameScene

#pragma mark - Initilization

- (id)init
{
    self = [super init];
    if (self)
    {
        
        isGameOver = NO;
        _collectiblesArray = [[NSMutableArray alloc] init];
        _hudLayer = [[HudLayer alloc] initWithConfiguration:_configuration];
        [self addChild:_hudLayer z:8];
        
        srandom(time(NULL));
        _winSize = [CCDirector sharedDirector].winSize;
        
        // Load configuration file
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"]];
        
        // Create physics world
        _space = [[ChipmunkSpace alloc] init];
        CGFloat gravity = [_configuration[@"gravity"] floatValue];
        _space.gravity = ccp(0.0f, -gravity);
        
        // Register collision handler
        [_space setDefaultCollisionHandler:self
                                     begin:@selector(collisionBegan:space:)
                                  preSolve:nil
                                 postSolve:nil
                                  separate:nil];
        
        // Setup world
        [self setupGraphicsLandscape];
        [self setupPhysicsLandscape];
        
        // Create debug node
        CCPhysicsDebugNode *debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
        debugNode.visible = NO;
        [self addChild:debugNode];
        
        // Add a player
        NSString *playerPositionString = _configuration[@"playerPosition"];
        _player = [[Player alloc] initWithSpace:_space position:CGPointFromString(playerPositionString)];
        [_gameNode addChild:_player];
        
        [self addCollectiblesToGameWorld];
        // Add goal
        _goal = [[Goal alloc] initWithSpace:_space position:CGPointFromString(_configuration[@"goalPosition"])];
        [_gameNode addChild:_goal];
        
        // Create a input layer
        InputLayer *inputLayer = [[InputLayer alloc] init];
        inputLayer.delegate = self;
        [self addChild:inputLayer];
        
        // Setup particle system
        _explosionParticles = [CCParticleSystemQuad particleWithFile:@"Explosion.plist"];
        _explosionParticles.position = _goal.position;
        [_explosionParticles stopSystem];
        [_gameNode addChild:_explosionParticles];
        
        // Preload sound effects
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"sound_pikachu.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"sound_coin.wav"];
        
        // Your initilization code goes here
        [self scheduleUpdate];
        _followPlayer = YES;
    }
    return self;
}

- (bool)collisionBegan:(cpArbiter *)arbiter space:(ChipmunkSpace*)space {
    cpBody *firstBody;
    cpBody *secondBody;
    cpArbiterGetBodies(arbiter, &firstBody, &secondBody);
    
    ChipmunkBody *firstChipmunkBody = firstBody->data;
    ChipmunkBody *secondChipmunkBody = secondBody->data;
    
    if ((firstChipmunkBody == _player.chipmunkBody && secondChipmunkBody == _goal.chipmunkBody) ||
        (firstChipmunkBody == _goal.chipmunkBody && secondChipmunkBody == _player.chipmunkBody)){
        NSLog(@"Player HIT pikachu! :D:D:D");
        
        // Play sfx
        [[SimpleAudioEngine sharedEngine] playEffect:@"sound_pikachu.wav" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1];
        
        // Remove physics body
        [_space smartRemove:_player.chipmunkBody];
        for (ChipmunkShape *shape in _player.chipmunkBody.shapes) {
            [_space smartRemove:shape];
        }
        
        // Remove player from cocos2d
        [_player removeFromParentAndCleanup:YES];
        _player = NULL;
        // Play particle effect
        [_explosionParticles resetSystem];
        GameOverScene *gameOverScene = [[GameOverScene alloc] initWithWinOrDeath:YES];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2.0 scene:gameOverScene withColor:ccBLACK]];
        isGameOver = YES;
    }
    
    NSMutableArray *itemsToKeep = [NSMutableArray arrayWithCapacity:[_collectiblesArray count]];
    
    for(Collectible *c in _collectiblesArray) {
        if ((firstChipmunkBody == _player.chipmunkBody && secondChipmunkBody == c.chipmunkBody) ||
            (firstChipmunkBody == c.chipmunkBody && secondChipmunkBody == _player.chipmunkBody)){
            
            // Play sfx
            [[SimpleAudioEngine sharedEngine] playEffect:@"sound_coin.wav" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1];
            
            // Remove physics body
            for (ChipmunkShape *shape in c.chipmunkBody.shapes) {
               [_space smartRemove:shape];
            }
            
            // Remove collectible from cocos2d
            [c removeFromParentAndCleanup:YES];
            
            // Update the score.
            [_hudLayer updateScoreForBonus: 1000];
        }
        else{
            // If we're not colliding with a collectible we want it in the array for the next round.
            [itemsToKeep addObject:c];
        }
    }
    // Update the _collectiblesArray with the remaining collectibles.
    _collectiblesArray = itemsToKeep;
    return YES;
}

- (void)setupGraphicsLandscape
{
    // Set up the sky layer (the sunset gradient in the background).
    _skyLayer = [CCLayerGradient layerWithColor:ccc4(232, 108, 0, 255) fadingTo:ccc4(201, 32, 2, 255)];
    [self addChild:_skyLayer];

    _parallaxNode = [CCParallaxNode node];
    [self addChild:_parallaxNode];
    
    // Add the debug node to the world, default is disabled. Change to YES to see it.
    _debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
    _debugNode.visible = NO;
    [self addChild:_debugNode z:100];
    
    // Create the background skyline which is scrolling behind everything else.
    CCSprite *skylineFar = [CCSprite spriteWithFile:@"skylinefar.png"];
    skylineFar.anchorPoint = ccp(0, 0);
    [_parallaxNode addChild:skylineFar z:0 parallaxRatio:ccp(0.5f, 0.0f) positionOffset:CGPointZero];
    
    // Create the second, nearer skyline which scrolls at a slower pace.
    CCSprite *skylineNear = [CCSprite spriteWithFile:@"skylinenear.png"];
    skylineNear.anchorPoint = ccp(0, 0);
    [_parallaxNode addChild:skylineNear z:1 parallaxRatio:ccp(0.3f, 0.0f) positionOffset:CGPointZero];
    
    // Create the top level border.
    CCSprite *top = [CCSprite spriteWithFile:@"level1top.png"];
    top.anchorPoint = ccp(0, 0);
    _landscapeWidth = top.contentSize.width;
    [_parallaxNode addChild:top z:2 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:ccp(0, 0)];
    
    // Create the bottom level border.
    CCSprite *bottom = [CCSprite spriteWithFile:@"level1bottom.png"];
    bottom.anchorPoint = ccp(0, 0);
    [_parallaxNode addChild: bottom z:3 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
    
    _gameNode = [CCNode node];
    [_parallaxNode addChild:_gameNode z:4 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
}

- (void)setupPhysicsLandscape
{
    //Set up the top of the world.
    NSURL *top = [[NSBundle mainBundle] URLForResource:@"level1top" withExtension:@"png"];
    ChipmunkImageSampler *samplerTop = [ChipmunkImageSampler samplerWithImageFile:top isMask:NO];
    ChipmunkPolylineSet *contourTop = [samplerTop marchAllWithBorder:NO hard:YES];
    ChipmunkPolyline *lineTop = [contourTop lineAtIndex:0];
    ChipmunkPolyline *simpleLineTop = [lineTop simplifyCurves:1];
    
    //Set up the bottom of the world.
    NSURL *bottom = [[NSBundle mainBundle] URLForResource:@"level1bottom" withExtension:@"png"];
    ChipmunkImageSampler *samplerBottom = [ChipmunkImageSampler samplerWithImageFile:bottom isMask:NO];
    ChipmunkPolylineSet *contourBottom = [samplerBottom marchAllWithBorder:NO hard:YES];
    ChipmunkPolyline *lineBottom = [contourBottom lineAtIndex:0];
    ChipmunkPolyline *simpleLineBottom = [lineBottom simplifyCurves:1];
    
    ChipmunkBody *terrainTop = [ChipmunkBody staticBody];
    ChipmunkBody *terrainBottom = [ChipmunkBody staticBody];
    
    NSMutableArray *terrainArray = [[NSMutableArray alloc] init];
    [terrainArray addObject: [simpleLineTop asChipmunkSegmentsWithBody:terrainTop radius:0 offset:cpvzero]];
    [terrainArray addObject: [simpleLineBottom asChipmunkSegmentsWithBody:terrainBottom radius:0 offset:cpvzero]];
    
    // Loop through the each shape in the game, giving friction to each shape and adding them to the gamespace.
    for(NSArray *a in terrainArray) {
        for (ChipmunkShape *shape in a)
        {
            shape.friction = 100;
            [_space addShape:shape];
        }
    }
}

#pragma mark - Update

- (void)update:(ccTime)delta
{
    CGFloat fixedTimeStep = 1.0f / 240.0f;
    _accumulator += delta;
    
    while (_accumulator > fixedTimeStep)
    {
        [_space step:fixedTimeStep];
        _accumulator -= fixedTimeStep;
    }
    if(!isGameOver) {
        //Update the score according to how far the player has travelled in the game.
        [_hudLayer updateScore:_player.position.x];
        
       // NSLog(NSStringFromCGPoint(_parallaxNode.position));
        if( (_parallaxNode.position.x - _winSize.width) < -2400) {
            GameOverScene *gameOverScene = [[GameOverScene alloc] initWithWinOrDeath:NO];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2.0 scene:gameOverScene withColor:ccBLACK]];
            isGameOver = YES;
            return;
        }
        else if( _player.position.x > -(_parallaxNode.position.x) + (_winSize.width - 180))
        {
            _parallaxNode.position = ccp(-(_player.position.x - (_winSize.width - 180)), 0);
        }
        else if(_player.position.x < -(_parallaxNode.position.x)) {
            GameOverScene *gameOverScene = [[GameOverScene alloc] initWithWinOrDeath:NO];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2.0 scene:gameOverScene withColor:ccBLACK]];
            isGameOver = YES;
        }
        else {
            CGPoint foo = _parallaxNode.position;
            //NSLog(@"_parralaxNode before: %@", NSStringFromCGPoint(_parallaxNode.position));
            _parallaxNode.position = ccp((foo.x - (40 * delta )), 0);
            //NSLog(@"_parralaxNode after: %@", NSStringFromCGPoint(_parallaxNode.position));
        }
    }
    
}

- (void) addCollectiblesToGameWorld{
    
    // Create collectibles (manual positions for now) and add them to an array.
    [_collectiblesArray addObject:[[Collectible alloc] initWithSpace:_space position:ccp(500.0f, 57.0f)]];
    [_collectiblesArray addObject:[[Collectible alloc] initWithSpace:_space position:ccp(700.0f, 76.0f)]];
    [_collectiblesArray addObject:[[Collectible alloc] initWithSpace:_space position:ccp(900.0f, 110.0f)]];
    [_collectiblesArray addObject:[[Collectible alloc] initWithSpace:_space position:ccp(1100.0f, 113.0f)]];
    [_collectiblesArray addObject:[[Collectible alloc] initWithSpace:_space position:ccp(1400.0f, 70.0f)]];
    [_collectiblesArray addObject:[[Collectible alloc] initWithSpace:_space position:ccp(1550.0f, 80.0f)]];
    [_collectiblesArray addObject:[[Collectible alloc] initWithSpace:_space position:ccp(1700.0f, 185.0f)]];
    [_collectiblesArray addObject:[[Collectible alloc] initWithSpace:_space position:ccp(1900.0f, 75.0f)]];
    
    // Loop through the array and add each collectible to the gamenode.
    for(Collectible *c in _collectiblesArray) {
        [_gameNode addChild:c];
    }

}

#pragma mark - My Touch Delegate Methods

- (void)touchEndedAtPositon:(CGPoint)position afterDelay:(NSTimeInterval)delay
{
    position = [_gameNode convertToNodeSpace:position];
    NSLog(@"touch: %@", NSStringFromCGPoint(position));
    NSLog(@"Player: %@", NSStringFromCGPoint(_player.position));

    
    cpVect upVector = cpv(0, 1);
    [_player jumpWithPower:delay * 300 vector:upVector];
}

@end
