//
//  NSString+HTMLEntities.m
//

#import "NSString+HTMLEntities.h"

@implementation NSString (HTMLEntities)

- (NSString *)stringByDecodingHTMLEntities {
	NSUInteger myLength = [self length];
	NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;
	
	// Short-circuit if there are no ampersands.
	if (ampIndex == NSNotFound) {
		return self;
	}
	// Make result string with some extra capacity.
	NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
	
	// First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
	NSScanner *scanner = [NSScanner scannerWithString:self];
	
	[scanner setCharactersToBeSkipped:nil];
	
	NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
	
	do {
		// Scan up to the next entity or the end of the string.
		NSString *nonEntityString;
		if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
			[result appendString:nonEntityString];
		}
		if ([scanner isAtEnd]) {
			goto finish;
		}
		// Scan either a HTML or numeric character entity reference.
		if ([scanner scanString:@"&amp;" intoString:NULL])
			[result appendString:@"&"];
		else if ([scanner scanString:@"&apos;" intoString:NULL])
			[result appendString:@"'"];
		else if ([scanner scanString:@"&quot;" intoString:NULL])
			[result appendString:@"\""];
		else if ([scanner scanString:@"&lt;" intoString:NULL])
			[result appendString:@"<"];
		else if ([scanner scanString:@"&gt;" intoString:NULL])
			[result appendString:@">"];
        else if ([scanner scanString:@"&nbsp;" intoString:NULL])
            [result appendString:@" "];
        else if ([scanner scanString:@"&cap;" intoString:NULL])
            [result appendString:@"∩"];
        else if ([scanner scanString:@"&middot;" intoString:NULL])
            [result appendString:@"·"];
		else if ([scanner scanString:@"&#" intoString:NULL]) {
			BOOL gotNumber;
			unsigned charCode;
			NSString *xForHex = @"";
			
			// Is it hex or decimal?
			if ([scanner scanString:@"x" intoString:&xForHex]) {
				gotNumber = [scanner scanHexInt:&charCode];
			}
			else {
				gotNumber = [scanner scanInt:(int*)&charCode];
			}
			
			if (gotNumber) {
				[result appendFormat:@"%C", charCode];
				[scanner scanString:@";" intoString:NULL];
			}
			else {
				NSString *unknownEntity = @"";				
				[scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
				[result appendFormat:@"&#%@%@", xForHex, unknownEntity];
				//[scanner scanUpToString:@";" intoString:&unknownEntity];
				//[result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
				NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
			}
			
		}
		else {
			NSString *amp;
			//an isolated & symbol
			[scanner scanString:@"&" intoString:&amp];
			[result appendString:amp];
		}
	}
	while (![scanner isAtEnd]);
	
finish:
	return result;
}

@end