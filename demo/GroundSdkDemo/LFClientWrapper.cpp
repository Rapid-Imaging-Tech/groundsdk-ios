//
//  LFClientWrapper.c
//  GroundSdkDemo
//
//  Created by David Dvergsten on 2/9/21.
//  Copyright © 2021 Parrot SA. All rights reserved.
//

#include "LFClientWrapper.h"
#include <mutex>
#include <thread>
//#include <mutex>
float touchx = 0.0f;
float touchy = 0.0f;
std::mutex messageMutex;
void setXY(float x, float y)
{
    std::lock_guard<std::mutex> lock(messageMutex);
    touchx = x;
    touchy = y;
}

void resetXY()//call this from pdraw to reset things so we only get one notification to pdraw for the next iteration
{
    std::lock_guard<std::mutex> lock(messageMutex);
    touchx = 0.0f;
    touchy = 0.0f;
}
void getxy(float& x, float& y)//call this from pdraw to see if user clicked the screen
{
    std::lock_guard<std::mutex> lock(messageMutex);
    x = touchx;
    y = touchy;
    
}
