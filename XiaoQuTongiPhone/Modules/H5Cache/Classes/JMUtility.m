//
//  JMUtility.m
//  JoyMapsKit
//
//  Created by laijiandong on 13-5-12.
//  Copyright (c) 2013年 laijiandong. All rights reserved.
//

#import "JMUtility.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "JMUtility requires ARC support."
#endif

@implementation JMUtility

+ (void)performActionOnMainThreadAsync:(BOOL)async action:(dispatch_block_t)action {
    if (action == nil) return;
    
    if ([NSThread isMainThread]) {
        action();
        
    } else {
        void (*impl)(dispatch_queue_t, dispatch_block_t) = async ? &dispatch_async
                                                                 : &dispatch_sync;
        
        impl(dispatch_get_main_queue(), action);
    }
}

+ (void)performActionOnSubThreadAsync:(BOOL)async
                               action:(dispatch_block_t)action {
    if (action == nil) return;
    
    if ([NSThread isMainThread]) {
        void (*impl)(dispatch_queue_t, dispatch_block_t) = async ? &dispatch_async
                                                                 : &dispatch_sync;
        
        impl(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), action);
        
    } else {
        action();
    }
}

+ (NSDictionary *)queryParamsDictionaryFromURL:(NSURL *)url {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if ([url query]) {
        [result addEntriesFromDictionary:[JMUtility dictionaryByParsingURLQueryPart:[url query]]];
    }
    if ([url fragment]) {
        [result addEntriesFromDictionary:[JMUtility dictionaryByParsingURLQueryPart:[url fragment]]];
    }
    
    return result;
}

// finishes the parsing job that NSURL starts
+ (NSDictionary*)dictionaryByParsingURLQueryPart:(NSString *)encodedString {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *parts = [encodedString componentsSeparatedByString:@"&"];
    
    for (NSString *part in parts) {
        if ([part length] == 0) {
            continue;
        }
        
        NSRange index = [part rangeOfString:@"="];
        NSString *key;
        NSString *value;
        
        if (index.location == NSNotFound) {
            key = part;
            value = @"";
        } else {
            key = [part substringToIndex:index.location];
            value = [part substringFromIndex:index.location + index.length];
        }
        
        if (key && value) {
            [result setObject:[JMUtility stringByURLDecodingString:value]
                       forKey:[JMUtility stringByURLDecodingString:key]];
        }
    }
    return result;
}

+ (NSString *)stringBySerializingQueryParameters:(NSDictionary *)queryParameters {
    NSMutableString *queryString = [[NSMutableString alloc] init];
    BOOL hasParameters = NO;
    if (queryParameters) {
        for (NSString *key in queryParameters) {
            if (hasParameters) {
                [queryString appendString:@"&"];
            }
            
            [queryString appendFormat:@"%@=%@", key, [JMUtility stringByURLEncodingString:queryParameters[key]]];
            hasParameters = YES;
        }
    }
    
    return [NSString stringWithString:queryString];
}

// the reverse of url encoding
+ (NSString *)stringByURLDecodingString:(NSString *)escapedString {
    return [[escapedString stringByReplacingOccurrencesOfString:@"+" withString:@" "]
            stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)stringByURLEncodingString:(NSString*)unescapedString {
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                    kCFAllocatorDefault,
                                                    (__bridge CFStringRef)unescapedString,
                                                    NULL, // characters to leave unescaped
                                                    (__bridge CFStringRef)@":!*();@/&?#[]+$,='%’\"",
                                                    kCFStringEncodingUTF8);
    
    return result;
}

@end
