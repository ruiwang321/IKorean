/*
 
 Copyright 2010 www.adview.cn. All rights reserved.
 
 */

#import "AdViewAdNetworkAdapter.h"
//#import "VponAdOn.h"
#import "VpadnBanner.h"

@class AdOnView;

/*架势无线*/

@interface AdViewAdapterVpon : AdViewAdNetworkAdapter <VpadnBannerDelegate> {

}
@property (nonatomic,retain)VpadnBanner *vpon;
+ (AdViewAdNetworkType)networkType;

@end
