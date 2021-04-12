//
//  LFMessageHandler.h
//  GroundSdkDemo
//
//  Created by David Dvergsten on 2/13/21.
//  Copyright © 2021 Parrot SA. All rights reserved.
//

#ifndef LFMessageHandler_h
#define LFMessageHandler_h
#import <Foundation/Foundation.h>
@interface LFMessageHandler : NSObject


-(void) VCGetLatLonForScreenXY:(float)screenx andScreenY:(float) screeny;
-(bool) PDCheckGetLatLon:(float*)screenx _:(float*)screeny;
-(void) PDSetLatLonReady:(float)lat _:(float) lon;
-(bool) VCCheckLatLonReadyLat:(float*)lat Lon:(float*) lon;
-(void) setXY2:(float)x _:(float) y;

-(void)resetXY;
-(void) getxy2:(float*)x _:(float*)y;

-(void)setX:(float)x andY:(float)y;
@end

#endif /* LFMessageHandler_h */
