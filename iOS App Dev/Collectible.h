//
//  Collectible.h
//  iOS App Dev
//
//  Created by HR Schoolsen on 9/29/13.
//  Edited by King Gunnar and his minion Vidir.


#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Collectible : CCPhysicsSprite {
    
}

- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;

@end
