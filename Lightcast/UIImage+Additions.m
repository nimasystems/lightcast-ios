/*
 * Lightcast for iOS Framework
 * Copyright (C) 2007-2011 Nimasystems Ltd
 *
 * This program is NOT free software; you cannot redistribute and/or modify
 * it's sources under any circumstances without the explicit knowledge and
 * agreement of the rightful owner of the software - Nimasystems Ltd.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without even the
 * implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the LICENSE.txt file for more information.
 *
 * You should have received a copy of LICENSE.txt file along with this
 * program; if not, write to:
 * NIMASYSTEMS LTD 
 * Plovdiv, Bulgaria
 * ZIP Code: 4000
 * Address: 95 "Kapitan Raycho" Str., 6th Floor
 * General E-Mail: info@nimasystems.com
 * Tel./Fax: +359 32 395 282
 * Mobile: +359 896 610 876
 */

/**
 * File Description
 * @package File Category
 * @subpackage File Subcategory
 * @changed $Id: UIImage+Additions.m 341 2014-08-28 05:21:47Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 341 $
 */

#if !__has_feature(objc_arc)
#error This library requires automatic reference counting
#endif

#import "UIImage+Additions.h"

@implementation UIImage(LAdditions)

+ (CGFloat)degreesToRadians:(CGFloat)degrees {
    return degrees * M_PI / 180;
};

+ (CGFloat)radiansToDegrees:(CGFloat)radians {
    return radians * 180/M_PI;
};

- (CGSize)constraintImageToSize:(CGSize)constrainToSize
{
    if (!constrainToSize.width || !constrainToSize.height)
    {
        return constrainToSize;
    }
    
    CGFloat w = constrainToSize.width;
    CGFloat h = constrainToSize.height;
    
    CGFloat imgW = self.size.width;
    CGFloat imgH = self.size.height;
    
    if (!imgW || !imgH)
    {
        return constrainToSize;
    }
    
    CGFloat newW = 0;
    CGFloat newH = 0;
    
    if (w > imgW && h > imgH)
    {
        newW = imgW;
        newH = imgH;
    }
    else if (w < imgW && h > imgH)
    {
        CGFloat diff = imgW - w;
        CGFloat per = (100 * diff) / imgW;
        newW = imgW - ((imgW * per)/100);
        newH = imgH - ((imgH * per)/100);
    }
    else if (w > imgW && h < imgH)
    {
        CGFloat diff = imgH - h;
        CGFloat per = (100 * diff) / imgH;
        newH = imgH - ((imgH * per)/100);
        newW = imgW - ((imgW * per)/100);
    }
    else
    {
        if (imgW - w >= imgH - h)
        {
            CGFloat diff = imgW - w;
            CGFloat per = (100 * diff) / imgW;
            newW = imgW - ((imgW * per)/100);
            newH = imgH - ((imgH * per)/100);
        }
        else
        {
            CGFloat diff = imgH - h;
            CGFloat per = (100 * diff) / imgH;
            newH = imgH - ((imgH * per)/100);
            newW = imgW - ((imgW * per)/100);
        }
    }
    
    CGSize newSize = CGSizeMake(newW, newH);
    return newSize;
}

- (UIImage *)resizedImage:(ImageResizeType)resizeType width:(float)width height:(float)height {
    
    // get the current size
    float aw = self.size.width;
    float ah = self.size.height;
    
    if (!aw || !ah) return nil;
    
    width = !width ? aw : width;
    height = !height ? ah : height;
    
    float newW = 0;
    float newH = 0;
    
    UIImage * ret = nil;
    
    // set the size
    switch (resizeType) 
    {
        case resizeWithConstraints:
        {
            // with preserving the ratio width/height up to the maximums
            
            float imgRatio = aw / ah;
            float maxRatio = width / height;
            
            if(imgRatio < maxRatio)
            {
                imgRatio = height / ah;
                newW = imgRatio * aw;
                newH = height;
            }
            else
            {
                imgRatio = width / aw;
                newH = imgRatio * ah;
                newW = width;
            }
            
            break;
        }
        default:
        {
            // resizeImageAsSpecified
            
            newW = width;
            newH = height;
            
            break;
        }
    }
    
    if (aw < newW && ah < newH)
    {
        newW = aw;
        newH = ah;
    }
    
    // size is the same - no resize necessary
    if (newW == aw && newH == ah)
    {
        LogDebug(@"No resize necessary - new image size will be the same");
        return self;
    }
    
    LogDebug(@"Resizing image to new size: %fx%f", newW, newH);
    
    @try 
    {
        CGRect rect = CGRectMake(0.0, 0.0, newW, newH);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        [self drawInRect:rect];
        ret = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    @catch (NSException * e) 
    {
        LogError(@"Error resizing image: resizeType: %d, width: %f, height: %f: %@", resizeType, width, height, [e description]);
        
        ret = nil;
    }
    
    return ret;
}

- (UIImage *)resizedImage:(CGSize)newSize
{
    UIImage * ret = nil;
    
    @try 
    {
        CGRect rect = CGRectMake(0.0, 0.0, newSize.width, newSize.height);
        UIGraphicsBeginImageContext(rect.size);
        [self drawInRect:rect];
        ret = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    @catch (NSException * e) 
    {
        ret = nil;
    }
    
    return ret;
}

- (UIImage *)imageFlippedHorizontally {
    
    UIImage * ret = nil;
    
    CGRect rect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    [self drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, -1.0, 1.0); 
    
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), [self CGImage]);
    
    ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return ret;
}

- (UIImage *)imageFlippedVertically {
    UIImage * ret = nil;
    
    CGRect rect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    [self drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, -1.0, 1.0);    
    
    CGContextDrawImage(context, CGRectMake(0, 0, self.size.width, self.size.height), [self CGImage]);
    
    ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return ret;
}

-(UIImage *)imageAtRect:(CGRect)rect
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
    
}

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) 
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor) 
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageByScalingToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    //   CGSize imageSize = sourceImage.size;
    //   CGFloat width = imageSize.width;
    //   CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    //   CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    return [self imageRotatedByDegrees:[UIImage radiansToDegrees:radians]];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees 
{   
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation([UIImage degreesToRadians:degrees]);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, [UIImage degreesToRadians:degrees]);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// Creates a mask that makes the outer edges transparent and everything else opaque
// The size must include the entire mask (opaque part + transparent border)
// The caller is responsible for releasing the returned reference by calling CGImageRelease
- (CGImageRef)newBorderMask:(NSUInteger)borderSize size:(CGSize)size {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Build a context that's the same dimensions as the new size
    CGContextRef maskContext = CGBitmapContextCreate(NULL,
                                                     size.width,
                                                     size.height,
                                                     8, // 8-bit grayscale
                                                     0,
                                                     colorSpace,
                                                     kCGBitmapByteOrderDefault | kCGImageAlphaNone);
    
    // Start with a mask that's entirely transparent
    CGContextSetFillColorWithColor(maskContext, [UIColor blackColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(0, 0, size.width, size.height));
    
    // Make the inner part (within the border) opaque
    CGContextSetFillColorWithColor(maskContext, [UIColor whiteColor].CGColor);
    CGContextFillRect(maskContext, CGRectMake(borderSize, borderSize, size.width - borderSize * 2, size.height - borderSize * 2));
    
    // Get an image of the context
    CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContext);
    
    // Clean up
    CGContextRelease(maskContext);
    CGColorSpaceRelease(colorSpace);
    
    return maskImageRef;
}

// Returns true if the image has an alpha layer
- (BOOL)hasAlpha {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

// Returns a copy of the given image, adding an alpha channel if it doesn't already have one
- (UIImage *)imageWithAlpha {
    if ([self hasAlpha]) {
        return self;
    }
    
    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          CGImageGetColorSpace(imageRef),
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}

// Returns a copy of the image with a transparent border of the given size added around its edges.
// If the image has no alpha layer, one will be added to it.
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize {
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    
    CGRect newRect = CGRectMake(0, 0, image.size.width + borderSize * 2, image.size.height + borderSize * 2);
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(self.CGImage),
                                                0,
                                                CGImageGetColorSpace(self.CGImage),
                                                CGImageGetBitmapInfo(self.CGImage));
    
    // Draw the image in the center of the context, leaving a gap around the edges
    CGRect imageLocation = CGRectMake(borderSize, borderSize, image.size.width, image.size.height);
    CGContextDrawImage(bitmap, imageLocation, self.CGImage);
    CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
    
    // Create a mask to make the border transparent, and combine it with the image
    CGImageRef maskImageRef = [self newBorderMask:borderSize size:newRect.size];
    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
    UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(borderImageRef);
    CGImageRelease(maskImageRef);
    CGImageRelease(transparentBorderImageRef);
    
    return transparentBorderImage;
}

#pragma mark -
#pragma mark Cropping

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    return transform;
}

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

// Returns a copy of this image that is squared to the thumbnail size.
// If transparentBorder is non-zero, a transparent border of the given size will be added around the edges of the thumbnail. (Adding a transparent border of at least one pixel in size has the side-effect of antialiasing the edges of the image when rotating it using Core Animation.)
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality {
    UIImage *resizedImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                       bounds:CGSizeMake(thumbnailSize, thumbnailSize)
                                         interpolationQuality:quality];
    
    // Crop out any part of the image that's larger than the thumbnail size
    // The cropped rect must be centered on the resized image
    // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
    CGRect cropRect = CGRectMake(round((resizedImage.size.width - thumbnailSize) / 2),
                                 round((resizedImage.size.height - thumbnailSize) / 2),
                                 thumbnailSize,
                                 thumbnailSize);
    UIImage *croppedImage = [resizedImage croppedImage:cropRect];
    
    UIImage *transparentBorderImage = borderSize ? [croppedImage transparentBorderImage:borderSize] : croppedImage;
    
    return [transparentBorderImage roundedCornerImage:cornerRadius borderSize:borderSize];
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality {
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", (int)contentMode];
    }
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    return [self resizedImage:newSize interpolationQuality:quality];
}

#pragma mark -
#pragma mark Rounded Corners

// Adds a rectangular path to the given context and rounds its corners by the given extents
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (void)addRoundedRectToPath:(CGRect)rect context:(CGContextRef)context ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight {
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    CGFloat fw = CGRectGetWidth(rect) / ovalWidth;
    CGFloat fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

// Creates a copy of this image with rounded corners
// If borderSize is non-zero, a transparent border of the given size will also be added
// Original author: Björn Sållarp. Used with permission. See: http://blog.sallarp.com/iphone-uiimage-round-corners/
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize {
    // If the image does not have an alpha layer, add one
    UIImage *image = [self imageWithAlpha];
    
    // Build a context that's the same dimensions as the new size
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 image.size.width,
                                                 image.size.height,
                                                 CGImageGetBitsPerComponent(image.CGImage),
                                                 0,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 CGImageGetBitmapInfo(image.CGImage));
    
    // Create a clipping path with rounded corners
    CGContextBeginPath(context);
    [self addRoundedRectToPath:CGRectMake(borderSize, borderSize, image.size.width - borderSize * 2, image.size.height - borderSize * 2)
                       context:context
                     ovalWidth:cornerSize
                    ovalHeight:cornerSize];
    CGContextClosePath(context);
    CGContextClip(context);
    
    // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    
    // Create a CGImage from the context
    CGImageRef clippedImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    // Create a UIImage from the CGImage
    UIImage *roundedImage = [UIImage imageWithCGImage:clippedImage];
    CGImageRelease(clippedImage);
    
    return roundedImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)grayscaleImage {
    
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, self.size.width * self.scale, self.size.height * self.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint8_t gray = (uint8_t) ((30 * rgbaPixel[RED] + 59 * rgbaPixel[GREEN] + 11 * rgbaPixel[BLUE]) / 100);
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:self.scale
                                           orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

@end
