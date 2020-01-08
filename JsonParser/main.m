//
//  main.m
//  JsonParser
//
//  Created by Maksym Nesterchuk on 11/21/19.
//  Copyright © 2019 Maksym Nesterchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "jsonParser.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        JsonObject* object = [JSParser parse : @"{\
            \"json\":[\
                {\
                    \"tag_name\": \"a\",\
                    \"attr\": [{\"key\": \"href\", \"value\": \"http\"}, {\"key\": \"target\", \"value\": \"_blank\"}]\
                },\
                {\
                    \"this_is\": [\"array\", \"of\", \"strings\"],\
                    \"number_array\": [1, 2, 4, 8, 16],\
                    \"double\": 3.14,\
                    \"boolean\": true,\
                    \"null\": null,\
                    \"mixed\": [1, 2, {\"test1\": -10.2345, \"test2\": false}, null, 0.4, [\"text\", [\"array\", true]], \"more text\"]\
                },\
                {\
                    \"done\": true\
                },\
                {\
                    \"control_chars\": \"\n\t\n\"\
                }\
            ]\
        } "];
        NSLog([object toString]);
    }
    return 0;
}
