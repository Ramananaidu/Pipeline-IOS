package geb.mobile.ios

import geb.Page
import groovy.util.logging.Slf4j
import io.appium.java_client.ios.IOSDriver
import org.openqa.selenium.ScreenOrientation

/**
 * Created by gmueksch on 27.08.14.
 */
@Slf4j
class IosBaseView extends Page {

    static content = {
    }

    static at = {
// iOS does not have concept as activity/page/view, just returning True.
// The actual check would be by a specifc element in the page
//        getCurrentView() ? currentView == getCurrentView() : true
        true
    }


    void switchOrientation( orientation ) {
            if (driver instanceof IOSDriver) {
                if (orientation == ScreenOrientation.LANDSCAPE && driver.orientation != orientation) {
                    log.info("Switch orientation to $orientation")
                    executeTargetFunc('setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPELEFT)')

                } else if( orientation == ScreenOrientation.PORTRAIT && driver.orientation != orientation) {
                    executeTargetFunc('setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT)')
                }
            }
    }


    def executeTargetFunc( func ){
        try {
            ((IOSDriver) driver).findElementsByIosUIAutomation("var target = UIATarget.localTarget();target.$func")
        }catch(e){
            log.error("Error on target Function $func: $e.message")
        }
    }

    //To add for web view:
//    public String getCurrentView() {
//        return driver.currentUrl
//    }

}
