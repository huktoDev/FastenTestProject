//
//  HULoginStyleButton.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 14.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HULoginStyleButton : UIButton

#pragma mark - Initialization & Config
// Конфигурирование кнопки

- (void)configStyle;

#pragma mark - Button Action
// Установление основного обработчика при касании

- (void)setTarget:(id)actionTarget actionSelector:(SEL)actionSelector;

#pragma mark - Login Indicator
// Индикатор ожидания кнопки

- (void)showLoginIndicator;
- (void)hideLoginIndicator;

@end
