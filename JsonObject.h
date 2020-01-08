//
//  JsonObject.h
//  JsonParser
//
//  Created by Maksym Nesterchuk on 12/5/19.
//  Copyright © 2019 Maksym Nesterchuk. All rights reserved.
//

#ifndef JsonObject_h
#define JsonObject_h

typedef NS_ENUM(NSUInteger, JsonType) {
    jsonObject,
    jsonArray,
    jsonString,
    jsonBoolean,
    jsonNumber,
    jsonNull,
    jsonUnknown
};

@interface JSParseException : NSException
@end

@interface JsonObject : NSObject
{
}

@property (nonatomic) JsonType mType;
@property (nonatomic) NSString* mStringValue;

- (instancetype) initWithType : (JsonType) type;
- (instancetype) init;

-(NSString *) toString;
-(NSInteger) length;

-(NSInteger) asInt;
-(double) asDouble;
-(BOOL) asBool;
-(NSNull *) asNul;
-(NSString *) asString;

-addPropertyKey : (NSString *) key andValue : (JsonObject *) value;
-addElement : (JsonObject *) object;
-addString : (NSString *) string;

-(JsonObject *) getByIndex : (NSInteger) index;
-(JsonObject *) getByProperty : (NSString *) property;
-(BOOL) isEqualToJsonObject : (JsonObject *) jsonObject;

@end

#endif /* JsonObject_h */
