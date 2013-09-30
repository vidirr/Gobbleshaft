//
//  GameOverScene.m
//  iOS App Dev
//
//  Created by HR Schoolsen on 9/30/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "GameOverScene.h"
#import "cocos2d.h"
#import "GameScene.h"

@implementation GameOverScene

- (id)initWithWinOrDeath:(BOOL) win;
{
    self = [super init];
    if (self != nil)
    {
        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF *label;
        if(!win) {
            label = [CCLabelTTF labelWithString:@"YOU DIE MAN! \nCLICK TO \nPLAY AGAIN" fontName:@"Arial" fontSize:40];
        }
        else {
          label = [CCLabelTTF labelWithString:@"YOU WIN MAN! \nCLICK TO \nPLAY AGAIN" fontName:@"Arial" fontSize:40];
        }
        
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
