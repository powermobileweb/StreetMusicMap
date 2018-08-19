//
//  Util.m
//  InstaPet
//
//  Created by PowerMobile Team on 3/6/15.
//  Copyright (c) 2015 DevMac. All rights reserved.
//

#import "Util.h"
#import "InstagramKit.h"

@implementation Util

+ (UIImageView *)addLogoHeader {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoHeader"]];
}

+ (void)saveUserDefaultsWithBool:(BOOL)objectBool forKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:objectBool forKey:key];
    [userDefaults synchronize];
}

+ (BOOL)loadUserDefaultsBoolWithKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (void)saveUserDefaultsWithObject:(id)object forKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:object forKey:key];
    [userDefaults synchronize];
}

+ (id)loadUserDefaultsWithKey:(NSString *)key
{
   return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)removeUserDefaultsWithKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}

+ (void)archiveAndSaveObject:(id)object toUserDefaultsWithKey:(NSString *)key
{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    [self saveUserDefaultsWithObject:encodedObject forKey:key];
}

+ (id)unarchiveObjectFromUserDefaultsWithKey:(NSString *)key
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    
    if (encodedObject != nil) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    } else {
        return nil;
    }
}

+ (void)circularProfile:(AsyncImageView *)imgPrile
{
    [self circularProfile:imgPrile borderWith:3.0f];
}

+ (void)circularProfile:(AsyncImageView *)imgPrile borderWith:(CGFloat)borderWith
{
    imgPrile.layer.cornerRadius = imgPrile.frame.size.width / 2;
    imgPrile.clipsToBounds = YES;
    imgPrile.layer.borderWidth = borderWith;
    imgPrile.layer.borderColor = [UIColor whiteColor].CGColor;
}

+ (NSString *)formatDateForString:(NSDate *)formatDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay) fromDate:formatDate];
    
    return [NSString stringWithFormat:@"%li/%li/%li", (long)[components day], (long)[components month], (long)[components year]];
}

+ (NSString*) howLongTimeAgoFromDate: (NSDate*)date {
    
    NSDate *today = [NSDate date];
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];

    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitSecond;
    
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date  toDate:today  options:0];
    
   // NSLog(@"Conversion: %ld min %ld hours %ld days %ld moths",(long)[conversionInfo minute], (long)[conversionInfo hour], (long)[conversionInfo day], (long)[conversionInfo weekdayOrdinal]);
    
    
    NSInteger month = [conversionInfo month];
    NSInteger week = [conversionInfo weekdayOrdinal];
    NSInteger day = [conversionInfo day];
    NSInteger hour = [conversionInfo hour];
    NSInteger minute = [conversionInfo minute];
    NSInteger seconds = [conversionInfo second];
    
    NSString *result = @"";
    
    if (week > 4) {
        result = [NSString stringWithFormat:@"%ldm %ldw", month, week];
        return result;
    }
    else if (week > 0) {
        result = [NSString stringWithFormat:@"%ldw", week];
        return result;
    }
    else if (day > 0 ) {
        if (day == 1) {
            result = [NSString stringWithFormat:@"%ldd %ldh", day, hour];
        }
        else {
            result = [NSString stringWithFormat:@"%ldd", day];
        }
        return result;
    }
    else if (hour > 0) {
            result = [NSString stringWithFormat:@"%ldh", hour];
            return result;
    }
    else if (minute > 0) {
        result = [NSString stringWithFormat:@"%ldm", minute];
        return result;
    }
    else {
        result = [NSString stringWithFormat:@"%lds", seconds];
        return result;
    }

}



+ (UIImage*)imageWithBlurredImageWithImage:(UIImage*)image withBlurRadius:(CGFloat)blurRadius{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context =  UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -image.size.height);
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), [self blurImage: image withBottomInset: image.size.height blurRadius: blurRadius].CGImage);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage*)blurImage:(UIImage*)image withBottomInset:(CGFloat)inset blurRadius:(CGFloat)radius{
    
    image =  [UIImage imageWithCGImage: CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, image.size.height - inset, image.size.width,inset))];
    
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setValue:@(radius) forKey:kCIInputRadiusKey];
    
    CIImage *outputCIImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    
    return [UIImage imageWithCGImage: [context createCGImage:outputCIImage fromRect:ciImage.extent]];
    
}


+ (BOOL) userIsLogged {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *logged = [prefs stringForKey:@"logged"];
    if ([logged  isEqual: @"true"] && (![[[InstagramEngine sharedEngine] accessToken] isEqual: @""] || [[[InstagramEngine sharedEngine] accessToken] isEqual: nil]) ) {
        return YES;
    }
    else {
        return NO;
    }
    
    
}

+ (void) userIsLogged:(BOOL) value {
    if (value) {
    
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:@"true" forKey:@"logged"];
    }
    else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:@"false" forKey:@"logged"];
    }
}














@end
