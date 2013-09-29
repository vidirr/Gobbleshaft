//
//  ScoreManager.m
//  iOS App Dev
//
//  Created by HR Schoolsen on 9/29/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "ScoreManager.h"

static ScoreManager *sharedScoreManager = nil;

@implementation ScoreManager

@synthesize score;

+ (id)sharedScoreManager {
    @synchronized(self) {
        if(sharedScoreManager == nil)
            sharedScoreManager = [[super allocWithZone:NULL] init];
    }
    sharedScoreManager.score = 0;
    return sharedScoreManager;
}

-(void)addScore : (int)val
{
    score = (val - 300) * 0.01f;
    //if(score > 9000) {
    //    // TODO: something awesome
   // }
}

@end