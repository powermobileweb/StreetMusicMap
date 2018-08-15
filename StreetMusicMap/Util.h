//
//  Util.h
//  InstaPet
//
//  Created by PowerMobile Team on 3/6/15.
//  Copyright (c) 2015 DevMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncImageView.h"

@interface Util : NSObject

+ (UIImageView *)addLogoHeader;
+ (void)saveUserDefaultsWithBool:(BOOL)objectBool forKey:(NSString *)key;
+ (BOOL)loadUserDefaultsBoolWithKey:(NSString *)key;
+ (void)saveUserDefaultsWithObject:(id)object forKey:(NSString *)key;
+ (id)loadUserDefaultsWithKey:(NSString *)key;
+ (void)removeUserDefaultsWithKey:(NSString *)key;
+ (void)archiveAndSaveObject:(id)object toUserDefaultsWithKey:(NSString *)key;
+ (id)unarchiveObjectFromUserDefaultsWithKey:(NSString *)key;
+ (void)circularProfile:(AsyncImageView *)imgPrile;
+ (void)circularProfile:(AsyncImageView *)imgPrile borderWith:(CGFloat)borderWith;
+ (NSString *)formatDateForString:(NSDate *)formatDate;
+ (NSString*) howLongTimeAgoFromDate: (NSDate*)date;
+ (UIImage*) imageWithBlurredImageWithImage:(UIImage*)image withBlurRadius:(CGFloat)blurRadius;
+ (BOOL) userIsLogged;
+ (void) userIsLogged:(BOOL) value;
@end
