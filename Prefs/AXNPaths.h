#import <Foundation/Foundation.h>

#if AXN_ROOTHIDE
#import <roothide.h>
static inline const char *AXNRootPath(const char *path) {
    return jbroot(path);
}
#else
#import <rootless.h>
static inline const char *AXNRootPath(const char *path) {
    return ROOT_PATH(path);
}
#endif
