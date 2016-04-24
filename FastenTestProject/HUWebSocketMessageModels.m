//
//  APIRequestModel.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 10.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HUWebSocketMessageModels.h"
#import "HURFC3339DateFormatter.h"

/**
    @function knownMessageDataTypes()
    @abstract Список объектов известных классов данных
    @discussion
    Определяет список объектов известных классов данных для маппинга данных сообщения. 
    Указатели на объект класса оборачиваются в NSValue
 
    @note Определяется только 1 раз, при первом выполнении. В остальных случаях - отдается уже готовый массив.
    @return Массив известных классов данных
 */
NSArray <NSValue*>* knownMessageDataTypes(){
    
    static NSArray <NSValue*> *knownMessageDataTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        knownMessageDataTypes = @[
            [NSValue valueWithPointer:(__bridge const void * _Nullable)([HUWebSocketAuthDataRequest class])],
            [NSValue valueWithPointer:(__bridge const void * _Nullable)([HUWebSocketAuthDataSuccessResponse class])],
            [NSValue valueWithPointer:(__bridge const void * _Nullable)([HUWebSocketAuthDataBadResponse class])]];
    });
    
    return knownMessageDataTypes;
}

#pragma mark - Main message Model

@implementation HUWebSocketMessage

+ (JSONKeyMapper*)keyMapper{
    
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                @"type": @"messageType",
                @"sequence_id": @"sequenceID",
                @"data": @"messageData" }];
}

/**
    @abstract Выполнение маппинга данных сообщения
    @discussion
    Одной из проблем, с которой столкнулся при построении подобного рода архитектуры - была проблема определения конкретного типа сообщения. Сначала не заметил наличие type, и возникла идея того, что каждая модель сообщения должна знать сигнатуру словаря данных, который ей подходит.
 
    <ol type="1">
        <li> Сигнатура словаря определяется с помощью протокола HUWebSocketMessageDataProtocol
        <li> Если сигнатура схожа - генерится объкт конкретного определенного типа
    </ol>
 
    @param messageDict Словарь, определяющий данные сообщения
 */
- (void)setMessageDataWithNSDictionary:(NSDictionary*)messageDict {
    
    // MARK : К сожалению, сразу не заметил наличие type, с помощью которой идентификация была бы в разы проще. Но код было жалко, и сделал комбинрованный алгоритм, сверяющий одновременно и тип, и наличие требуемых ключей в мапе =)
    
    // Получение известных типов данных
    NSArray <NSValue*> *messageDataTypes = knownMessageDataTypes();
    for (NSValue *dataTypeClassValue in messageDataTypes) {
        
        Class dataTypeClass = (Class)[dataTypeClassValue pointerValue];
        
        // Если класс не определяет требуемый протокол - ошибка
        BOOL hasSignatureDefinitionInerface = [dataTypeClass conformsToProtocol:@protocol(HUWebSocketMessageDataProtocol)];
        NSAssert(hasSignatureDefinitionInerface, @"ERROR : Current Data type class not have Signature Definition Interface !!!");
        if(! hasSignatureDefinitionInerface){
            continue;
        }
        
        // Получение сигнатуры для текущего класса, и сравнение сигнатур
        NSArray <NSString*> *classJSONSignature = [dataTypeClass JSONDataBaseSignature];
        BOOL isSignatureSimilar = YES;
        for (NSString *checkingJSONKey in classJSONSignature) {
            
            BOOL hasCurrentJSONKey = [[messageDict allKeys] containsObject:checkingJSONKey];
            if(! hasCurrentJSONKey){
                
                isSignatureSimilar = NO;
                break;
            }
        }
        
        // Если сигнатуры схожи - создать объект данных
        if(isSignatureSimilar){
            
            NSError *mappingError = nil;
            id<HUWebSocketMessageDataProtocol> mappingMessageDataResult = [[dataTypeClass alloc] initWithDictionary:messageDict error:&mappingError];
            
            // Проверка на ошибку при создании
            NSAssert((mappingError == nil && mappingMessageDataResult), @"ERROR : Bad Mapping message Data JSON Dictionary");
            self.messageData = mappingMessageDataResult;
            
            return;
        }
    }
    
    // Если сигнатура данных пришла неизвестная (ни одна из моделей не знает такой сигнатуры)
    self.messageData = nil;
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"ERROR : Similar Signature for Message Data Not Recognized !!!" userInfo:nil];
}

@end


#pragma mark - Messages submodels

@implementation HUWebSocketAuthDataRequest

+ (NSArray <NSString*> *)JSONDataBaseSignature{
    
    return @[@"email", @"password"];
}

@end

@implementation HUWebSocketAuthDataSuccessResponse

+ (JSONKeyMapper*)keyMapper{
    
    return [[JSONKeyMapper alloc] initWithDictionary:@{
            @"api_token": @"apiToken",
            @"api_token_expiration_date": @"apiTokenExpirationDateString",}];
}

+ (NSArray <NSString*> *)JSONDataBaseSignature{
    
    return @[@"api_token", @"api_token_expiration_date"];
}

/**
    @abstract Получение объекта-даты
    @discussion
    Данные приходят в стандартном формате RFC-3339, поэтому используется специализировнный под эту задачу форматтер
 
    @return Объект-даты (когда истекает срок сессии)
 */
- (NSDate*)expirationDate{
    
    HURFC3339DateFormatter *dateFormatter = [HURFC3339DateFormatter formatterForExpirationString:self.apiTokenExpirationDateString];
    NSDate *expirationDate = [dateFormatter createExpirationDate];
    return expirationDate;
}

@end

@implementation HUWebSocketAuthDataBadResponse

+ (JSONKeyMapper*)keyMapper{
    
    return [[JSONKeyMapper alloc] initWithDictionary:@{
        @"error_description": @"errorDescription",
        @"error_code": @"errorCode",
        @"error_uuid": @"errorUUID",
        @"in_event": @"incomingEvent",
        @"errors": @"errors"}];
}

+ (NSArray <NSString*> *)JSONDataBaseSignature{
    
    return @[@"error_description", @"error_code", @"error_uuid", @"in_event"];
}

@end


#pragma mark - Error Description

@implementation HUWebSocketErrorEventDescription

+ (JSONKeyMapper*)keyMapper{
    
    return [[JSONKeyMapper alloc] initWithDictionary:@{
            @"type": @"type",
            @"sequence_id": @"sequenceID",
            @"customer_id": @"customerID",
            @"event_id": @"eventID",
            @"email": @"email",
            @"password": @"password",
            @"imei": @"imei"}];
}

@end


