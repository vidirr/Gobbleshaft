//
//  MenuScene.m
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/24/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "MenuScene.h"
#import "cocos2d.h"
#import "GameScene.h"

@implementation MenuScene

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"PLAY \n GOBBLESHAFT!" fontName:@"Arial" fontSize:42];
        CCMenuItemLabel *button = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
        {
            GameScene *gameScene = [[GameScene alloc] init];
            [[CCDirector sharedDirector] replaceScene:gameScene];
        }];
        button.position = ccp(size.width/2, size.height/2);
        
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
    }
    
    return self;
}

@end
