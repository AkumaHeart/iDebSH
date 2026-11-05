//
//  CurrentRoot.m
//  iDebSH
//
//  Created by Theodore Dubois on 11/4/21.
//

#import "CurrentRoot.h"
#include "kernel/calls.h"
#include "fs/path.h"

#ifdef ISH_LINUX
#import "LinuxInterop.h"
#endif

int fs_ish_version;
int fs_ish_apt_version;

#if !ISH_LINUX
static ssize_t read_file(const char *path, char *buf, size_t size) {
    struct fd *fd = generic_open(path, O_RDONLY_, 0);
    if (IS_ERR(fd))
        return PTR_ERR(fd);
    ssize_t n = fd->ops->read(fd, buf, size);
    fd_close(fd);
    if (n == size)
        return _ENAMETOOLONG;
    return n;
}

static ssize_t write_file(const char *path, const char *buf, size_t size) {
    struct fd *fd = generic_open(path, O_WRONLY_|O_CREAT_|O_TRUNC_, 0644);
    if (IS_ERR(fd))
        return PTR_ERR(fd);
    ssize_t n = fd->ops->write(fd, buf, size);
    fd_close(fd);
    return n;
}
static int remove_directory(const char *path) {
    return generic_rmdirat(AT_PWD, path);
}
#else
#define read_file linux_read_file
#define write_file linux_write_file
#define remove_directory linux_remove_directory
#endif

void FsInitialize(void) {
    // /ish/version is the last ish version that opened this root. Used to migrate the filesystem.
    char buf[1000];
    ssize_t n = read_file("/ish/version", buf, sizeof(buf));
    if (n >= 0) {
        NSString *currentVersion = NSBundle.mainBundle.infoDictionary[(__bridge NSString *) kCFBundleVersionKey];
        NSString *currentVersionFile = [NSString stringWithFormat:@"%@\n", currentVersion];

        NSString *version = [[NSString alloc] initWithBytesNoCopy:buf length:n encoding:NSUTF8StringEncoding freeWhenDone:NO];
        version = [version stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        fs_ish_version = version.intValue;

        version = nil;

        n = read_file("/ish/debian-version", buf, sizeof(buf));
        if (n < 0) {
            // Fallback for transition from legacy /ish/apk-version
            n = read_file("/ish/apk-version", buf, sizeof(buf));
        }

        if (n >= 0) {
            NSString *version = [[NSString alloc] initWithBytesNoCopy:buf length:n encoding:NSUTF8StringEncoding freeWhenDone:NO];
            version = [version stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            fs_ish_apt_version = version.intValue;
        }

        // If no newer value for CURRENT_DEBIAN_VERSION, do silent update.
        if (fs_ish_apt_version >= CURRENT_DEBIAN_VERSION)
            FsUpdateRepositories();

        if (currentVersion.intValue > fs_ish_version) {
            fs_ish_version = currentVersion.intValue;
            write_file("/ish/version", currentVersionFile.UTF8String, [currentVersionFile lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
        }
    }
}

bool FsIsManaged(void) {
    return fs_ish_version != 0;
}

bool FsNeedsRepositoryUpdate(void) {
    return FsIsManaged() && fs_ish_apt_version < CURRENT_DEBIAN_VERSION;
}

void FsUpdateOnlyRepositoriesFile(void) {
    NSURL *sources = [NSBundle.mainBundle URLForResource:@"sources" withExtension:@"list"];
    if (sources == nil) {
        // Fallback for legacy bundle name
        sources = [NSBundle.mainBundle URLForResource:@"repositories" withExtension:@"txt"];
    }

    if (sources != nil) {
        NSMutableData *sourcesData = [@"# This file contains Debian APT sources managed by iDebSH.\n"
                                      @"# If the /ish directory exists, iDebSH keeps this file up to date.\n"
                                      dataUsingEncoding:NSUTF8StringEncoding].mutableCopy;
        [sourcesData appendData:[NSData dataWithContentsOfURL:sources]];
        write_file("/etc/apt/sources.list", sourcesData.bytes, sourcesData.length);
    }
}

void FsUpdateRepositories(void) {
    FsUpdateOnlyRepositoriesFile();
    fs_ish_apt_version = CURRENT_DEBIAN_VERSION;
    NSString *currentVersionFile = [NSString stringWithFormat:@"%d\n", fs_ish_apt_version];
    write_file("/ish/debian-version", currentVersionFile.UTF8String, [currentVersionFile lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    remove_directory("/ish/apt");
    remove_directory("/ish/apk");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSNotificationCenter.defaultCenter postNotificationName:FsUpdatedNotification object:nil];
    });
}

NSString *const FsUpdatedNotification = @"FsUpdatedNotification";
