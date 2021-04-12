//
//  LFMessageHandler.m
//  GroundSdkDemo
//
//  Created by David Dvergsten on 2/13/21.
//  Copyright © 2021 Parrot SA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LFMessageHandler.h"
//@interface LFMessageHandler
//
//@end
#import "/Users/ddvergsten/XCodeProjects/RespondAR5-14-20PostMergeKEEP/RespondAR/Sample Code/SwiftSampleCode/SmartCam/SmartCam/LFClientWrapper2.h"
//#import "LFClientWrapper.h"
@implementation LFMessageHandler
{
    
}

-(void) VCGetLatLonForScreenXY:(float)screenx andScreenY:(float) screeny
{
    VCGetLatLonForScreenXY(screenx, screeny);

}
-(bool) PDCheckGetLatLon:(float*)screenx _:(float*)screeny
{
    return PDCheckGetLatLon(screenx, screeny);
    //return true;
}
-(void) PDSetLatLonReady:(float)lat _:(float) lon
{
    PDSetLatLonReady(lat, lon);
}
-(bool) VCCheckLatLonReadyLat:(float*)lat Lon:(float*) lon
{
    bool ready = VCCheckLatLonReady(lat, lon);
    return ready;
}
-(void) setXY2:(float)x _:(float) y
{
    setXY2(x, y);
}

-(void)resetXY{
    resetXY2();
}
-(void) getxy2:(float*)x _:(float*)y
{
    getxy2(x, y);
}

//-(void)setX:(float)x andY:(float)y;

-(void)setX:(float)x andY:(float)y{
    NSLog(@"it worked");
    setXY2(x, y);
    float testx = 0.0f;
    float testy = 0.0f;
    getxy2(&testx, &testy);
    NSLog(@"x = %f y= %f", testx, testy);
    
}

@end
