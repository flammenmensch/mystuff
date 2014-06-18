//
//  MyWhatsit.m
//  MyStuff
//
//  Created by Алексей Протасов on 18.06.14.
//  Copyright (c) 2014 Alexey Protasov. All rights reserved.
//

#import "MyWhatsit.h"

@implementation MyWhatsit

- (id)initWithName:(NSString*)name location:(NSString*)location {
    self = [super init];
    
    if (self) {
        self.name = name;
        self.location = location;
    }
    
    return self;
}

- (void)postDidChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kWhatsitDidChangeNotification object:self];
}

@end
