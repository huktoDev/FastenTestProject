//
//  HUWebSocketClient.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 13.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "HUWebSocketMessages.h"

typedef void (^HandleResponseBlock)(HUWebSocketMessage*);
typedef void (^WebSocketOpenBlock)(SRWebSocket*);

/**
    @protocol HUWebSocketClientSubscriberProtocol
    @abstract Протокол для обмена данных с транспортным слоем приложения (HUWebSocketClient)
    @discussion
    Позволяет подписываться на события клиента с помощью механизма подписчиков (множественного делегирования)
 
    @method didOpenWebSocket:
        Момент открытия веб-сокета
 
    @method didSuccessWebSocketRecieveMessage:
        При удачном получении сообщения с веб-сокета
 
    @method didFailWebSocketWithError:
        В случае ошибки веб-сокета
 
    @method didCloseWebSocketWithCode:
        В случае закрытия веб-сокета
 */
@protocol HUWebSocketClientSubscriberProtocol <NSObject>

@optional
- (void)didOpenWebSocket:(SRWebSocket*)webSocket;
- (void)didSuccessWebSocketRecieveMessage:(HUWebSocketMessage*)message;

- (void)didFailWebSocketWithError:(NSError*)failError;
- (void)didCloseWebSocketWithCode:(NSError*)closeError;

@end


/**
    @class HUWebSocketClient
    @author HuktoDev
    @abstract Класс-адаптер, инкапсулирующий работу с веб-сокетом
    @discussion
    Класс, хранящий в себе веб-сокет и работающий с ним. 
    
    <h4> Задачи класса : </h4>
    <ol type="a">
        <li> Задачи конфигурации веб-сокета
        <li> Предоставление информации о состоянии веб-сокета
        <li> Предоставляет удобный интерфейс для работы с сетью
        <li> Дает возможность подписываться на события
        <li> Всю возможную тяжелую работу класс выполняет асинхронно
    </ol>
 */
@interface HUWebSocketClient : NSObject <SRWebSocketDelegate>


#pragma mark - Initialization & Config

+ (instancetype)sharedClient;
- (void)configWebSocket;
@property (strong, nonatomic) SRWebSocket *customerWebSocket;


#pragma mark - Waiting Socket Opening
// Для ожидания открытия сокета

@property (assign, nonatomic, readonly) BOOL isClientReady;
- (void)waitWhenWebSocketOpen:(WebSocketOpenBlock)openBlock;
@property (strong, nonatomic) NSMutableArray <NSValue*> *waitActions;


#pragma mark - SEND MESSAGE (MAIN METHOD)
// Отправка сообщений

- (void)sendMessage:(HUWebSocketMessage*)requestMessage andHandlingResponseMessage:(HandleResponseBlock)responseBlock withSubscriberOnEvents:(id<HUWebSocketClientSubscriberProtocol>)eventSubscriber;

@property (strong, nonatomic, readonly) NSMapTable *subscribersDispatchTable;
@property (strong, nonatomic) NSMutableDictionary <NSString*, HandleResponseBlock> *responseHandlers;


@end
