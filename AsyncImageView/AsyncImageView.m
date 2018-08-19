//
//  AsyncImageView.m
//
//  Version 1.5.1
//
//  Created by Nick Lockwood on 03/04/2011.
//  Copyright (c) 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/AsyncImageView
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#import "AsyncImageView.h"
#import <objc/message.h>
#import <QuartzCore/QuartzCore.h>


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

NSString *const AsyncImageLoadDidFinish = @"AsyncImageLoadDidFinish";
NSString *const AsyncImageLoadDidFail = @"AsyncImageLoadDidFail";

NSString *const AsyncImageImageKey = @"image";
NSString *const AsyncImageURLKey = @"URL";
NSString *const AsyncImageCacheKey = @"cache";
NSString *const AsyncImageErrorKey = @"error";


@interface AsyncImageConnection : NSObject

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL success;
@property (nonatomic, assign) SEL failure;
@property (nonatomic, getter = isLoading) BOOL loading;
@property (nonatomic, getter = isCancelled) BOOL cancelled;

- (AsyncImageConnection *)initWithURL:(NSURL *)URL
                                cache:(NSCache *)cache
							   target:(id)target
							  success:(SEL)success
							  failure:(SEL)failure;

- (void)start;
- (void)cancel;
- (BOOL)isInCache;

@end


@implementation AsyncImageConnection

- (AsyncImageConnection *)initWithURL:(NSURL *)URL
                                cache:(NSCache *)cache
							   target:(id)target
							  success:(SEL)success
							  failure:(SEL)failure
{
    if ((self = [self init]))
    {
        self.URL = URL;
        self.cache = cache;
        self.target = target;
        self.success = success;
        self.failure = failure;
    }
    return self;
}

- (UIImage *)cachedImage
{
    if ([self.URL isFileURL])
	{
		NSString *path = [[self.URL absoluteURL] path];
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
		if ([path hasPrefix:resourcePath])
		{
			return [UIImage imageNamed:[path substringFromIndex:[resourcePath length]]];
		}
	}
    if ([self.cache objectForKey:self.URL]) {
        return [self.cache objectForKey:self.URL];
    }
    
    //Stored in temporary folder
    NSString *photoPath = [[self pathFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [[_URL absoluteString] lastPathComponent]]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:photoPath])
    {
        UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:photoPath]];
        
        //add to cache (cached already but it doesn't matter)
        [self performSelectorOnMainThread:@selector(cacheImage:)
                               withObject:image
                            waitUntilDone:NO];
        
        return image;
    }
    
    return nil;
}

- (BOOL)isInCache
{
    return [self cachedImage] != nil;
}

- (void)loadFailedWithError:(NSError *)error
{
	self.loading = NO;
	self.cancelled = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:AsyncImageLoadDidFail
                                                        object:self.target
                                                      userInfo:@{AsyncImageURLKey: self.URL,
                                                                AsyncImageErrorKey: error}];
}

- (void)cacheImage:(UIImage *)image
{
	if (!self.cancelled)
	{
        if (image && self.URL)
        {
            BOOL storeInCache = YES;
            if ([self.URL isFileURL])
            {
                if ([[[self.URL absoluteURL] path] hasPrefix:[[NSBundle mainBundle] resourcePath]])
                {
                    //do not store in cache
                    storeInCache = NO;
                }
            }
            if (storeInCache)
            {
                [self.cache setObject:image forKey:self.URL];
//fabio API change
                
                //Store in temp folder
                NSString *photoPath = [[self pathFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [[_URL absoluteString] lastPathComponent]]];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                if (![fileManager fileExistsAtPath:photoPath])
                {
                    NSData* imageData = UIImagePNGRepresentation(image);
                    BOOL  saveworks = [imageData writeToFile:photoPath atomically:YES];
                    
                    saveworks = saveworks;
                }
            }
        }
        
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										 image, AsyncImageImageKey,
										 self.URL, AsyncImageURLKey,
										 nil];
		if (self.cache)
		{
			userInfo[AsyncImageCacheKey] = self.cache;
		}
		
		self.loading = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:AsyncImageLoadDidFinish
															object:self.target
														  userInfo:[userInfo copy]];
	}
	else
	{
		self.loading = NO;
		self.cancelled = NO;
	}
}

- (void)processDataInBackground:(NSData *)data
{
	@synchronized ([self class])
	{	
		if (!self.cancelled)
		{
            UIImage *image = [[UIImage alloc] initWithData:data];
			if (image)
			{
                //redraw to prevent deferred decompression
                UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
                [image drawAtPoint:CGPointZero];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
				//add to cache (may be cached already but it doesn't matter)
                [self performSelectorOnMainThread:@selector(cacheImage:)
                                       withObject:image
                                    waitUntilDone:YES];
			}
			else
			{
                @autoreleasepool
                {
                    NSError *error = [NSError errorWithDomain:@"AsyncImageLoader" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Invalid image data"}];
                    [self performSelectorOnMainThread:@selector(loadFailedWithError:) withObject:error waitUntilDone:YES];
				}
			}
		}
		else
		{
			//clean up
			[self performSelectorOnMainThread:@selector(cacheImage:)
								   withObject:nil
								waitUntilDone:YES];
		}
	}
}

- (void)connection:(__unused NSURLConnection *)connection didReceiveResponse:(__unused NSURLResponse *)response
{
    self.data = [NSMutableData data];
}

- (void)connection:(__unused NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //add data
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(__unused NSURLConnection *)connection
{
    [self performSelectorInBackground:@selector(processDataInBackground:) withObject:self.data];
    self.connection = nil;
    self.data = nil;
}

- (void)connection:(__unused NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    self.data = nil;
    [self loadFailedWithError:error];
}

- (void)start
{
    if (self.loading && !self.cancelled)
    {
        return;
    }
	
	//begin loading
	self.loading = YES;
	self.cancelled = NO;
    
    //check for nil URL
    if (self.URL == nil)
    {
        [self cacheImage:nil];
        return;
    }
    
    //check for cached image
	UIImage *image = [self cachedImage];
    if (image)
    {
        //add to cache (cached already but it doesn't matter)
        [self performSelectorOnMainThread:@selector(cacheImage:)
                               withObject:image
                            waitUntilDone:NO];
        return;
    }
//fabio API change
    //Check from file system cache
    else
    {
        //Stored in temporary folder
        NSString *photoPath = [[self pathFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [[_URL absoluteString] lastPathComponent]]];
		
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:photoPath])
        {
            image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:photoPath]];
            
            //add to cache (cached already but it doesn't matter)
            [self performSelectorOnMainThread:@selector(cacheImage:)
                                   withObject:image
                                waitUntilDone:NO];
            return;
        }
    }
    
    //begin load
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:[AsyncImageLoader sharedLoader].loadingTimeout];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
}

- (void)cancel
{
	self.cancelled = YES;
    [self.connection cancel];
    self.connection = nil;
    self.data = nil;
}

- (NSString *)pathFolder
{
    NSString *documentsDirectory = NSTemporaryDirectory();
    
    NSArray *components = _URL.absoluteString.pathComponents;
    NSString *completePath = documentsDirectory;
    
     NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *err;
    for (NSInteger i=0; i<(components.count-1); i++)
    {
        NSString *path = components[i];
        completePath = [completePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", path]];
        
        if (![fileManager fileExistsAtPath:completePath]) {
            [fileManager createDirectoryAtPath:completePath withIntermediateDirectories:NO attributes:nil error:&err];
            
            if (err) {
                NSLog(@"Error: %@", err.localizedDescription);
              }
        }
    }
    
    return completePath;
}

@end


@interface AsyncImageLoader ()

@property (nonatomic, strong) NSMutableArray *connections;

@end


@implementation AsyncImageLoader

+ (AsyncImageLoader *)sharedLoader
{
	static AsyncImageLoader *sharedInstance = nil;
	if (sharedInstance == nil)
	{
		sharedInstance = [(AsyncImageLoader *)[self alloc] init];
	}
	return sharedInstance;
}

- (UIImage *)cachedImageForURL:(NSURL *)url
{
    if ([self.cache objectForKey:url])
    {
        return [self.cache objectForKey:url];
    }
    else
    {
        AsyncImageConnection *connection = [[AsyncImageConnection alloc] initWithURL:url cache:self.cache target:nil success:nil failure:nil];
        return [connection cachedImage];
    }
}

+ (NSCache *)defaultCache
{
    static NSCache *sharedCache = nil;
	if (sharedCache == nil)
	{
		sharedCache = [[NSCache alloc] init];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(__unused NSNotification *note) {
            
            [sharedCache removeAllObjects];
        }];
	}
	return sharedCache;
}

- (AsyncImageLoader *)init
{
	if ((self = [super init]))
	{
        self.cache = [[self class] defaultCache];
        _concurrentLoads = 2;
        _loadingTimeout = 60.0;
		_connections = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(imageLoaded:)
													 name:AsyncImageLoadDidFinish
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(imageFailed:)
													 name:AsyncImageLoadDidFail
												   object:nil];
	}
	return self;
}

- (void)updateQueue
{
    //start connections
    NSUInteger count = 0;
    for (AsyncImageConnection *connection in self.connections)
    {
        if (![connection isLoading])
        {
            if ([connection isInCache])
            {
                [connection start];
            }
            else if (count < self.concurrentLoads)
            {
                count ++;
                [connection start];
            }
        }
    }
}

- (void)imageLoaded:(NSNotification *)notification
{  
    //complete connections for URL
    NSURL *URL = (notification.userInfo)[AsyncImageURLKey];
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        AsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.URL == URL || [connection.URL isEqual:URL])
        {
            //cancel earlier connections for same target/action
            for (NSInteger j = i - 1; j >= 0; j--)
            {
                AsyncImageConnection *earlier = self.connections[(NSUInteger)j];
                if (earlier.target == connection.target &&
                    earlier.success == connection.success)
                {
                    [earlier cancel];
                    [self.connections removeObjectAtIndex:(NSUInteger)j];
                    i--;
                }
            }
            
            //cancel connection (in case it's a duplicate)
            [connection cancel];
            
            //perform action
			UIImage *image = (notification.userInfo)[AsyncImageImageKey];
            ((void (*)(id, SEL, id, id))objc_msgSend)(connection.target, connection.success, image, connection.URL);
            
            //remove from queue
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
    
    //update the queue
    [self updateQueue];
}

- (void)imageFailed:(NSNotification *)notification
{
    //remove connections for URL
    NSURL *URL = (notification.userInfo)[AsyncImageURLKey];
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        AsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL])
        {
            //cancel connection (in case it's a duplicate)
            [connection cancel];
            
            //perform failure action
            if (connection.failure)
            {
                NSError *error = (notification.userInfo)[AsyncImageErrorKey];
                ((void (*)(id, SEL, id, id))objc_msgSend)(connection.target, connection.failure, error, URL);
            }
            
            //remove from queue
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
    
    //update the queue
    [self updateQueue];
}

- (void)loadImageWithURL:(NSURL *)URL target:(id)target success:(SEL)success failure:(SEL)failure
{
    //check cache
    UIImage *image = [self.cache objectForKey:URL];
    if (image)
    {
        [self cancelLoadingImagesForTarget:self action:success];
        if (success)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                ((void (*)(id, SEL, id, id))objc_msgSend)(target, success, image, URL);
            });
        }
        return;
    }
    
    //create new connection
    AsyncImageConnection *connection = [[AsyncImageConnection alloc] initWithURL:URL
                                                                           cache:self.cache
                                                                          target:target
                                                                         success:success
                                                                         failure:failure];
    BOOL added = NO;
    for (NSUInteger i = 0; i < [self.connections count]; i++)
    {
        AsyncImageConnection *existingConnection = self.connections[i];
        if (!existingConnection.loading)
        {
            [self.connections insertObject:connection atIndex:i];
            added = YES;
            break;
        }
    }
    if (!added)
    {
        [self.connections addObject:connection];
    }
    
    [self updateQueue];
}

- (void)loadImageWithURL:(NSURL *)URL target:(id)target action:(SEL)action
{
    [self loadImageWithURL:URL target:target success:action failure:NULL];
}

- (void)loadImageWithURL:(NSURL *)URL
{
    [self loadImageWithURL:URL target:nil success:NULL failure:NULL];
}

- (void)cancelLoadingURL:(NSURL *)URL target:(id)target action:(SEL)action
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        AsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL] && connection.target == target && connection.success == action)
        {
            [connection cancel];
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
}

- (void)cancelLoadingURL:(NSURL *)URL target:(id)target
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        AsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL] && connection.target == target)
        {
            [connection cancel];
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
}

- (void)cancelLoadingURL:(NSURL *)URL
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        AsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if ([connection.URL isEqual:URL])
        {
            [connection cancel];
            [self.connections removeObjectAtIndex:(NSUInteger)i];
        }
    }
}

- (void)cancelLoadingImagesForTarget:(id)target action:(SEL)action
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        AsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target && connection.success == action)
        {
            [connection cancel];
        }
    }
}

- (void)cancelLoadingImagesForTarget:(id)target
{
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        AsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target)
        {
            [connection cancel];
        }
    }
}

- (NSURL *)URLForTarget:(id)target action:(SEL)action
{
    //return the most recent image URL assigned to the target for the given action
    //this is not neccesarily the next image that will be assigned
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        AsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target && connection.success == action)
        {
            return connection.URL;
        }
    }
    return nil;
}

- (NSURL *)URLForTarget:(id)target
{
    //return the most recent image URL assigned to the target
    //this is not neccesarily the next image that will be assigned
    for (NSInteger i = (NSInteger)[self.connections count] - 1; i >= 0; i--)
    {
        AsyncImageConnection *connection = self.connections[(NSUInteger)i];
        if (connection.target == target)
        {
            return connection.URL;
        }
    }
    return nil;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


@implementation UIImageView(AsyncImageView)

- (void)setImageURL:(NSURL *)imageURL
{
	[[AsyncImageLoader sharedLoader] loadImageWithURL:imageURL target:self action:@selector(setImage:)];
}

- (NSURL *)imageURL
{
	return [[AsyncImageLoader sharedLoader] URLForTarget:self action:@selector(setImage:)];
}

@end


@interface AsyncImageView ()

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end


@implementation AsyncImageView

- (void)setUp
{
	self.showActivityIndicator = (self.image == nil);
	self.activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
	self.crossfadeDuration = 0.4;
    self.crossfadeImages = NO;
    self.actvPositionYCenter = YES;
    self.cropImage = NO;
    self.greyImage = NO;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL
{
    UIImage *image = [[AsyncImageLoader sharedLoader].cache objectForKey:imageURL];
    if (image)
    {
        self.image = image;
        return;
    }
    super.imageURL = imageURL;
    if (self.showActivityIndicator && !self.image && imageURL)
    {
        if (self.activityView == nil)
        {
            self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.activityIndicatorStyle];
            self.activityView.hidesWhenStopped = YES;
            
//fabio API change
            //Activity View Y position fix
            if(_actvPositionYCenter)
                _activityView.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
            else
                _activityView.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.7f);
            
            self.activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
            [self addSubview:self.activityView];
        }
        [self.activityView startAnimating];
    }
}

- (void)setActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
	_activityIndicatorStyle = style;
	[self.activityView removeFromSuperview];
	self.activityView = nil;
}

- (void)setImage:(UIImage *)image
{
//fabio API change
    //Crossfade images
    if (image != self.image && self.crossfadeDuration && self.crossfadeImages)
    {
        //jump through a few hoops to avoid QuartzCore framework dependency
        CAAnimation *animation = [NSClassFromString(@"CATransition") animation];
        [animation setValue:@"kCATransitionFade" forKey:@"type"];
        animation.duration = self.crossfadeDuration;
        [self.layer addAnimation:animation forKey:nil];
    }
    
//fabio API change
    //Crop image fix
    if (!_cropImage)
    {
        super.image = image;
    }
    else
    {
        CGFloat minSize = image.size.height;
        if (image.size.width<image.size.height) {
            minSize = image.size.width;
        }
        
        CGRect newSize = CGRectMake(image.size.width/2 - minSize/2, 0, minSize, minSize);
        CGImageRef tmp = CGImageCreateWithImageInRect([image CGImage], newSize);
        UIImage *newImage = [UIImage imageWithCGImage:tmp];
        CGImageRelease(tmp);
        [super setImage:newImage];
    }
    
    if (_greyImage && super.image)
    {
        super.image = [self convertToGrayscale:super.image];
    }
    
    [self.activityView stopAnimating];
}

- (void)dealloc
{
    [[AsyncImageLoader sharedLoader] cancelLoadingURL:self.imageURL target:self];
}

//fabio API change
- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, 0);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

- (UIImage *)convertToGrayscale:(UIImage *)image {
    CGSize size = [image size];
    int width = size.width;
    int height = size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:newImage];
    
    // we're done with image now too
    CGImageRelease(newImage);
    
    return resultUIImage;
}

@end
