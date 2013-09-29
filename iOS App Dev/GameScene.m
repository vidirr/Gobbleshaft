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

@implementation GameScene

#pragma mark - Initilization

- (id)init
{
    self = [super init];
    if (self)
    {
        
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
        
        // Add a tank
        NSString *playerPositionString = _configuration[@"tankPosition"];
        _player = [[Player alloc] initWithSpace:_space position:CGPointFromString(playerPositionString)];
        [_gameNode addChild:_player];
        
        [self addCollectiblesToGameWorld];
        // Add goal
        //_goal = [[Goal alloc] initWithSpace:_space position:CGPointFromString(_configuration[@"goalPosition"])];
        //[_gameNode addChild:_goal];
        
        // Create a input layer
        InputLayer *inputLayer = [[InputLayer alloc] init];
        inputLayer.delegate = self;
        [self addChild:inputLayer];
        
        // Setup particle system
        ////_splashParticles = [CCParticleSystemQuad particleWithFile:@"WaterSplash.plist"];
        //[_splashParticles stopSystem];
        //[_gameNode addChild:_splashParticles];
        
        // Preload sound effects
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Impact.wav"];
        
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
    
    for(Collectible *c in _collectiblesArray) {
        
    if ((firstChipmunkBody == _player.chipmunkBody && secondChipmunkBody == c.chipmunkBody) ||
        (firstChipmunkBody == c.chipmunkBody && secondChipmunkBody == _player.chipmunkBody)){
        
        // Play sfx
        //[[SimpleAudioEngine sharedEngine] playEffect:@"Impact.wav" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1];
        
        // Remove physics body
        //[_space smartRemove: c.chipmunkBody];
        //for (ChipmunkShape *shape in c.chipmunkBody.shapes) {
        //   [_space smartRemove:shape];
        //}
        
        // Remove collectible from cocos2d
        [c removeFromParentAndCleanup:YES];
        
        [_hudLayer updateScoreForBonus: 1000];
        // Play particle effect
        //[_splashParticles resetSystem];
    }
    }
    return YES;
}

- (void)setupGraphicsLandscape
{
    // Sky
    
    _skyLayer = [CCLayerGradient layerWithColor:ccc4(232, 108, 0, 255) fadingTo:ccc4(201, 32, 2, 255)];
    [self addChild:_skyLayer];
    /*
    for (NSUInteger i = 0; i < 4; ++i)
    {
        CCSprite *cloud = [CCSprite spriteWithFile:@"Cloud.png"];
        cloud.position = ccp(CCRANDOM_0_1() * _winSize.width, (CCRANDOM_0_1() * 200) + _winSize.height / 2);
        [_skyLayer addChild:cloud];
    }
    */
    _parallaxNode = [CCParallaxNode node];
    [self addChild:_parallaxNode];
    
    _debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
    _debugNode.visible = NO;
    [self addChild:_debugNode z:100];
    
    CCSprite *skylineFar = [CCSprite spriteWithFile:@"skylinefar.png"];
    skylineFar.anchorPoint = ccp(0, 0);
    [_parallaxNode addChild:skylineFar z:0 parallaxRatio:ccp(0.5f, 0.0f) positionOffset:CGPointZero];
    
    CCSprite *skylineNear = [CCSprite spriteWithFile:@"skylinenear.png"];
    skylineNear.anchorPoint = ccp(0, 0);
    [_parallaxNode addChild:skylineNear z:1 parallaxRatio:ccp(0.3f, 0.0f) positionOffset:CGPointZero];
    
    CCSprite *top = [CCSprite spriteWithFile:@"level1top.png"];
    top.anchorPoint = ccp(0, 0);
    _landscapeWidth = top.contentSize.width;
    [_parallaxNode addChild:top z:2 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:ccp(0, 0)];
    
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
    terrainTop.pos = ccp(0, 0);
    ChipmunkBody *terrainBottom = [ChipmunkBody staticBody];
    
    NSMutableArray *terrainArray = [[NSMutableArray alloc] init];
    
    [terrainArray addObject: [simpleLineTop asChipmunkSegmentsWithBody:terrainTop radius:0 offset:cpvzero]];
    [terrainArray addObject: [simpleLineBottom asChipmunkSegmentsWithBody:terrainBottom radius:0 offset:cpvzero]];
    
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

    //Update the score
    [_hudLayer updateScore:_player.position.x];
    
    //if (_followPlayer == YES)
    
    if( _player.position.x > -(_parallaxNode.position.x) + (_winSize.width - 100))
    {
        NSLog(@"Updating screen position %f %f", _player.position.x, _parallaxNode.position.x);
        _parallaxNode.position = ccp(_parallaxNode.position.x - (140 * delta), 0);
    }
    else {
    CGPoint foo = _parallaxNode.position;
        //NSLog(@"_parralaxNode before: %@", NSStringFromCGPoint(_parallaxNode.position));
        _parallaxNode.position = ccp((foo.x - (20 * delta )), 0);
        //NSLog(@"_parralaxNode after: %@", NSStringFromCGPoint(_parallaxNode.position));
    }
    
}

- (void) addCollectiblesToGameWorld{
    
    // Add collectibles
    Collectible *c0 = [[Collectible alloc] initWithSpace:_space position:ccp(300.0f, 150.0f)];
    Collectible *c1 = [[Collectible alloc] initWithSpace:_space position:ccp(400.0f, 160.0f)];
    Collectible *c2 = [[Collectible alloc] initWithSpace:_space position:ccp(500.0f, 180.0f)];
    Collectible *c3 = [[Collectible alloc] initWithSpace:_space position:ccp(300.0f, 130.0f)];
    
    [_gameNode addChild:c0];
    [_gameNode addChild:c1];
    [_gameNode addChild:c2];
    [_gameNode addChild:c3];
    
    [_collectiblesArray addObject: c0];
    [_collectiblesArray addObject: c1];
    [_collectiblesArray addObject: c2];
    [_collectiblesArray addObject: c3];

}

#pragma mark - My Touch Delegate Methods

- (void)touchEndedAtPositon:(CGPoint)position afterDelay:(NSTimeInterval)delay
{
    position = [_gameNode convertToNodeSpace:position];
    NSLog(@"touch: %@", NSStringFromCGPoint(position));
    NSLog(@"tank: %@", NSStringFromCGPoint(_player.position));

    
    cpVect upVector = cpv(0, 1);
    [_player jumpWithPower:delay * 300 vector:upVector];
}

@end
