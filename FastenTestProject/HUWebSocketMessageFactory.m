//
//  HUWebSocketMessageFactory.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 13.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HUWebSocketMessageFactory.h"

/// Известные подклассы сообщений
NSArray <NSString*>* knownMessagesTypes(){
    
    static NSArray <NSString*> *knownMessagesTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        knownMessagesTypes = @[@"HUWebSocketAuthMessage"];
    });
    
    return knownMessagesTypes;
}

@implementation HUWebSocketMessageFactory

/**
    @abstract Создает объект сообщения из словаря
    @discussion
    <li> Получает известные подклассы сообщений
    <li> Сравнивает их с типом присылаемого сообщения
    <li> Если удается найти соответствующий класс - создает модель из него
    <li> Иначе - создает объект базового класса сообщения HUWebSocketMessage
 
    @param dictionaryMessage Словарь сообщения (генерируемый из JSON-строки, передаваемой по сети)
    @return объект сообщения, требуемый подкласс HUWebSocketMessage
 */
+ (HUWebSocketMessage*)messageWithDictionary:(NSDictionary*)dictionaryMessage{
    
    NSArray <NSString*> *knownClassMessages = knownMessagesTypes();
    
    Class baseMessageClass = [HUWebSocketMessage class];
    Class currentTypeClass = baseMessageClass;
    NSString *recievedType = dictionaryMessage[@"type"];
    
    for (NSString *currentClassName in knownClassMessages) {
        
        Class messageClass = NSClassFromString(currentClassName);
        NSAssert(messageClass, @"ERROR : Undefined Type Class");
        NSAssert([messageClass respondsToSelector:@selector(predefinedTypes)], @"ERROR : predefinedTypes method not implemented !");
        NSArray <NSString*> *predefinedTypesForClass = [messageClass predefinedTypes];
        
        // Определение, подходит ли текущий выбранный подкласс сообщения
        BOOL successSearchType = NO;
        for (NSString *predefinedType in predefinedTypesForClass) {
            if([recievedType isEqualToString:predefinedType]){
                
                currentTypeClass = messageClass;
                successSearchType = YES;
                break;
            }
        }
        if(successSearchType){
            break;
        }
    }
    
    NSError *mappingError = nil;
    HUWebSocketMessage *newMessage = [[currentTypeClass alloc] initWithDictionary:dictionaryMessage error:&mappingError];
    
    // Если не удалось размаппить сообщение
    NSAssert(! mappingError, @"ERROR : Mapping Error when creating message in %s\n%@", __PRETTY_FUNCTION__, [mappingError localizedDescription]);
    
    return newMessage;
}

/**
    @abstract Метод создания сообщения-запроса аутентификация
    @discussion 
    Создание сообщения-запроса аутентификации по заданным пользовательским реквизитам
 
    @note Генерирет UUID для идентификации последовательности
 
    @param userRequisites Пользовательские реквизиты (например : имейл и пароль)
    @return Запрос-сообщение аутентификации
 */
+ (HUWebSocketAuthMessage*)authMessageWithUserRequisites:(HUWebSocketAuthUserRequisites*)userRequisites{
    
    NSString *email = userRequisites.email;
    NSString *password = userRequisites.password;
    
    HUWebSocketAuthMessage *newAuthMessage = [HUWebSocketAuthMessage new];
    newAuthMessage.messageType = AUTH_REQUEST_MESSAGE_TYPE;
    
    NSUUID *newGeneratedSequenceID = [NSUUID UUID];
    newAuthMessage.sequenceID = newGeneratedSequenceID.UUIDString;
    
    HUWebSocketAuthDataRequest *authData = [HUWebSocketAuthDataRequest new];
    authData.email = email;
    authData.password= password;
    
    newAuthMessage.messageData = authData;
    return newAuthMessage;
}

@end
