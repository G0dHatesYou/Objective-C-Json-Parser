//
//  Header.h
//  JsonParser
//
//  Created by Maksym Nesterchuk on 11/21/19.
//  Copyright © 2019 Maksym Nesterchuk. All rights reserved.
//

#ifndef Header_h
#define Header_h

#import "JsonObject.h"
#import "jsonParser.h"

typedef NS_ENUM(NSUInteger, TokenType) {
    tokenString,
    tokenNumber,
    tokenBoolean,
    tokenBracesOpen,
    tokenBracesClose,
    tokenBracketOpen,
    tokenBracketClose,
    tokenComm,
    tokenColo,
    tokenNull,
    tokenUnknow
};

@interface Token : NSObject
{
}
@property NSString* mStringValue;
@property TokenType mType;

- (instancetype) initWithString : (NSString *) string tokenType : (TokenType) type;

@end


@interface JSParser : NSObject
{
    
}

+(NSString *) deserialize : (NSString *) inputString;
+(JsonObject *) parse : (NSString *) jsonString;
+(NSInteger) nextWhitespaceWithString : (NSString *) jsonString position : (NSInteger) pos;
+(NSInteger) skipWhiteSpaces : (NSString *) jsonString position : (NSInteger) pos;//private
+(NSArray<Token *> *) tokenize : (NSString *) source;
+(JsonObject *) jsonParseWithTokens : (NSArray<Token *> *) tokens startPosition : (NSInteger) startPos endPosition : (NSInteger *) endPos;

@end
#endif /* Header_h */
