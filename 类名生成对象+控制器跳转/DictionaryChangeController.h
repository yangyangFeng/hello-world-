//
//  DictionaryChangeController.h
//  链式函数
//
//  Created by 邴天宇 on 15/9/6.
//  Copyright (c) 2015年 邴天宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictionaryChangeController : NSObject
/*!
 *  set Controller Name
 */
-(DictionaryChangeController *(^)(NSString * ControllerName))controllerName;
/*!
 *  set Property Dictionary
 */
-(DictionaryChangeController *(^)(NSDictionary * propertys))property;
/*!
 *  get Controller Object
 */
-(id)instanceObject;


- (DictionaryChangeController *)and;
- (DictionaryChangeController *)with;
@end
