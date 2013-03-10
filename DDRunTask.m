//
//  DDRunTask.c
//  cocoa-interpreter
//
//  Created by Dominik Pich on 7/15/12.
//  Copyright (c) 2012 info.pich. All rights reserved.
//

#import <objc/objc.h>
//#import <objc/runtime.h>

NSArray* DefinedClassesInBundle(NSBundle *bundle);
NSArray* DefinedClassesInBundle(NSBundle *bundle){

	Class *classes = NULL;
	NSMutableArray *classObjects = NSMutableArray.new;
	int numClasses = objc_getClassList(NULL, 0);
	if (numClasses > 0 ){
		classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
		numClasses = objc_getClassList(classes, numClasses);
		for (int i = 0; i < numClasses; i++) [classObjects addObject:classes[i]];
	}
	free(classes);
	return classObjects.copy ?: nil;
}
/*
	int numberOfClasses = objc_getClassList(NULL, 0);
	
//	Class *classes = calloc(sizeof(Class), numberOfClasses);
	__strong Class *classes = calloc(sizeof(Class), numberOfClasses);
//	numberOfClasses = objc_getClassList(classes, numberOfClasses);
	for (int i = 0; i < numberOfClasses; ++i) {
		Class c = classes[i];
		if ([NSBundle bundleForClass:c] == self) [array addObject:c];
	}
	free(classes);
	return array.copy;
}
*/

BOOL LoadFramework(NSString *name, ...);
BOOL LoadFramework(NSString *name, ...) {

	NSString *frameworkPath = [@"/Library/Frameworks" stringByAppendingPathComponent:name].stringByResolvingSymlinksInPath;
	NSBundle *b = [NSFileManager.defaultManager fileExistsAtPath:frameworkPath] ? [NSBundle bundleWithPath:frameworkPath] : nil;
	BOOL loaded = [b load];
	loaded ? NSLog(@"Framework loaded... Primary Class: %@", b.principalClass) : NSLog(@"Error, framework failed to load.");
	return loaded;
}
	


NSString *DDRunTask(NSString *command, ...);
NSString *DDRunTask(NSString *command, ...) {	va_list varargs;	va_start(varargs, command);
												id arg = nil;		NSMutableArray *args = NSMutableArray.new;
	// var args to string array
	while ((arg = va_arg(varargs,id))) {	id argString = [[arg description] stringByExpandingTildeInPath];
											[args addObject:argString];
	} 										va_end(varargs);		

	if(![command hasPrefix:@"./"] && ![command hasPrefix:@"/"]) {	[args insertObject:command atIndex:0];
																	command = @"/usr/bin/env";
	}	// add env if needed
	@autoreleasepool {
	
		NSMutableData  *readData = NSMutableData.new;	NSPipe 			   *pipe = NSPipe.new;
		NSFileHandle *fileHandle = pipe.fileHandleForReading;
//		NSData 			   *data = nil;
		NSTask 			   *task = NSTask.new;
		task.launchPath			 = command;
		task.arguments			 = args.count != 0 ? args : nil;
		task.standardOutput		 = pipe;
		
		[readData setLength:0];
		[task launch];
		while ( task && task.isRunning )	{
//			data = ;
			[readData appendData:fileHandle.availableData];//data];
		}
		return [NSString.alloc initWithData:readData encoding:NSUTF8StringEncoding];
	}
	return nil;
}