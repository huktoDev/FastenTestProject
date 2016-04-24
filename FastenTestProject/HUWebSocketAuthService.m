//
//  HUWebSocketAuthService.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 13.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HUWebSocketAuthService.h"

@implementation HUWebSocketAuthService{
    
    HUWebSocketAuthDataSuccessResponse *activeSessionInfo;
    NSUserDefaults *sessionInfoStorage;
}

#pragma mark - Initialization & Config

+ (instancetype)sharedService{
    static HUWebSocketAuthService *authService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        authService = [HUWebSocketAuthService new];
    });
    return authService;
}

/// Метод конфигурирования сервиса
- (void)configAuthService{
    
    self.webSocketClient = [HUWebSocketClient sharedClient];
    sessionInfoStorage = [[NSUserDefaults alloc] initWithSuiteName:@"FastenStorage"];
}

#pragma mark - MAIN Authentification Method

/**
    @abstract Основной метод выполнения аутентификации
    @discussion
    Выполняет аутентификацию. Если сокет не открыт - ожидает открытия, и тогда выполняет  аутентификацию. 
    Передает управление сетевому клиенту (транспортному слою)
 
    @param userRequisites Пользовательские реквизиты для выполнения процесса (идентификации / аутентификации / авторизации)
 */
- (void)tryAuthentificationWithRequisites:(HUWebSocketAuthUserRequisites*)userRequisites{
    
    [self.webSocketClient waitWhenWebSocketOpen:^(SRWebSocket *webSocket) {
        
        HUWebSocketAuthMessage *authMessage = [HUWebSocketMessageFactory authMessageWithUserRequisites:userRequisites];
        [self.webSocketClient sendMessage:authMessage andHandlingResponseMessage:nil withSubscriberOnEvents:self];
    }];
}

#pragma mark - HUWebSocketClientSubscriberProtocol

/**
    @abstract Обработка сообщения аутентификации от сервера
    @discussion
    Определяет, была ли аутентификация успешной, извлекает данные, и передает управление соответствующему обработчику
 
    @param message Сообщение-ответ аутентификации с сервера
 */
- (void)didSuccessWebSocketRecieveMessage:(HUWebSocketAuthMessage *)message{
    
    if([message isAuthSuccess]){
        
        HUWebSocketAuthDataSuccessResponse *successAuthData = (HUWebSocketAuthDataSuccessResponse*)message.messageData;
        [self handleSuccessAuthentificationData:successAuthData];
    }else{
        
        HUWebSocketAuthDataBadResponse *badAuthData = (HUWebSocketAuthDataBadResponse*)message.messageData;
        [self handleFailureAuthntificationData:badAuthData];
    }
}

/// В случае ошибки на веб-сокете
- (void)didFailWebSocketWithError:(NSError*)failError{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didFailAuthorizationWithErrorDescription:)]){
        
        NSString *errorDescription = @"Network Error";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didFailAuthorizationWithErrorDescription:errorDescription];
        });
    }
}

/// В случе закрытия веб-сокета
- (void)didCloseWebSocketWithCode:(NSError *)closeError{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didFailAuthorizationWithErrorDescription:)]){
        
        NSString *errorDescription = @"Connection is broken";
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didFailAuthorizationWithErrorDescription:errorDescription];
        });
    }
}

#pragma mark - Handle Auth Message Data

/**
    @abstract Обработка успешных атентификационных данных
    @discussion
    <li> Запоминание информации текущей активной сессии
    <li> Отправка делегату сервиса данных об успешной аутентификации
 
    @param successAuthData данные успешной аутентификации
 */
- (void)handleSuccessAuthentificationData:(HUWebSocketAuthDataSuccessResponse*)successAuthData{
    
    activeSessionInfo = successAuthData;
    [self storeNewActiveSessionInfo:activeSessionInfo];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didSuccessAuthorizationWithAPIToken:andWithExpirationDate:)]){
        
        BOOL isRightMessageData = [successAuthData isKindOfClass:[HUWebSocketAuthDataSuccessResponse class]];
        NSAssert(isRightMessageData, @"ERROR : Message Data Have UNKNOWN TYPE");
        
        NSString *apiToken = successAuthData.apiToken;
        NSDate *expirationDate = [successAuthData expirationDate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didSuccessAuthorizationWithAPIToken:apiToken andWithExpirationDate:expirationDate];
        });
        NSLog(@"\nSUCCESS AUTHORIZATION !!!\nAPI TOKEN : %@\nEXPIRATION DATE : %@\n", apiToken, expirationDate);
    }
}

/**
    @abstract Обработка данных неудачной аутентификации
    @discussion
    Выполняет только одно действие - отсылку клиенту информации о неудачной аутентификации
 
    @param badAuthData данные неудачной авторизации
 */
- (void)handleFailureAuthntificationData:(HUWebSocketAuthDataBadResponse*)badAuthData{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didFailAuthorizationWithErrorDescription:)]){
        
        BOOL isRightMessageData = [badAuthData isKindOfClass:[HUWebSocketAuthDataBadResponse class]];
        NSAssert(isRightMessageData, @"ERROR : Message Data Have UNKNOWN TYPE");
        
        NSString *errorDescription = badAuthData.errorDescription;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didFailAuthorizationWithErrorDescription:errorDescription];
        });
        NSLog(@"\nFAILURE AUTHORIZATION !!!\nERROR DESCRIPTION : %@\n", errorDescription);
    }
}

#pragma mark - Active Session Info

/// Метод-доступа к объекту текущей сессии
- (HUWebSocketAuthDataSuccessResponse*)getCurrentActiveSessionInfo{
    
    return activeSessionInfo;
}

/**
    @abstract Запоминает данные о сессии
    @discussion
    Сохраняет данные о текущей активной сессии в постоянное хранилище (NSUserDefaults), чтобы при следующем входе их можно было проверить
 
    @param newActiveSessionInfo Объект информации о новой активной сессии
 */
- (void)storeNewActiveSessionInfo:(HUWebSocketAuthDataSuccessResponse*)newActiveSessionInfo{
    
    NSString *APITokenExpirationDateString = newActiveSessionInfo.apiTokenExpirationDateString;
    NSString *APIToken = newActiveSessionInfo.apiToken;
    
    [sessionInfoStorage setObject:APITokenExpirationDateString forKey:@"APITokenExpirationDateString"];
    [sessionInfoStorage setObject:APIToken forKey:@"APIToken"];
}

/**
    @abstract Пытается получить объект сесси из хранилища
    @discussion
    Считается, что объект есть в хранилище, и извлекается -  только, если по 2м ключам есть значения - APITokenExpirationDateString и APIToken
    @return Если информация в наличии - возвращает объект текущей сессии. Иначе - nil
 */
- (HUWebSocketAuthDataSuccessResponse*)tryRestoreActiveSession{
    
    BOOL haveStoredSession = [sessionInfoStorage objectForKey:@"APITokenExpirationDateString"] && [sessionInfoStorage objectForKey:@"APIToken"];
    
    if(haveStoredSession){
        NSString *APITokenExpirationDateString = [sessionInfoStorage objectForKey:@"APITokenExpirationDateString"];
        NSString *APIToken = [sessionInfoStorage objectForKey:@"APIToken"];
        
        HUWebSocketAuthDataSuccessResponse *restoredSessionInfo = [HUWebSocketAuthDataSuccessResponse new];
        restoredSessionInfo.apiToken = APIToken;
        restoredSessionInfo.apiTokenExpirationDateString = APITokenExpirationDateString;
        
        return restoredSessionInfo;
    }else{
        return nil;
    }
}

/**
    @abstract Отвечает на вопрос, активна ли сохраненная сессия
    @discussion
    Пытается восстановить сохраненную сессию, сравнивает текущую дату, и дату истечения сохраненной сессии. 
    @return Если сохраненная сессия активна - YES. Иначе, если нету сохраненной сессии, или она уже неактивна - NO
 */
- (BOOL)isPreviousSessionActive{
    
    HUWebSocketAuthDataSuccessResponse *restoredActiveSession = [self tryRestoreActiveSession];
    if(! restoredActiveSession){
        return NO;
    }
    
    NSDate *expirationDate = [restoredActiveSession expirationDate];
    NSDate *currentDate = [NSDate date];
    
    NSComparisonResult dateComparisonResult = [expirationDate compare:currentDate];
    BOOL isSessionYetActive = (dateComparisonResult == NSOrderedDescending || dateComparisonResult == NSOrderedSame);
    return isSessionYetActive;
}

/**
    @abstract Метод, устанавливающий предыдущую сессию активной
    @discussion
    Выполняет проверку, активна ли сохраненная сессия, и если да - то устанавливает ее текущей, и оповещает об этом делегата
    @return Если сессия была установлена - YES, иначе - NO
 */
- (BOOL)setPreviousSessionIfActive{
    
    if([self isPreviousSessionActive]){
        activeSessionInfo = [self tryRestoreActiveSession];
        
        __block NSDate *expirationDate = [activeSessionInfo expirationDate];
        __block NSString *APIToken = activeSessionInfo.apiToken;
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(didPreviousActiveSessionWithAPIToken:andWithExpirationDate:)]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didPreviousActiveSessionWithAPIToken:APIToken andWithExpirationDate:expirationDate];
            });
        }
        return YES;
    }
    return NO;
}


@end
