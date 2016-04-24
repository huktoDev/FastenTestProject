//
//  HUWebSocketMessageFactory.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 13.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HUWebSocketMessageModels.h"
#import "HUWebSocketAuthMessage.h"
#import "HUWebSocketAuthUserRequisites.h"

/**
    @protocol HUWebSocketCustomMessagesProtocol
    @abstract Протокол, определяющий выбор типа сообщения
    @discussion
    Протокол, используемый фабрикой, с помощью которого  фабрика сообщений определяет, какой конкретно класс сообщения ей требуется создать
 */
@protocol HUWebSocketCustomMessagesProtocol <NSObject>

@required
+ (NSArray <NSString*> *)predefinedTypes;

@end

NSArray <NSString*>* knownMessagesTypes();

/**
    @class HUWebSocketMessageFactory
    @abstract Абстрактный класс, фабрика, генерирующая сообщения для сетевого взаимодействия
 */
@interface HUWebSocketMessageFactory : NSObject

+ (HUWebSocketMessage*)messageWithDictionary:(NSDictionary*)dictionaryMessage;
+ (HUWebSocketAuthMessage*)authMessageWithUserRequisites:(HUWebSocketAuthUserRequisites*)userRequisites;   //Email:(NSString*)email withPassword:(NSString*)password;

@end
