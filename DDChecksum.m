//
//  DDChecksum.m
//  Created by Dominik Pich on 26.03.11.
//
#import "DDChecksum.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (DDChecksum)

#pragma mark sha

+ (NSString *)hexForDigest:(unsigned char*)ret ofLength:(int)l {         NSMutableString* output = NSMutableString.new;  //stringWithCapacity:l * 2];

	if(!ret || l <= 0) return nil; for(int i = 0; i < l; i++) [output appendFormat:@"%02x", ret[i]];
  return output;
}


- (NSString*)checksum:(DDChecksumType)type {


  int              l = type == DDChecksumTypeSha512 ? CC_SHA512_DIGEST_LENGTH : CC_MD5_DIGEST_LENGTH;    // DDChecksumTypeMD5
  unsigned char digest[type == DDChecksumTypeSha512 ? CC_SHA512_DIGEST_LENGTH : CC_MD5_DIGEST_LENGTH];
  return [self.class hexForDigest:type == DDChecksumTypeSha512 ? CC_SHA512(self.bytes, (CC_LONG)self.length, digest)
                                   /* unsigned char *ret */    : CC_MD5   (self.bytes, (CC_LONG)self.length, digest) ofLength:l];
}

@end