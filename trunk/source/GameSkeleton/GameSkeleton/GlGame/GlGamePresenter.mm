//
//  GlGamePresenter.m
//  GameSkelton
//
//  Created by Nobuhiro Kuroiwa on 12/03/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GlGamePresenter.h"
#import "GlBasePresentee.h"
#import "CommonUtility.h"
#import "GroundPine.h"
#import "LivingRoom.h"
#include <vector>

const NSString* GlGameLock = @"GlGameLock";
const GLKVector3 PLAYER_BASE_TRANS = {0.0, -1.0, 1.5};
const GLfloat PLAYER_BASE_ROTX = 10.0/180.0 * M_PI;

using namespace std;

typedef enum GAMESTATE
{
    IDLE,
    PLAYING,
    FINISHED,
} GameState;

@interface GlGamePresenter()
{
    Ground *_ground;
    Background *_background;
    NSTimeInterval time;
    int bonus;
    int _stage;

    GLKMatrix4 _baseModelViewMatrix;
    
    GameState _gameState;
    //TimeKeeper *_timeKeeper;
}

@property (nonatomic, readwrite, strong) NSArray* presentees;

@end


@implementation GlGamePresenter

@synthesize presentees;
@synthesize time;
@synthesize score;
@synthesize bonus;

- (id)init {
    self = [super init];
    [CommonUtility nilToFail:self reason:@"super of GlGamePresenter init failed"];

    _gameState = IDLE;

    time = 0.0;
    bonus = 0;
    _stage = 0;

    return self;
}

- (void)setupGLForStage:(int)stage {
    [self updateBaseViewMatrix:&_baseModelViewMatrix withTgtPos:ZERO_VECTOR3 andAng:0.0];

    _stage = stage;
    NSMutableArray* arr = [NSMutableArray arrayWithObjects: nil];
    _ground = [[GroundPine alloc] init];
    _background = [[LivingRoom alloc] init];
    
    [arr addObject:_ground];
    [arr addObject:_background];
    
    if(_ground)
        [_ground setupGLWithBaseModelViewMatPtr:&_baseModelViewMatrix];
    if(_background)
        [_background setupGLWithBaseModelViewMatPtr:&_baseModelViewMatrix];
    
    self.presentees = arr;

    // inint sound engine
    [self setupAL];

    // init ski engine
}

- (void)setupAL {
}

- (void)tearDownGL {

    @synchronized(GlGameLock) {

        [_ground tearDownGL];
    }
}

- (void)touchesBegan:(NSSet *)touches proj:(const GLKMatrix4*)pProj view:(UIView*)view {
}

- (void)touchesMoved:(NSSet *)touches proj:(const GLKMatrix4*)pProj view:(UIView*)view {
    @synchronized(GlGameLock) {
    }
}

- (void)touchesEnded:(NSSet *)touches proj:(const GLKMatrix4*)pProj {
}

- (void)updateBaseViewMatrix:(GLKMatrix4*)pMat withTgtPos:(GLKVector3)pos andAng:(GLfloat)ang {
    
    GLKMatrix4 rot_x30 = GLKMatrix4RotateX(GLKMatrix4Identity, PLAYER_BASE_ROTX);
    GLKMatrix4 rot_ang = GLKMatrix4RotateY(rot_x30, M_PI-ang);
    GLKVector3 baseTrans = GLKMatrix3MultiplyVector3(GLKMatrix3MakeYRotation(ang), PLAYER_BASE_TRANS);
    GLKVector3 transVec = GLKVector3Subtract(baseTrans, pos);
    GLKMatrix4 transMat = GLKMatrix4TranslateWithVector3(rot_ang, transVec);
    
    GLKMatrix4 replace = transMat;
    @synchronized(GlGameLock) {
        memcpy(pMat, &replace, sizeof(GLKMatrix4));
    }
}

- (void)updateSolution {
}

- (void)updateWithTimeSinceLastUpdate:(NSTimeInterval)timeSinceLastUpdate {

    @synchronized(GlGameLock) {

        if(_ground) {
            [_ground setPlayerPos:ZERO_VECTOR3];
            [_ground updateWithTimeSinceLastUpdate:timeSinceLastUpdate];
        }
        
        [_background setPos:ZERO_VECTOR3];
        [_background updateWithTimeSinceLastUpdate:timeSinceLastUpdate];
    }
}

- (GameResult*)getResult {
    return nil;
}

@end