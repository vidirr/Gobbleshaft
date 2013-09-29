//
//  Collectible.m
//  iOS App Dev
//
//  Created by HR Schoolsen on 9/29/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Collectible.h"

@implementation Collectible

- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position
{
    self = [super initWithFile:@"collectible_bag.png"];
    if (self) {
        CGSize size = self.textureRect.size;
        
        // Create body and shape
        ChipmunkBody *body = [ChipmunkBody staticBody];
        body.pos = position;
        ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:size.width height:size.height/8];
        shape.sensor = YES;
        
        // Add to world
        [space addShape:shape];
        
        // Add self to body and body to self
        body.data = self;
        self.chipmunkBody = body;
    }
    return self;
}

@end
