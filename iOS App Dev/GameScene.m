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

@implementation GameScene

#pragma mark - Initilization

- (id)init
{
    self = [super init];
    if (self)
    {
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
        NSString *tankPositionString = _configuration[@"tankPosition"];
        _tank = [[Player alloc] initWithSpace:_space position:CGPointFromString(tankPositionString)];
        [_gameNode addChild:_tank];
        
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
        _followTank = YES;
    }
    return self;
}

- (bool)collisionBegan:(cpArbiter *)arbiter space:(ChipmunkSpace*)space {
    cpBody *firstBody;
    cpBody *secondBody;
    cpArbiterGetBodies(arbiter, &firstBody, &secondBody);
    
    ChipmunkBody *firstChipmunkBody = firstBody->data;
    ChipmunkBody *secondChipmunkBody = secondBody->data;
    
    /*if ((firstChipmunkBody == _tank.chipmunkBody && secondChipmunkBody == _goal.chipmunkBody) ||
        (firstChipmunkBody == _goal.chipmunkBody && secondChipmunkBody == _tank.chipmunkBody)){
        NSLog(@"TANK HIT GOAL :D:D:D xoxoxo");
        
        // Play sfx
        [[SimpleAudioEngine sharedEngine] playEffect:@"Impact.wav" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1];
        
        // Remove physics body
        [_space smartRemove:_tank.chipmunkBody];
        for (ChipmunkShape *shape in _tank.chipmunkBody.shapes) {
            [_space smartRemove:shape];
        }
        
        // Remove tank from cocos2d
        [_tank removeFromParentAndCleanup:YES];
        
        // Play particle effect
        [_splashParticles resetSystem];
    }*/
    
    return YES;
}

- (void)setupGraphicsLandscape
{
    // Sky
    
    //_skyLayer = [CCLayerGradient layerWithColor:ccc4(89, 67, 245, 255) fadingTo:ccc4(67, 219, 245, 255)];
    //[self addChild:_skyLayer];
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
    _debugNode.visible = YES;
    [self addChild:_debugNode z:100];
    
    CCSprite *cave = [CCSprite spriteWithFile:@"space.jpg"];
    cave.anchorPoint = ccp(0, 0);
    [_parallaxNode addChild:cave z:0 parallaxRatio:ccp(0.5f, 0.0f) positionOffset:CGPointZero];
    
    CCSprite *top = [CCSprite spriteWithFile:@"_top.png"];
    top.anchorPoint = ccp(0, 0);
    _landscapeWidth = top.contentSize.width;
    [_parallaxNode addChild:top z:0 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:ccp(0, 200)];
    
    CCSprite *bottom = [CCSprite spriteWithFile:@"_bottom.png"];
    bottom.anchorPoint = ccp(0, 0);
    [_parallaxNode addChild: bottom z:0 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
    

    
    _gameNode = [CCNode node];
    [_parallaxNode addChild:_gameNode z:1 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
}

- (void)setupPhysicsLandscape
{
    NSURL *top = [[NSBundle mainBundle] URLForResource:@"_top" withExtension:@"png"];
    ChipmunkImageSampler *samplerTop = [ChipmunkImageSampler samplerWithImageFile:top isMask:NO];
    ChipmunkPolylineSet *contourTop = [samplerTop marchAllWithBorder:NO hard:YES];
    ChipmunkPolyline *lineTop = [contourTop lineAtIndex:0];
    ChipmunkPolyline *simpleLineTop = [lineTop simplifyCurves:1];
    
    NSURL *bottom = [[NSBundle mainBundle] URLForResource:@"_bottom" withExtension:@"png"];
    ChipmunkImageSampler *samplerBottom = [ChipmunkImageSampler samplerWithImageFile:bottom isMask:NO];
    ChipmunkPolylineSet *contourBottom = [samplerBottom marchAllWithBorder:NO hard:YES];
    ChipmunkPolyline *lineBottom = [contourBottom lineAtIndex:0];
    ChipmunkPolyline *simpleLineBottom = [lineBottom simplifyCurves:1];
    
    
    ChipmunkBody *terrainTop = [ChipmunkBody staticBody];
    terrainTop.pos = ccp(0, 200);
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
    
    
    [_tank applyLateralRight];
   
    while (_accumulator > fixedTimeStep)
    {
        [_space step:fixedTimeStep];
        _accumulator -= fixedTimeStep;
    }
    /*
    for (CCSprite *cloud in _skyLayer.children)
    {
        CGFloat cloudHalfWidth = cloud.contentSize.width / 2;
        CGPoint newPosition = ccp(cloud.position.x + (_windSpeed * delta), cloud.position.y);
        if (newPosition.x < -cloudHalfWidth)
        {
            newPosition.x = _skyLayer.contentSize.width + cloudHalfWidth;
        }
        else if (newPosition.x > (_skyLayer.contentSize.width + cloudHalfWidth))
        {
            newPosition.x = -cloudHalfWidth;
        }

        
        cloud.position = newPosition;
    }*/
    
    if (_followTank == YES)
    {
        //if (_tank.position.x >= (_winSize.width / 2) && _tank.position.x < (_landscapeWidth - (_winSize.width / 2)))
        //{
            _parallaxNode.position = ccp(-(_tank.position.x - (_winSize.width / 2)), 0);
        //}
    }
}

-(CCSprite *)spriteWithColor:(ccColor4F)bgColor textureWidth:(float)textureWidth textureHeight:(float)textureHeight {
    
    // 1: Create new CCRenderTexture
    CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureWidth height:textureHeight];
    
    // 2: Call CCRenderTexture:begin
    [rt beginWithClear:bgColor.r g:bgColor.g b:bgColor.b a:bgColor.a];
    
    // 3: Draw into the texture
    // You'll add this later
    
    // 4: Call CCRenderTexture:end
    [rt end];
    
    // 5: Create a new Sprite from the texture
    return [CCSprite spriteWithTexture:rt.sprite.texture];
}

- (ccColor4F)randomBrightColor {
    
    while (true) {
        float requiredBrightness = 192;
        ccColor4B randomColor =
        ccc4(arc4random() % 255,
             arc4random() % 255,
             arc4random() % 255,
             255);
        if (randomColor.r > requiredBrightness ||
            randomColor.g > requiredBrightness ||
            randomColor.b > requiredBrightness) {
            return ccc4FFromccc4B(randomColor);
        }
    }
    
}

#pragma mark - My Touch Delegate Methods

- (void)touchEndedAtPositon:(CGPoint)position afterDelay:(NSTimeInterval)delay
{
    position = [_gameNode convertToNodeSpace:position];
    NSLog(@"touch: %@", NSStringFromCGPoint(position));
    NSLog(@"tank: %@", NSStringFromCGPoint(_tank.position));

    
    cpVect upVector = cpv(0, 1);
    [_tank jumpWithPower:delay * 300 vector:upVector];
}

@end
