//
//  Register.m
//  Smartlock
//
//  Created by RivenL on 15/4/11.
//  Copyright (c) 2015年 RivenL. All rights reserved.
//

#import "Register.h"

@implementation Register

+ (void)verifyPhone:(NSString *)phone withBlock:(void (^)(id, NSError *))block {
    void (^callbackBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
        if(error) {
            DLog(@"error = %@", error);
            if(block) {
                block(nil, error);
            }
            return ;
        }
        BaseResponse *response = [[BaseResponse alloc] initWithResponseObject:responseObject];
        
        if(block) {
            block(response, nil);
        }
    };
    
    [RegisterRequest verifyPhone:phone withBlock:callbackBlock];
}

+ (void)getAuthcode:(NSString *)phone withBlock:(void (^)(id , NSError *))block {
    void (^callbackBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
        if(error) {
            DLog(@"error = %@", error);
            if(block) {
                block(nil, error);
            }
            return ;
        }
         BaseResponse *response = [[BaseResponse alloc] initWithResponseObject:responseObject];
        
        if(block) {
            block(response, nil);
        }
    };
    
    [RegisterRequest getAuthcode:phone withBlock:callbackBlock];
}

+ (void)verifyAuthcode:(NSString *)phone authcode:(NSString *)authcode withBlock:(void (^)(id, NSError *))block {
    void (^callbackBlock)(id responseObject, NSError *error) = ^(id responseObject, NSError *error) {
        if(error) {
            DLog(@"error = %@", error);
            if(block) {
                block(nil, error);
            }
            return ;
        }
        BaseResponse *response = [[BaseResponse alloc] initWithResponseObject:responseObject];
        if(response.status == 0) {
            User *user = [User sharedUser];
            user.phone = phone;
        }
        if(block) {
            block(response, nil);
        }
    };
    
    [RegisterRequest verifyAuthcode:phone authcode:authcode withBlock:callbackBlock];
}

+ (void)register:(RegisterModel *)aRegister withBlock:(void (^)(RegisterResponse *response, NSError *error))block {
    void (^callbackBlock)(RegisterResponse *responseObject, NSError *error) = ^(RegisterResponse *responseObject, NSError *error) {
        if(error) {
            DLog(@"error = %@", error);
            if(block) {
                block(nil, error);
            }
            return ;
        }
        RegisterResponse *response = [[RegisterResponse alloc] initWithResponseObject:responseObject];
        if(response.status == 0) {
            [[User sharedUser] setWithParameters:(NSDictionary *)responseObject];
        }
        if(block) {
            block(response, nil);
        }
    };
    
    [RegisterRequest register:aRegister withBlock:callbackBlock];
}

+ (void)findPassword:(FindPasswordModel *)findPasswordModel withBlock:(void (^)(RegisterResponse *, NSError *))block {
    void (^callbackBlock)(RegisterResponse *responseObject, NSError *error) = ^(RegisterResponse *responseObject, NSError *error) {
        if(error) {
            DLog(@"error = %@", error);
            if(block) {
                block(nil, error);
            }
            return ;
        }
        RegisterResponse *response = [[RegisterResponse alloc] initWithResponseObject:responseObject];
        if(response.status == 0) {
//            User *user = [User sharedUser];
        }
        if(block) {
            block(response, nil);
        }
    };
    
    [RegisterRequest findPassword:findPasswordModel withBlock:callbackBlock];
}
@end
