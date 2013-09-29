//
//  Tank.m
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/19/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Player.h"

const float MAX_RIGHT_LATERAL = 140;

@implementation Player

- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;
{
    self = [super initWithFile:@"squash.png"];
    if (self)
    {
        _space = space;
        
        if (_space != nil)
        {
            CGSize size = self.textureRect.size;
            cpFloat mass = size.width * size.height;
            cpFloat moment = cpMomentForBox(mass, size.width, size.height);
            
            ChipmunkBody *body = [ChipmunkBody bodyWithMass:mass andMoment:moment];
            body.pos = position;
            ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:body radius:size.width/2-5 offset:cpvzero];
            //ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:size.width height:size.height];
            shape.friction = 100;
            
            // Add to space
            [_space addBody:body];
            [_space addShape:shape];
            
            // Add to pysics sprite
            self.chipmunkBody = body;
            //self.chipmunkBody.velLimit = 200.0f;
            //cpVect lateralRight = cpv(1, 0);
            

        }
    }
    return self;
}

- (void)jumpWithPower:(CGFloat)power vector:(cpVect)vector
{
    cpVect impulseVectorWithLateral = cpvmult(ccp(0.7f, 1), self.chipmunkBody.mass * power);
    cpVect impulseVectorJump = cpvmult(ccp(0,1), self.chipmunkBody.mass * power);
    
    //If we haven't reached max velocity on the x-axis we apply the impulse on up and right.
    if(self.chipmunkBody.vel.x < MAX_RIGHT_LATERAL) [self.chipmunkBody applyImpulse:impulseVectorWithLateral offset:cpvzero];
    //If not we just apply on up.
    else [self.chipmunkBody applyImpulse:impulseVectorJump offset:cpvzero];
    
}

@end
