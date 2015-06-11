//
//  SSLocalizationInfo.m
//  SystemServicesDemo
//
//  Created by Kramer on 9/20/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SSLocalizationInfo.h"

@implementation SSLocalizationInfo

// Localization Information

// Country
+ (NSString *)Country {
    // Get the user's country
    @try {
        // Get the locale
        NSLocale *Locale = [NSLocale currentLocale];
        // Get the country from the locale
        NSString *Country = [Locale localeIdentifier];
        // Check for validity
        if (Country == nil || Country.length <= 0) {
            // Error, invalid country
            return nil;
        }
        // Completed Successfully
        return Country;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Locale
+ (NSString *)Locale {
    // Get the user's locale/region
    @try {
        // Get the locale
        NSLocale *Locale = [NSLocale currentLocale];
        // Get the string value of the locale
        NSString *Region = [NSString stringWithFormat:@"%@", [Locale localeIdentifier]];
        // Check for validity
        if (Region == nil || Region.length <= 0) {
            // Error, invalid Region
            return nil;
        }
        // Completed Successfully
        return Region;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Language
+ (NSString *)Language {
    // Get the user's language
    @try {
        // Get the list of languages
        NSArray *LanguageArray = [NSLocale preferredLanguages];
        // Get the user's language
        NSString *Language = [LanguageArray objectAtIndex:0];
        // Check for validity
        if (Language == nil || Language.length <= 0) {
            // Error, invalid language
            return nil;
        }
        // Completed Successfully
        return Language;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// TimeZone
+ (NSString *)TimeZone {
    // Get the user's timezone
    @try {
        // Get the system timezone
        NSTimeZone *LocalTime = [NSTimeZone systemTimeZone];
        // Convert the time zone to a string
        NSString *TimeZone = [LocalTime name];
        // Check for validity
        if (TimeZone == nil || TimeZone.length <= 0) {
            // Error, invalid TimeZone
            return nil;
        }
        // Completed Successfully
        return TimeZone;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Currency Symbol
+ (NSString *)Currency {
    // Get the user's currency
    @try {
        // Get the system currency
        NSString *Currency = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
        // Check for validity
        if (Currency == nil || Currency.length <= 0) {
            // Error, invalid Currency
            return nil;
        }
        // Completed Successfully
        return Currency;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

@end
