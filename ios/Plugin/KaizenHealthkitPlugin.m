#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(KaizenHealthkitPlugin, "KaizenHealthkit",
    CAP_PLUGIN_METHOD(isAvailable, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(requestAuthorization, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(queryHKitStatistics, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(queryHKitSampleType, CAPPluginReturnPromise);
)
