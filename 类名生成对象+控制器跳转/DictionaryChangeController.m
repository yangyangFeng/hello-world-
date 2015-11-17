//
//  DictionaryChangeController.m
//  链式函数
//
//  Created by 邴天宇 on 15/9/6.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//

#import "DictionaryChangeController.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@interface DictionaryChangeController ()
{
    id _instanceObject;
}

//如果使用属性,必须 strong 否则会提前释放.
//@property (nonatomic, strong) id instanceObject;

@end

@implementation DictionaryChangeController

- (DictionaryChangeController* (^)(NSString*))controllerName
{

    //        return ^(NSString *controllerName){
    return ^DictionaryChangeController*(NSString* controllerName)
    {

        // 类名
        NSString* class = controllerName;
        const char* className = [class cStringUsingEncoding:NSASCIIStringEncoding];
        // 从一个字串返回一个类
        Class newClass = objc_getClass(className);
        if (!newClass) {
            // 创建一个类
            Class superClass = [NSObject class];
            newClass = objc_allocateClassPair(superClass, className, 0);
            // 注册你创建的这个类
            objc_registerClassPair(newClass);
        }
        // 创建对象
        id instance = [[newClass alloc] init];

        _instanceObject = instance;
        return self;
    };
    

}

- (DictionaryChangeController* (^)(NSDictionary*))property
{
     __weak typeof(self) weakself = self;
    return ^DictionaryChangeController*(NSDictionary* propertys)
    {
        if (propertys) {
            [propertys enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                // 检测这个对象是否存在该属性
                if ([weakself checkIsExistPropertyWithInstance:_instanceObject verifyPropertyName:key]) {
                    // 利用kvc赋值
                    [_instanceObject setValue:obj forKey:key];
                }
            }];
        }

        return self;
    };
}



- (BOOL)checkIsExistPropertyWithInstance:(id)instance verifyPropertyName:(NSString*)verifyPropertyName
{
    unsigned int outCount, i;
    // 获取对象里的属性列表
    objc_property_t* properties = class_copyPropertyList([instance class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //  属性名转成字符串
        NSString* propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        // 判断该属性是否存在
        if ([propertyName isEqualToString:verifyPropertyName]) {
            free(properties);
            return YES;
        }
    }
    free(properties);
    return NO;
}

-(DictionaryChangeController *)and
{
    return self;
}

-(DictionaryChangeController *)with
{
    return self;
}


-(id)instanceObject
{
    return _instanceObject;
}

@end
