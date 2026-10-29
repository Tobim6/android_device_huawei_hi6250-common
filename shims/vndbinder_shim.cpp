/*
 * system_teecd (EMUI8 binary) links libbinder just to join a binder thread pool for its trusted-UI helper and calls
 * ProcessState::self(), which on Android 9 means /dev/binder. Under Treble a vendor process may only open /dev/vndbinder,
 * so interpose ProcessState::self() (LD_PRELOAD, see init.tee.rc) and open the vndbinder driver instead.
 */
#include <binder/ProcessState.h>

namespace android {

sp<ProcessState> ProcessState::self() {
    return ProcessState::initWithDriver("/dev/vndbinder");
}

}  // namespace android
