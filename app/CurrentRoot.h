//
//  CurrentRoot.h
//  iDebSH
//
//  Created by Theodore Dubois on 11/4/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern int fs_ish_version;
extern int fs_ish_apt_version;

void FsInitialize(void);
bool FsIsManaged(void);
bool FsNeedsRepositoryUpdate(void);
void FsUpdateOnlyRepositoriesFile(void);
void FsUpdateRepositories(void);

/// An integer representing the current major version of Debian APT repositories.
/// An upgrade will be prompted if the number in /ish/debian-version is smaller.
/// After a successful upgrade, the newer number is copied into /ish/debian-version.
#define CURRENT_DEBIAN_VERSION 12000
#define CURRENT_DEBIAN_VERSION_STRING "Debian 12 (Bookworm)"

// Backward compatibility aliases
#define fs_ish_apk_version fs_ish_apt_version
#define CURRENT_APK_VERSION CURRENT_DEBIAN_VERSION
#define CURRENT_APK_VERSION_STRING CURRENT_DEBIAN_VERSION_STRING

extern NSString *const FsUpdatedNotification;

NS_ASSUME_NONNULL_END
