//
//  HUWebSocketAuthMessage.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 13.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HUWebSocketMessageModels.h"

/**
    @constant AUTH_REQUEST_MESSAGE_TYPE
        Сообщение  запроса аутентификации
    @constant AUTH_SUCCESS_RESPONSE_MESSAGE_TYPE
        Сообщение при успешной аутентификации
    @constant AUTH_BAD_RESPONSE_MESSAGE_TYPE
        В случае неудачной аутентификации (неправильный пароль / не найден клиент)
    @constant AUTH_VALIDATION_ERROR_MESSAGE_TYPE
        В случае ошибки валидации данных на сервере (пароль пустой / email не проходит regExp)
 */

extern NSString* const AUTH_REQUEST_MESSAGE_TYPE;
extern NSString* const AUTH_SUCCESS_RESPONSE_MESSAGE_TYPE;
extern NSString* const AUTH_BAD_RESPONSE_MESSAGE_TYPE;
extern NSString* const AUTH_VALIDATION_ERROR_MESSAGE_TYPE;

/**
    @class HUWebSocketAuthMessage
    @abstract Класс для сообщения аутентификации
    @discussion
    Используется для объектов-сообщений аутентификации. Имеет метод isAuthSuccess, отвечающий на вопрос - "Успешна ли была аутентификация"
    
    @note Фабрика HUWebSocketMessageFactory проверяет сигнатуру словаря с помощью predefinedTypes.  Если один из типов совпадает - определяет объект сообщения текущего подкласса.
 */
@interface HUWebSocketAuthMessage : HUWebSocketMessage

+ (NSArray <NSString*>*)predefinedTypes;

- (BOOL)isAuthSuccess;

@end
