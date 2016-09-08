/*

adview.
 
*/

#import "AdInstlAdNetworkAdapter.h"
#import "IMInterstitial.h"
#import "IMSdk.h"

@interface AdInstlAdapterInMobi : AdInstlAdNetworkAdapter<IMInterstitialDelegate> {
   
}

+ (AdInstlAdNetworkType)networkType;

@end
