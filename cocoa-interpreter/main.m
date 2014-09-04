//
//  main.m
//  cocoa-interpreter
//
//  Created by Dominik Pich on 7/4/12.
//  Copyright (c) 2012 info.pich. All rights reserved.
//
@import Foundation;
#import "defines.h"
#import "DDChecksum.h"
#import "NSTask+Clang.h"
#import "NSTASK+ProcessString.h"

#define FM NSFileManager.defaultManager

//call clang
int compile(NSMutableString *objC, NSStringEncoding encoding, NSString **file) {

  //get md5
  NSData   * data = [objC dataUsingEncoding:encoding];
  NSString *  md5 = [data checksum:DDChecksumTypeMD5];

  //get paths
  NSString  * out = [NSTemporaryDirectory()  stringByAppendingPathComponent:md5],
  * mFile = [[NSTemporaryDirectory() stringByAppendingPathComponent:md5] stringByAppendingPathExtension:@"m"];

  //see if we have in and out
  if([FM fileExistsAtPath:mFile] && [FM fileExistsAtPath:out]) {
    data = [NSData dataWithContentsOfFile:mFile];
    NSString *oldMd5 =

    if([[data checksum:DDChecksumTypeMD5] isEqualToString:md5]) {
      //all up to date
    }
    return 0;
  }
}


//write it right now
[objC writeToFile:in atomically:YES encoding:encoding error:nil];

//call clang
NSTask *task = [NSTask clangForFile:in outputTo:out];
[task waitUntilExit];
return [task terminationStatus];
}

}
[objC deleteCharactersInRange:NSMakeRange(0, index)];


//add main body
[objC insertString:scriptArgs?scriptArgs:EMPTY_ARGS atIndex:0];
[objC insertString:progName atIndex:0];
[objC insertString:MAIN_OPEN atIndex:0];
[objC insertString:IMPORT_COCOA atIndex:0];
[objC insertString:IMPORT_ATOZ atIndex:0];
[objC appendString:MAIN_CLOSE];

//preprocess it by replacing calls to shell (in backtickes) with calls to RunTask
NSInteger replaces = [NSTask processString:objC];
if(replaces < 0) {
  printf("failed to preprocess script");
  return -4;
}

return 0;
}

//entry point
int main(int argc, const char * argv[])
{
  if(argc<INTERPRETER_ARGS_COUNT) {
    printf("Usage: cocoa-interpreter FILE [args] or embed #!<PATHT_TO_cocoa-interpreter> in your objective-C shell script");
    return -1;
  }

  @autoreleasepool {
    //open file
    NSStringEncoding encoding = 0;
    NSError *error = nil;
    NSMutableString *objC = [NSMutableString stringWithContentsOfFile:@(argv[1]) usedEncoding:&encoding error:&error];
    if(!objC.length) {
      printf("cocoa-interpreter failed to read script at %s. File not found or bad encoding %ld", argv[1], encoding);
      if(error) {
        printf("Underlying error: %s", error.description.UTF8String);
      }
      return -1;
    }

    int res = prepare(objC, encoding, argc, argv);
    if(res!=0) {
      printf("Preparation (adding includes, main method, arguments array) of script failed");
      return res;
    }

    NSString *path = nil;
    res = compile(objC, encoding, &path);
    if(res!=0) {
      printf("Compilation of script failed");
      return res;
    }

    NSTask *task = [NSTask launchedTaskWithLaunchPath:path arguments:[NSArray array]];
    [task waitUntilExit];
    res = task.terminationStatus;
    if(res!=0) {
      //            printf(@"Script was executed but failed: %d", res);
      return res;
    }
  }
  return 0;
}

