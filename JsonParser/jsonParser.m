//
//  jsonParser.m
//  JsonParser
//
//  Created by Maksym Nesterchuk on 11/21/19.
//  Copyright © 2019 Maksym Nesterchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "jsonParser.h"
#define let __auto_type const
#define var __auto_type

@implementation Token

@synthesize mStringValue, mType;

- (instancetype) initWithString : (NSString *) string tokenType : (TokenType) type
{
    [self setMStringValue : string];
    [self setMType : type];
    return self;
}

@end


@implementation JSParser

+ (NSString *) deserialize : (NSString *) inputString
{
    NSMutableString* outputString = [[NSMutableString alloc] initWithString : @""];;
    for (int i = 0; i < [inputString length]; i++) {
        NSString* currentCharacter = [NSString stringWithFormat : @"%C", [inputString characterAtIndex : i]];
        NSString* nextCharacter = [NSString stringWithFormat : @"%C", [inputString characterAtIndex : i+1]];
        if ([currentCharacter isEqualToString : @"\\"] &&  i + 1 < [inputString length])
        {
            if ([nextCharacter isEqualToString : @"\""])
            {
                [outputString appendString : @"\""];
            }
            else if ([nextCharacter isEqualToString : @"\\"])
            {
                [outputString appendString : @"\\"];
            }
            else if ([currentCharacter isEqualToString : @"/"])
            {
                [outputString appendString : @"/"];
            }
            else if ([currentCharacter isEqualToString : @"b"])
            {
                [outputString appendString : @"\b"];
            }
            else if ([currentCharacter isEqualToString : @"f"])
            {
                [outputString appendString : @"\f"];
            }
            else if ([currentCharacter isEqualToString : @"n"])
            {
                [outputString appendString : @"\n"];
            }
            else if ([currentCharacter isEqualToString : @"t"])
            {
                [outputString appendString : @"\t"];
            }
            else if ([currentCharacter isEqualToString : @"r"])
            {
                [outputString appendString : @"\r"];
            }
            i++;
            continue;
        }
    [outputString appendString : currentCharacter];
    }
    
    return outputString;
}

+ (JsonObject *) parse : (NSString *) jsonString
{
    if ([jsonString length] == 0)
    {
        return [[JsonObject alloc] init];
    }
    NSInteger end;
    return [JSParser jsonParseWithTokens : [JSParser tokenize : jsonString] startPosition : 0 endPosition : &end];
}

+ (NSInteger) nextWhitespaceWithString : (NSString *) jsonString position : (NSInteger) pos
{
    while (pos < [jsonString length])
    {
        if ([[NSString stringWithFormat : @"%C", [jsonString characterAtIndex : pos]] isEqualToString : @"\""])
        {
            pos++;
            while (pos < [jsonString length] && (![[NSString stringWithFormat : @"%C", [jsonString characterAtIndex : pos]] isEqualToString : @"\""] ||
                                                 [[NSString stringWithFormat : @"%C", [jsonString characterAtIndex : pos - 1]] isEqualToString : @"\\"]))
            {
                pos++;
            }
        }
        
        if ([[NSString stringWithFormat : @"%C", [jsonString characterAtIndex : pos]] isEqualToString : @"'"])
        {
            pos++;
            while (pos < [jsonString length] && (![[NSString stringWithFormat : @"%C", [jsonString characterAtIndex : pos]] isEqualToString : @"'"] ||
                                                 [[NSString stringWithFormat : @"%C", [jsonString characterAtIndex : pos - 1]] isEqualToString : @"\\"]))
            {
                pos++;
            }
        }
        
        if (isspace([jsonString characterAtIndex : pos]))
        {
            return pos;
        }
        
        pos++;
    }
    return [jsonString length];
}

+ (NSArray<Token *> *) tokenize : (NSString *) source
{
    NSMutableString* inputString = [[NSMutableString alloc] initWithString : source];
    [inputString appendString : @" "];
    NSMutableArray* tokens = [[NSMutableArray alloc] init];
    NSInteger index = [JSParser skipWhiteSpaces : inputString position : 0];
    
    while (index >= 0)
    {
        NSInteger next = [JSParser nextWhitespaceWithString : inputString position : index];
        let tokenizeString = [inputString substringWithRange : NSMakeRange(index, next - index)];
        
        NSInteger pos = 0;
        while (pos < [tokenizeString length])
        {
            let currentPosTokenizeSymbol = [NSString stringWithFormat : @"%C", [tokenizeString characterAtIndex : pos]];
            if ([currentPosTokenizeSymbol isEqualToString : @"\""])
            {
                NSInteger nestedPos = pos + 1;
                while (nestedPos < [tokenizeString length] &&
                       (![[NSString stringWithFormat : @"%C", [tokenizeString characterAtIndex : nestedPos]] isEqualToString : @"\""] ||
                        [[NSString stringWithFormat : @"%C", [tokenizeString characterAtIndex : nestedPos]] isEqualToString : @"\\"]))
                {
                    nestedPos++;
                }
                let nestedString = [tokenizeString substringWithRange : NSMakeRange(pos + 1, nestedPos - pos - 1)];
                [tokens addObject : [[Token alloc] initWithString : nestedString tokenType : tokenString]];
                pos = nestedPos + 1;
                continue;
            }
            
            if ([currentPosTokenizeSymbol isEqualToString : @"'"])
            {
                NSInteger nestedPos = pos + 1;
                while (nestedPos < [tokenizeString length] &&
                       (![[NSString stringWithFormat : @"%C", [tokenizeString characterAtIndex : nestedPos]] isEqualToString : @"'"] ||
                        [[NSString stringWithFormat : @"%C", [tokenizeString characterAtIndex : nestedPos]] isEqualToString : @"\\"]))
                {
                    nestedPos++;
                }
                let nestedString = [tokenizeString substringWithRange : NSMakeRange(pos + 1, nestedPos - pos - 1)];
                [tokens addObject : [[Token alloc] initWithString : nestedString tokenType : tokenString]];
                pos = nestedPos + 1;
                continue;
            }
            
            if ([currentPosTokenizeSymbol isEqualToString : @","])
            {
                [tokens addObject : [[Token alloc] initWithString : @"," tokenType : tokenComm]];
                pos++;
                continue;
            }
            
            if (pos + 4 <= [tokenizeString length] && [[tokenizeString substringWithRange : NSMakeRange(pos, 4)] isEqualToString : @"true"])
            {
                [tokens addObject : [[Token alloc] initWithString : @"true" tokenType : tokenBoolean]];
                pos += 4;
                continue;
            }
            
            if (pos + 5 <= [tokenizeString length] && [[tokenizeString substringWithRange : NSMakeRange(pos, 5)] isEqualToString : @"false"])
            {
                [tokens addObject : [[Token alloc] initWithString : @"false" tokenType : tokenBoolean]];
                pos += 5;
                continue;
            }
            
            if (pos + 4 <= [tokenizeString length] && [[tokenizeString substringWithRange : NSMakeRange(pos, 4)] isEqualToString : @"null"])
            {
                [tokens addObject : [[Token alloc] initWithString : @"null" tokenType : tokenNull]];
                pos += 4;
                continue;
            }
            
            if ([currentPosTokenizeSymbol isEqualToString : @"}"])
            {
                [tokens addObject : [[Token alloc] initWithString : @"}" tokenType : tokenBracesClose]];
                pos++;
                continue;
            }
            
            if([currentPosTokenizeSymbol isEqualToString : @"{"])
            {
                [tokens addObject : [[Token alloc] initWithString : @"{" tokenType : tokenBracesOpen]];
                pos++;
                continue;
            }
            
            if([currentPosTokenizeSymbol isEqualToString : @"]"])
            {
                [tokens addObject : [[Token alloc] initWithString : @"]" tokenType : tokenBracketClose]];
                pos++;
                continue;
            }
            
            if([currentPosTokenizeSymbol isEqualToString : @"["])
            {
                [tokens addObject : [[Token alloc] initWithString : @"[" tokenType : tokenBracketOpen]];
                pos++;
                continue;
            }
            
            if([currentPosTokenizeSymbol isEqualToString : @"]"])
            {
                [tokens addObject : [[Token alloc] initWithString : @"]" tokenType : tokenBracketClose]];
                pos++;
                continue;
            }
            
            if([currentPosTokenizeSymbol isEqualToString : @":"])
            {
                [tokens addObject : [[Token alloc] initWithString : @":" tokenType : tokenColo]];
                pos++;
                continue;
            }
            
            if([currentPosTokenizeSymbol isEqualToString : @"-"] || isdigit([tokenizeString characterAtIndex : pos]))
            {
                NSInteger nestedPos = pos;
                
                if ([[NSString stringWithFormat : @"%C", [tokenizeString characterAtIndex : nestedPos]] isEqualToString : @"-"])
                {
                    nestedPos++;
                }
                BOOL alreadyWithDot = false;
                while (nestedPos < [tokenizeString length] && (isdigit([tokenizeString characterAtIndex : nestedPos]) ||
                                                               ([[NSString stringWithFormat : @"%C", [tokenizeString characterAtIndex : nestedPos]] isEqualToString : @"."] && !alreadyWithDot)))
                {
                    if ([[NSString stringWithFormat : @"%C", [tokenizeString characterAtIndex:nestedPos]] isEqualToString : @"."])
                    {
                        alreadyWithDot = true;
                    }
                    nestedPos++;
                }
                let nestedString = [tokenizeString substringWithRange : NSMakeRange(pos, nestedPos - pos)];
                [tokens addObject : [[Token alloc] initWithString : nestedString tokenType : tokenNumber]];
                pos = nestedPos;
                continue;
            }
            
            @throw [[JSParseException alloc] initWithName : @"JSParse Exception" reason : @"Unknown character" userInfo : nil];
        }
        
        index = [JSParser skipWhiteSpaces : inputString position : next];
    }
    return tokens;
}

+ (JsonObject *) jsonParseWithTokens : (NSArray<Token *> *) tokens startPosition : (NSInteger) startPos endPosition : (NSInteger *) endPos
{
    var current = [[JsonObject alloc] init];
    if ([[tokens objectAtIndex : startPos] mType] == tokenBracesOpen)
    {
        [current setMType : jsonObject];
        NSInteger parsedStartPos = startPos + 1;
        
        while ([[tokens objectAtIndex : parsedStartPos] mType] != tokenBracesClose) {
            if ([[tokens objectAtIndex : parsedStartPos] mType] == tokenComm)
            {
                parsedStartPos++;
            }
            else
            {
                if ([[tokens objectAtIndex : parsedStartPos - 1] mType] != tokenBracesOpen)
                {
                    @throw [[JSParseException alloc] initWithName : @"JSParse Exception" reason : @"Missing open braces or comma" userInfo : nil];
                }
            }
            
            let key = [[tokens objectAtIndex : parsedStartPos] mStringValue];
            parsedStartPos += 2;
            NSInteger parsedEndPos = parsedStartPos;
            let parsedObject = [JSParser jsonParseWithTokens : tokens startPosition : parsedStartPos endPosition : &parsedEndPos];
            [current addPropertyKey : key andValue : parsedObject];
            parsedStartPos = parsedEndPos;
        }
        
        *endPos = parsedStartPos + 1;
        return current;
    }
    
    if ([[tokens objectAtIndex : startPos] mType] == tokenBracketOpen)
    {
        [current setMType : jsonArray];
        NSInteger parsedStartPos = startPos + 1;
        
        while ([[tokens objectAtIndex : parsedStartPos] mType] != tokenBracketClose) {
            if ([[tokens objectAtIndex : parsedStartPos] mType] == tokenComm)
            {
                parsedStartPos++;
            }
            else
            {
                if ([[tokens objectAtIndex : parsedStartPos - 1] mType] != tokenBracketOpen)
                {
                    @throw [[JSParseException alloc] initWithName : @"JSParse Exception" reason : @"Missing open brakcets or comma" userInfo : nil];
                }
            }
            
            NSInteger parsedEndPos = parsedStartPos;
            let parsedObject = [JSParser jsonParseWithTokens : tokens startPosition : parsedStartPos endPosition : &parsedEndPos];
            [current addElement : parsedObject];
            parsedStartPos = parsedEndPos;
        }
        
        *endPos = parsedStartPos + 1;
        return current;
    }
 
    if ([[tokens objectAtIndex : startPos] mType] == tokenNumber)
    {
        [current setMType : jsonNumber];
        [current setMStringValue : [[tokens objectAtIndex : startPos] mStringValue]];
        *endPos = startPos + 1;
        return current;
    }
    
    if ([[tokens objectAtIndex : startPos] mType] == tokenString)
    {
        [current setMType : jsonString];
        [current setMStringValue : [[tokens objectAtIndex : startPos] mStringValue]];
        *endPos = startPos + 1;
        return current;
    }
    
    if ([[tokens objectAtIndex:startPos] mType] == tokenBoolean)
    {
        [current setMType : jsonNumber];
        [current setMStringValue : [[tokens objectAtIndex : startPos] mStringValue]];
        *endPos = startPos + 1;
        return current;
    }
    
    if ([[tokens objectAtIndex : startPos] mType] == tokenNull)
    {
        [current setMType : jsonNull];
        [current setMStringValue : @"null"];
        *endPos = startPos + 1;
        return current;
    }
    
    if ([current isEqual : [[JsonObject alloc] init]])
    {
        @throw [[JSParseException alloc] initWithName : @"JSParse Exception" reason : @"Nothing parsed" userInfo : nil];
    }
    
    return current;
}

+ (NSInteger) skipWhiteSpaces : (NSString *) jsonString position : (NSInteger) pos
{
    while (pos < [jsonString length])
    {
        if (!isspace([jsonString characterAtIndex : pos]))
        {
            return pos;
        }
        pos++;
    }
    return -1;
}

@end
 
