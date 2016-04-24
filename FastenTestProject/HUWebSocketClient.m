//
//  HUWebSocketClient.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 13.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HUWebSocketClient.h"

NSString* const CUSTOMER_URL_STRING = @"ws://52.29.182.220:8080/customer-gateway/customer";

@implementation HUWebSocketClient{
    
    BOOL startWaitingSocketOpening;
    dispatch_semaphore_t waitingSemaphore;
    dispatch_queue_t internalDispatchQueue;
}

@synthesize subscribersDispatchTable;

#pragma mark - Initialization & Config

- (instancetype)init{
    if(self = [super init]){
        self.responseHandlers = [NSMutableDictionary new];
        self.waitActions = [NSMutableArray new];
        
        // MARK: подписчики должны храниться слабыми ссылками ( чтобы не задерживать высвобождение памяти подписчика ) !
        subscribersDispatchTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

+ (instancetype)sharedClient{
    static HUWebSocketClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [HUWebSocketClient new];
    });
    return sharedClient;
}

/**
    @abstract Метод настройки веб-сокета
    @discussion
    <li> Создает сокет для фиксированного хоста
    <li> Устанавливает работу делегата в бэкграунде
    <li> Класс устанавливается делегатом сокета, и открывает сокет
 */
- (void)configWebSocket{
    
    NSURL *customerURL = [NSURL URLWithString:CUSTOMER_URL_STRING];
    NSURLRequest *cutomerInitRequest = [NSURLRequest requestWithURL:customerURL];
    
    self.customerWebSocket = [[SRWebSocket alloc] initWithURLRequest:cutomerInitRequest];
    self.customerWebSocket.delegate = self;
    
    internalDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self.customerWebSocket setDelegateDispatchQueue:internalDispatchQueue];
    
    [self.customerWebSocket open];
}

#pragma mark - Waiting Socket Opening

/// Акцессор, получающий доступ к информации сокета ( открыт ли сокет )
- (BOOL)isClientReady{
    return (self.customerWebSocket.readyState == SR_OPEN);
}

/**
    @abstract Ожидание открытия сокета, и выполняющий определенные действия после
    @discussion
    Можно вызывать множество раз, необработанные события (блоки) запоминает в специальную структуру waitActions
    После открытия сокета - обрабтывает все необработанные ранее события.
 
    @note Для ожидания открытия сокета используется семафор, работающий в отдельной очереди
    @param openBlock блок кода, который требуется выполнить после открытия сокета
 */
- (void)waitWhenWebSocketOpen:(WebSocketOpenBlock)openBlock{

    // Если сокет уже открыт - выполниь действие немедленно !
    NSAssert(openBlock, @"Open Block must be not nil");
    if(self.isClientReady){
        openBlock(self.customerWebSocket);
        return;
    }
    
    // Если метод вызывается первый раз ( список действий пуст и ожидание еще не было начато)
    if(self.waitActions.count == 0 && ! startWaitingSocketOpening){
        startWaitingSocketOpening = YES;
        
        // Ожидание открытия сокета в отдельной очереди диспетчеризации
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            // Если клиент в момент обработки метода (до создания семафора) - открылся, значит обработать действия, и не использовать семафор
            if(self.isClientReady){
                [self handleDelayedActions];
                return;
            }
            waitingSemaphore = dispatch_semaphore_create(0);
            dispatch_semaphore_wait(waitingSemaphore, DISPATCH_TIME_FOREVER);
            
            [self handleDelayedActions];
        });
    }

    [self.waitActions addObject:[openBlock copy]];
}

/// Обрабатывает отложенные действия (которые были отложены до открытия сокета
- (void)handleDelayedActions{
    
    // Защита от двойного вызова
    if(! startWaitingSocketOpening){
        return;
    }
    
    // Сделать так, чтобы в момент обработки действий - изменение waitActions блокировалось
    @synchronized(self.waitActions) {
        
        startWaitingSocketOpening = NO;
        for (WebSocketOpenBlock actionBlock in self.waitActions) {
            actionBlock(self.customerWebSocket);
        }
        [self.waitActions removeAllObjects];
    }
}

#pragma mark - SEND MESSAGE (MAIN METHOD)

/**
    @abstract Основной метод отправки сообщений по веб-сокету
    @discussion
    Выполнение отправки сетевого сообщения по сокету. В случае ответа имеется блок обработки связного сообщения. 
    Кроме того, имеется возможность подписки конкретного подписчика на все связанные с отправляемым сообщения !
 
    @note Выполнение производится асинхронно в internalDispatchQueue
 
    @param requestMessage Сообщение-запрос, отправляемое на действующий хост по WebSocket протоколу
    @param responseBlock Блок обработки сообщения-ответа от сервера (содержит в параметре объект сообщения)
    @param eventSubscriber Подписчик на связанные сообщения
 */
- (void)sendMessage:(HUWebSocketMessage*)requestMessage andHandlingResponseMessage:(HandleResponseBlock)responseBlock withSubscriberOnEvents:(id<HUWebSocketClientSubscriberProtocol>)eventSubscriber{
    
    dispatch_async(internalDispatchQueue, ^{
        
        NSAssert(self.isClientReady, @"CLIENT NOT READY FOR MESSAGING");
        
        // Создание из объекта сообщения JSON-строки
        NSDictionary *sendingMessageDictionary = [requestMessage toDictionary];
        
        NSError *jsonError = nil;
        NSData *sendingData = [NSJSONSerialization dataWithJSONObject:sendingMessageDictionary options:0 error:&jsonError];
        NSString *sendingJSONString = [[NSString alloc] initWithData:sendingData encoding:NSUTF8StringEncoding];
        
        NSLog(@"\n\n-----------------------------\nSEND MESSAGE \n%@\n+++++++++++++++++++++++\nDATA : \n%@\n-----------------------------\n\n", requestMessage, sendingJSONString);
        
        // Если есть обработчик - запомнить его, чтобы при получении ответа выполнить
        if(responseBlock){
            [self.responseHandlers setObject:[responseBlock copy] forKey:requestMessage.sequenceID];
        }
        // Если есть подписчик - запомнить его в таблицу диспетчеризации подписчиков
        if(eventSubscriber){
            [self.subscribersDispatchTable setObject:eventSubscriber forKey:requestMessage.sequenceID];
        }
        
        // Отослать строку по веб-сокету
        [self.customerWebSocket send:sendingJSONString];
    });
}

#pragma mark - SRWebSocketDelegate

/**
    @abstract Обработка полученного сообщения по веб-сокету
    @discussion
    <li> Превращает JSON-строку ответа в объект-сообщения HUWebSocketMessage.
    <li> Ищет связанные обработчики с данной messageSequenceID, выполняет их
    <li> Ищет подписчиков на заданную последовательность сообщений messageSequenceID, и выполняет рассылку
 
    @warning После получения ответа - убирает соответствующего подписчика (считается, что с одним запросом связан только ОДИН ответ)
 
    @param webSocket Объект веб-сокета
    @param message Полученное сообщение (считается, что оно NSString*), хотя по идее можно возвращать и объекты NSData
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    
    NSAssert([message isKindOfClass:[NSString class]], @"ERROR : Unkonwn Web Socket Message class : %@", NSStringFromClass([message class]));
    
    NSData *responseMessageData = [((NSString*)message) dataUsingEncoding:NSUTF8StringEncoding];
    NSError *deserializationError = nil;
    NSDictionary *responseMessageDictionary = [NSJSONSerialization JSONObjectWithData:responseMessageData options:0 error:&deserializationError];
    HUWebSocketMessage *resultMessage = [HUWebSocketMessageFactory messageWithDictionary:responseMessageDictionary];
    
    NSString *messageSequenceID = resultMessage.sequenceID;
    if ([[self.responseHandlers allKeys] containsObject:messageSequenceID]) {
        
        HandleResponseBlock responseBlock = self.responseHandlers[messageSequenceID];
        responseBlock(resultMessage);
        [self.responseHandlers removeObjectForKey:messageSequenceID];
    }
    
    if([self.subscribersDispatchTable objectForKey:messageSequenceID]){
        
        id <HUWebSocketClientSubscriberProtocol> currentSubscriber = [self.subscribersDispatchTable objectForKey:messageSequenceID];
        if(currentSubscriber && [currentSubscriber respondsToSelector:@selector(didSuccessWebSocketRecieveMessage:)]){
            if(currentSubscriber){
                [currentSubscriber didSuccessWebSocketRecieveMessage:resultMessage];
            }
        }
        [self.subscribersDispatchTable removeObjectForKey:messageSequenceID];
    }
    
    NSLog(@"\n\n=============================\nMESSAGE RESPONSE !!!\n%@\n\n", resultMessage);
}

/// Обрабатывается, когда веб-сокет открывается : 1) Отправляет семафору сигнал 2) Рассылает сообщение всем подписчикам класса
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    
    if(waitingSemaphore){
        dispatch_semaphore_signal(waitingSemaphore);
    }
    
    [self performSubscribersSelector:@selector(didOpenWebSocket:) withObject:webSocket];
    NSLog(@"\n+++++++++++++++++++++++++++++++\nSOCKET OPENED\n+++++++++++++++++++++++++++++++\n");
}

/// Если на веб-сокете происходит ошибка - рассылает всем подписчикам сообщение, и удаляет подписчиков
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    
    [self performSubscribersSelector:@selector(didFailWebSocketWithError:) withObject:error];
    [self.subscribersDispatchTable removeAllObjects];
    
    NSLog(@"\nSOCKET FAIL WITH ERROR :\n%@\n", [error localizedDescription]);
}

/// Если на веб-сокете закрывается - рассылает всем подписчикам сообщение, и удаляет подписчиков
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    
    NSError *closeError = [NSError errorWithDomain:reason code:code userInfo:@{@"wasClean" : @(wasClean)}];
    [self performSubscribersSelector:@selector(didCloseWebSocketWithCode:) withObject:closeError];
    [self.subscribersDispatchTable removeAllObjects];
    
    NSLog(@"\nSOCKET CLOSE WITH CODE %ld\nWITH REASON :\n%@\n", (long)code, reason);
}

#pragma mark - Notification ALL Subscribers

/**
    @abstract Метод для удобной рассылки всем подписчикам класса
    @discussion
    Позволяет отправлять определенное сообщение каждому подписчику, со ссылкой на объект-параметр (если надо)
    Выполняет энумерацию подписчиков NSMapTable.
    <li> Проверяет, реализует ли подписчик метод по заданному селектору
    <li> Убирает предупреждение  компилятора о неизвестном селекторе
 
    @param methodSelector Селектор метода-сообщения рассылки подписчиков
    @param firstParam параметр, передаваемый в сообщении каждому подписчику
 */
- (void)performSubscribersSelector:(SEL)methodSelector withObject:(id)firstParam{
    
    NSEnumerator *subscribersEnumerator = [self.subscribersDispatchTable objectEnumerator];
    id <HUWebSocketClientSubscriberProtocol> currentSubscriber = nil;
    while (currentSubscriber = [subscribersEnumerator nextObject]) {
        if (currentSubscriber && [currentSubscriber respondsToSelector:methodSelector]) {
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            
            [currentSubscriber performSelector:methodSelector withObject:firstParam];
#pragma clang diagnostic pop
        }
    }
}

@end

