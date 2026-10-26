/*
 * The EMUI8 camera HAL (camera.hi6250.so) was built against Android 8's libui, where
 * android::Fence::~Fence() was exported. Android 9 made it a private inline default, so the
 * symbol is gone. Fence objects are created by libui (Fence::Fence(int)), whose layout is
 * { LightRefBase::mCount (int32), unique_fd mFenceFd (int) }: the destructor just closes the fd.
 */
#include <unistd.h>

void _ZN7android5FenceD1Ev(void *self)
{
    int fd = *(int *)((char *)self + 4);
    if (fd >= 0)
        close(fd);
}

void _ZN7android5FenceD2Ev(void *self) __attribute__((alias("_ZN7android5FenceD1Ev")));

/*
 * libcamera_algo.so (EMUI8) pulls in the platform libsensor.so, which is not part of the VNDK. The
 * copy placed in /vendor needs three AppOps/permission symbols that the vendor-visible libbinder does
 * not export. libsensor only uses them to look up the permission controller for the sensor privacy
 * check, so stubs that report "no controller / unknown op" are enough for the camera.
 */
void _ZN7android13AppOpsManagerC1Ev(void *self)
{
    (void)self;
}

int _ZN7android13AppOpsManager18permissionToOpCodeERKNS_8String16E(const void *permission)
{
    (void)permission;
    return -1; /* OP_NONE */
}

/* android::sp<IPermissionController> IPermissionController::asInterface(const sp<IBinder>&): the sp is
 * returned through a hidden pointer (x8 on arm64, r0 on arm32); return a null sp. */
#if defined(__aarch64__)
__attribute__((naked)) void _ZN7android21IPermissionController11asInterfaceERKNS_2spINS_7IBinderEEE(const void *binder)
{
    __asm__ volatile("str xzr, [x8]\n\tret");
}
#else
void _ZN7android21IPermissionController11asInterfaceERKNS_2spINS_7IBinderEEE(void **ret, const void *binder)
{
    (void)binder;
    *ret = 0;
}
#endif
