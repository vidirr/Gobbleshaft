//
//  ScoreManager.h
//  iOS App Dev
//
//  Created by HR Schoolsen on 9/29/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <foundation/Foundation.h>

@interface ScoreManager : NSObject {
    float score;
}

@property (nonatomic, readwrite) int score;

+ (id)sharedScoreManager;

-(void)addScore : (int)val;
@end