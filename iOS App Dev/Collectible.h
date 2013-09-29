//
//  Collectible.h
//  iOS App Dev
//
//  Created by HR Schoolsen on 9/29/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Collectible : CCPhysicsSprite {
    
}

- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;

@end
