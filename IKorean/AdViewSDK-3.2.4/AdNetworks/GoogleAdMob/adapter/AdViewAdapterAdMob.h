/*
 
 Copyright 2010 www.adview.cn. All rights reserved.
 
 */

#import "AdViewAdNetworkAdapter.h"
#import <GoogleMobileAds/GADBannerViewDelegate.h>

@class AdMobView;

@interface AdViewAdapterAdMob : AdViewAdNetworkAdapter <GADBannerViewDelegate> {

}

+ (AdViewAdNetworkType)networkType;

@end
