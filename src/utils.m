/*
* MIT License
*
* Copyright (c) 2020-2021 EntySec
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

#import "utils.h"

@implementation Utils

-(NSArray *)splitString:(NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSString *substring;
    NSMutableArray *array = [[NSMutableArray alloc] init];

    while (scanner.scanLocation < string.length) {
        unichar character = [string characterAtIndex:scanner.scanLocation];
        if (character == '"') {
            [scanner setScanLocation:(scanner.scanLocation + 1)];
            [scanner scanUpToString:@"\"" intoString:&substring];
            [scanner setScanLocation:(scanner.scanLocation + 1)];
        } else if (character == '\'') {
            [scanner setScanLocation:(scanner.scanLocation + 1)];
            [scanner scanUpToString:@"'" intoString:&substring];
            [scanner setScanLocation:(scanner.scanLocation + 1)];
        } else
            [scanner scanUpToString:@" " intoString:&substring];
        [array addObject:substring];

        if (scanner.scanLocation < string.length)
            [scanner setScanLocation:(scanner.scanLocation + 1)];
    }

    return array.copy;
}

@end
