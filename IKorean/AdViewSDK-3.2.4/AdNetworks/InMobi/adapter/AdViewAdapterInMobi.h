/*
 
 Adview .
 
 */

#import "AdViewAdNetworkAdapter.h"
//#import "IMAdView.h"
//#import "IMAdDelegate.h"
//#import "IMAdRequest.h"
//#import "IMAdError.h"

#import "IMBanner.h"
#import "IMBannerDelegate.h"
#import "IMSdk.h"

@interface AdViewAdapterInMobi : AdViewAdNetworkAdapter<IMBannerDelegate> {
    
}

+ (AdViewAdNetworkType)networkType;

@end
