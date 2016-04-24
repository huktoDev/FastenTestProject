//
//  ViewController.h
//  FastenTestProject
//
//  Created by Alexandr Babenko on 10.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import <UIKit/UIKit.h>


/*
    Построение UI гибридное. Часть UI строится с помощью Auto-Layout. Но Login Button и Description Result строятся полностью программно, чтобы они были более гибкими, и проще было бы сделать анимации.
 
    После отображения результата авторизации - запускается 4х-секундный таймер, который убирает потом надпись
 
    Сделана небольшая задержка получения событий аутентификации, чтобы сделать UI более плавным
    
    В начале добаляется "стартовый экран", который анимироанно смещается. В случае, если имеется сессия - он не убирается: и переход выполняется сразу же, иначе - отображаются другие элементы UI
 */

@class HULoginStyleButton;

@interface HULoginViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UIImageView *fastenLogoImageView;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) HULoginStyleButton *loginButton;

@property (strong, nonatomic) UILabel *descriptionErrorLabel;
@property (strong, nonatomic) UIImageView *descriptionResultIcon;

@end

