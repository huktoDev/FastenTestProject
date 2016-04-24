//
//  APIRequestModel.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 10.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

/**
 ===================================================================================================================
    @framework JSONModel
    Используется для маппинга
    (автогенерации объектных моделей из объекта словаря, формируемого из JSON-строки)
 
    @see https://github.com/icanzilb/JSONModel
 
    @note Для сопосталения ключей словаря со свойствами класса - переопределяются методы + (JSONKeyMapper*)keyMapper
    @note Для создания любого объекта сообщения - использовать требуется фабрику HUWebSocketMessageFactory
  ===================================================================================================================
 */


/**
    @protocol HUWebSocketMessageDataProtocol
    @abstract Предоставляет искомую сигнатуру словаря
    @discussion
    Интерфейс, определяемый моделью, чтобы алгоритм мог определить по словарю, что это именно нужная модель.
    Содержит только 1 метод, предоставляющий "сигнатуру" объекта, а именно список ключей, которые должны быть в словаре при инициализации, чтобы модель успешно идентифицировалась.
    Все объекты данных сообщения должны определять в себе этот протокол
 */
@protocol HUWebSocketMessageDataProtocol <NSObject>

@required
+ (NSArray <NSString*> *)JSONDataBaseSignature;

@end

NSArray <NSValue*>* knownMessageDataTypes();

@class HUWebSocketMessageData;
@class HUWebSocketErrorEventDescription;
@class HUWebSocketAuthDataRequest, HUWebSocketAuthDataSuccessResponse, HUWebSocketAuthDataBadResponse;

#pragma mark - Main message Model

/**
    @class HUWebSocketMessage
    @abstract Основная модель для сообщение по веб-сокету
    @discussion
    Используется при любом взаимодействии по веб-сокету. Так как все запросы и ответы унифицированы - то их удобно маппить в подобного вида модель.

    @property messageType       Используется для идентификации типа сообщения (чтобы размаппить соответствующие messageData класс)
    @property sequenceID        Используется для идентификации взаимосвязанных последовательностей сообщений
    @property messageData       Тело сообщения, содержит конкретные данные сообщения
 
    @note При инициализации словарем - в messageData автоматически предоставляется требуемый объект с интерфейсом HUWebSocketMessageDataProtocol  ( в методе setMessageDataWithNSDictionary )
    @warning класс messageData не фиксирован - на этапе выполнения в это свойство можно подставить любую модель данных.
 */
@interface HUWebSocketMessage : JSONModel

@property (copy, nonatomic) NSString *messageType;
@property (copy, nonatomic) NSString *sequenceID;
@property (strong, nonatomic) id<HUWebSocketMessageDataProtocol> messageData;

@end

#pragma mark - Messages submodels

/**
    @class HUWebSocketAuthDataRequest
    @abstract Данные запроса аутентификации
    @discussion
    Используется для описания запроса аутентификации
    На текущий момент передается для аутентификации - только 2 параметра :
    <li> @property email - адрес электронной почты
    <li> @property password - пароль (в незащищенном виде)
 */
@interface HUWebSocketAuthDataRequest : JSONModel <HUWebSocketMessageDataProtocol>

@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *password;

@end

/**
    @class HUWebSocketAuthDataSuccessResponse
    @abstract Данные успешной аутентификации
    @discussion
    Используется для описания данных успешной аутентификации
 
    При успешной аутентификации - передается 2 параметра :
    <li> @property apiToken - уникальный идентификатор сессии для пользователя (токен)
    <li> @property apiTokenExpirationDateString - стандартизированная форматированная строка даты (время, когда у пользователя завершается текущая сессия)
 
    @method expirationDate Создает из стандартизированной строки времени - объект даты
 */
@interface HUWebSocketAuthDataSuccessResponse : JSONModel <HUWebSocketMessageDataProtocol>

@property (copy, nonatomic) NSString *apiToken;
@property (copy, nonatomic) NSString *apiTokenExpirationDateString;

- (NSDate*)expirationDate;

@end

/**
    @class HUWebSocketAuthDataBadResponse
    @abstract Данные неудачной аутентификации
    @discussion
    Если пользователю не удалось выполнить аутентификацю - здесь будут лежать данные, связанные с неудачной аутентификацией
 
    @property errorDescription Описание причины неудачной аутентификации (<b> используется только это свойство на текущий момент </b>)
 
    @note incomingEvent и errors - опциональные свойства (могут не содержаться в инициализирующем словаре)
 */
@interface HUWebSocketAuthDataBadResponse : JSONModel <HUWebSocketMessageDataProtocol>

@property (copy, nonatomic) NSString *errorDescription;
@property (copy, nonatomic) NSString *errorCode;
@property (copy, nonatomic) NSString *errorUUID;
@property (strong, nonatomic) HUWebSocketErrorEventDescription <Optional> *incomingEvent;
@property (strong, nonatomic) NSArray <Optional> *errors;

@end

#pragma mark - Error Description

/**
    @class HUWebSocketErrorEventDescription
    @abstract Данные эвента, в результате которого произошла ошибка на сервере
    @discussion
    Можно использовать для определения причин различного рода проблем с сообщениями
 */
@interface HUWebSocketErrorEventDescription : JSONModel

@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *sequenceID;

@property (copy, nonatomic) NSString *customerID;
@property (copy, nonatomic) NSString *eventID;

@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString <Optional> *imei;

@end





