//
//  HUWebSocketAuthService.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 13.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HUWebSocketClient.h"
#import "HUWebSocketAuthUserRequisites.h"

/**
    @protocol HUWebSocketAuthServiceDelegate
    @abstract Протокол для обмена данными с сервисом аутентификации
    @discussion
    Передает  соответствующему клиенту сервиса информацию об успешной/неуспешной аутентификации
 
    @method didSuccessAuthorizationWithAPIToken: andWithExpirationDate:
        Когда пользователь успешно залогинивается - выполняется этот метод
    @method didFailAuthorizationWithErrorDescription:
        Когда пользователю не удается залогинится (в частности - происходит ошибка сети) - выполняется этот метод
    @method didPreviousActiveSessionWithAPIToken: andWithExpirationDate:
        Когда удается использовать данные сохраненной сессии (без запроса авторизации на сервер), когда активная сессия еще не истекла
 */
@protocol HUWebSocketAuthServiceDelegate <NSObject>

@optional
- (void)didSuccessAuthorizationWithAPIToken:(NSString*)apiToken andWithExpirationDate:(NSDate*)expirationDate;
- (void)didFailAuthorizationWithErrorDescription:(NSString*)errorDescription;

- (void)didPreviousActiveSessionWithAPIToken:(NSString*)apiToken andWithExpirationDate:(NSDate*)expirationDate;

@end


/**
    @class HUWebSocketAuthService
    @author HuktoDev
    @abstract Класс сервисного слоя, выполняющий задачи аутентификации
    @discussion
    Класс является представителем сервисного слоя в стэке управления данных. 
    Использует внутри себя WebSocketClient, подписывется на его события. По-своему интерпретирует данные сообщений из WebSocketClient, и передает их собственному делегату-клиенту на более высоком слое абстракции. 
 
    <h4> Имеет возможности : </h4>
    <ul>
        <li> Умеет сам себя конфигурировать
        <li> Умеет возвращать текущую активную сессию, если таковая существует
        <li> Умеет обращаться к клиенту, работающему с веб-сокетом для процесса аутентификации
        <li> Способен сохранить/восстановить предыдущую сессию (при прошлом запуске приложения)
        <li> Выполняет проверку, до сих пор ли активна текущая сессия
        <li> Выполняет уведомление делегата в главной очереди
    </ul>
 */
@interface HUWebSocketAuthService : NSObject <HUWebSocketClientSubscriberProtocol>


#pragma mark - Initialization & Config

+ (instancetype)sharedService;
- (void)configAuthService;
@property (weak, nonatomic) HUWebSocketClient *webSocketClient;


#pragma mark - MAIN Authentification Method
// Все, что нужно для процесса аутентификации

@property (weak, nonatomic) id <HUWebSocketAuthServiceDelegate> delegate;
- (void)tryAuthentificationWithRequisites:(HUWebSocketAuthUserRequisites*)userRequisites;


#pragma mark - Active Session Info
// Работа с сессиями

- (HUWebSocketAuthDataSuccessResponse*)getCurrentActiveSessionInfo;
- (BOOL)setPreviousSessionIfActive;

@end





