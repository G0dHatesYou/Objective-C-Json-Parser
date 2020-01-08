//
//  JsonObject.m
//  JsonParser
//
//  Created by Maksym Nesterchuk on 12/5/19.
//  Copyright © 2019 Maksym Nesterchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonObject.h"
#import "jsonParser.h"

@implementation JSParseException
@end

@interface JsonObject()
{
    NSMutableDictionary<NSString *, NSNumber *>* mDictionary;
    NSMutableDictionary<NSString *, JsonObject *>* mProperties;
    NSMutableArray<JsonObject *>* mArray;
}

-(NSString *) makeSpace : (NSInteger) space; //pretty space
-(NSString *) toStringWithSpace : (NSInteger) space;

@end

@implementation JsonObject

@synthesize mStringValue, mType;

- (instancetype) init
{
    if (self = [super init])
    {
        [self setMType : jsonUnknown];
        [self setMStringValue : @""];
        mDictionary = [[NSMutableDictionary alloc] init];
        mProperties = [[NSMutableDictionary alloc] init];
        mArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype) initWithType : (JsonType) type
{
    if (self = [super init])
    {
        [self setMType : type];
        [self setMStringValue : @""];
        mDictionary = [[NSMutableDictionary alloc] init];
        mProperties = [[NSMutableDictionary alloc] init];
        mArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *) toString
{
    return [self toStringWithSpace : 1];
}

- (NSInteger) length
{
    if (mType == jsonArray)
    {
        return [mArray count];
    }
    if (mType == jsonObject)
    {
        return [mProperties count];
    }
    return 0;
}

- (NSInteger) asInt
{
    return [mStringValue intValue];
}

- (double) asDouble
{
    return [mStringValue doubleValue];
}

- (BOOL) asBool
{
    if ([mStringValue isEqualToString : @"true"])
    {
        return true;
    }
    return false;
}

- (NSNull *) asNul
{
    return [NSNull init];
}

- (NSString *) asString
{
    return [JSParser deserialize : mStringValue];
}

- (id) addPropertyKey : (NSString *) key andValue : (JsonObject *) value
{
    [mDictionary setObject : [NSNumber numberWithInteger : [mProperties count]] forKey : key];
    [mProperties setObject : value forKey : key];
    return self;
}

- (id) addElement : (JsonObject *) object
{
    [mArray addObject : object];
    return self;
}


- (id) addString : (NSString *) string
{
    [self setMStringValue : string];
    return self;
}

- (JsonObject *) getByIndex : (NSInteger) index
{
    if (mType == jsonArray)
    {
        return [mArray objectAtIndex : index];
    }
    if (mType == jsonObject)
    {
        NSArray *keys = [mProperties allKeys];
        return [mProperties objectForKey : [keys objectAtIndex : index]];
    }
    return [[JsonObject alloc] init];
}

- (JsonObject *) getByProperty : (NSString *) property
{
    NSNumber* value = [mDictionary objectForKey : property];
    if (value)
    {
        NSArray* keys = [mProperties allKeys];
        return [mProperties objectForKey : [keys objectAtIndex : [value integerValue]]];
    }
    return [[JsonObject alloc] init];
}

- (NSString *) makeSpace : (NSInteger) space
{
    NSMutableString* outputString = [[NSMutableString alloc] initWithString : @""];;
    while (space--)
    {
        [outputString appendString : @" "];
    }
    return outputString;
}

- (NSString *) toStringWithSpace : (NSInteger) space
{
    NSMutableString* outputString = [[NSMutableString alloc] initWithString : @"\""];
    [outputString appendString : mStringValue];
    [outputString appendString : @"\""];
    switch (mType)
    {
        case jsonString:
            return outputString;
            break;
        case jsonBoolean:
            return mStringValue;
            break;
        case jsonNumber:
            return mStringValue;
            break;
        case jsonNull:
            return @"null";
            break;
        case jsonUnknown:
            return @"unknown";
            break;
        case jsonObject:
            {
                NSArray* keys = [mProperties allKeys];
                NSMutableString* objectString = [[NSMutableString alloc] initWithString : @"{\n"];
                for (int i = 0; i < [mProperties count]; i++)
                {
                    [objectString appendString : [self makeSpace:space]];
                    [objectString appendString : @"\""];
                    [objectString appendString : [keys objectAtIndex:i]];
                    [objectString appendString : @"\":"];
                    [objectString appendString : [[mProperties objectForKey : [keys objectAtIndex : i]] toStringWithSpace : space + 1]];
                    if (i == [mProperties count] - 1)
                    {
                        [objectString appendString : @","];
                    }
                    [objectString appendString : @"\n"];
                }
                [objectString appendString : [self makeSpace : space - 1]];
                [objectString appendString : @"}"];
                return objectString;
            }
            break;
        case jsonArray:
            {
                NSMutableString* arrayString = [[NSMutableString alloc] initWithString : @"["];
                for (int i = 0; i < [mArray count]; i++)
                {
                    if (i)
                    {
                        [arrayString appendString : @", "];
                    }
                    [arrayString appendString : [[mArray objectAtIndex : i] toStringWithSpace : space + 1]];
                }
                [arrayString appendString : @"]"];
                return arrayString;
            }
            break;
        default:
            break;
    }
    return @"error";
}

- (BOOL) isEqualToJsonObject : (JsonObject *) otherObject {
    return (mStringValue == [otherObject mStringValue] && [self mType] == [otherObject mType]);
}

@end
