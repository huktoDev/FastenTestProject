//
//  ViewController.m
//  FastenTestProject
//
//  Created by Alexandr Babenko on 10.02.16.
//  Copyright © 2016 Alexandr Babenko. All rights reserved.
//

#import "HULoginViewController.h"
#import "HUWebSocketAuthService.h"
#import "BLMultiColorLoader.h"
#import "TLAnimatedSegue.h"
#import "HUActiveSessionInfoProtocol.h"
#import "HUFastenStylization.h"
#import "HULoginStyleButton.h"
#import "UIView+Gradients.h"

#define SIMULATE_FAST_LOGIN_CONFIG 0
#define SKIP_AUTO_RESTORE_SESSION 0

const CGFloat SIDE_SIZE_RESULT_ICON = 25.f;
const CGFloat SIDE_SIZE_TEXTFIELD_ICON = 25.f;
const NSUInteger COUNT_DESCRIPTION_RESULT_LINES = 2;
const CGFloat DEFAULT_UI_FIELDS_HEIGHT = 52.f;
const CGFloat DEFAULT_VERTICAL_SPACING = 12.f;

const CGFloat DEFAULT_LOGIN_ANIMATION_DURATION = 0.6f;
const CGFloat TRANSITION_SUCCESS_LOGIN_DURATION = 1.f;
const CGFloat DISPLAY_RESULT_DESCRIPTION_TIME = 4.f;
const CGFloat DELAY_WAITING_RESULT_AUTH = 1.f;

NSString *const SUCCESS_AUTH_SEGUE = @"successAuthSegue";

@interface HULoginViewController () <HUWebSocketAuthServiceDelegate, UITextFieldDelegate, TLAnimatedSegueDelegate>

@end

@implementation HULoginViewController{
    
    HUWebSocketAuthService *authService;
    
    BOOL isLoginProcessing;
    BOOL isSuccessAuthorization;
    
    UIImageView *temporaryFastenLogoImageView;
    UIView *overlaySplashScreenView;
}

#pragma mark - UIView cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Добавить градиент на фоновую вью
    UIColor *baseColor = [HUFastenStylization loginScreenColor];
    [self.view addGradientWithBaseColor:baseColor andColorDeviation:0.25f];
    
    // Так как выполняется только настройка внешнего вида, то не нужно ждать, пока макет перестроится
    [self configTextFields];
    
    // Добаляется сплэш-скрин ( по окончанию - убирается, и выполняются анимации (если не имеется текущей сессии, иначе - выполнение анимаций отменяется, и выполняется переход к следующему экрану)
    [self addSplashScreenView];
    [self performSelector:@selector(startSplashScreenAnimation) withObject:nil afterDelay:0.5f];
    
    // Установить  делегта сервису авторизации
    authService = [HUWebSocketAuthService sharedService];
    authService.delegate = self;
    
    // Попытаться получить  предыдущую сессию
    [authService setPreviousSessionIfActive];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    // Выполняется каждый раз при перестроении макета, поэтому следует менять местоположения
    if(! isLoginProcessing){
        
        [self configDefaultLoginButton];
        [self configDescriptionResultLabel];
    }else{
        
        [self configWaitingLoginButton];
    }
    
    if(overlaySplashScreenView){
        [self.view bringSubviewToFront:overlaySplashScreenView];
    }
}

#pragma mark - Config UI

- (void)configDescriptionResultLabel{
    
    // Если уже создана подпись - конфигурировать только местоположение
    if(! self.descriptionErrorLabel){
        
        self.descriptionErrorLabel = [UILabel new];
        self.descriptionErrorLabel.alpha = 0.f;
        self.descriptionErrorLabel.font = [UIFont systemFontOfSize:18.f];
        self.descriptionErrorLabel.numberOfLines = COUNT_DESCRIPTION_RESULT_LINES;
        self.descriptionErrorLabel.textAlignment = NSTextAlignmentCenter;
        self.descriptionErrorLabel.text = @"Test Text";
    }
    
    // Вычислить новые размеры и позицию
    CGFloat topOriginLoginY = CGRectGetMaxY(self.passwordTextField.frame) + DEFAULT_VERTICAL_SPACING;
    CGFloat topOriginLoginX = CGRectGetMinX(self.passwordTextField.frame) + 38.f;
    
    CGFloat resultDescriptionWidth = (CGRectGetWidth(self.passwordTextField.frame) / 2.f);
    CGFloat resultDescriptionHeight = DEFAULT_UI_FIELDS_HEIGHT;
    CGPoint centerResultDescription = CGPointMake(topOriginLoginX + (resultDescriptionWidth / 2.f), topOriginLoginY + (resultDescriptionHeight / 2.f));
    CGRect boundsResultDescription = CGRectMake(0.f, 0.f, resultDescriptionWidth, resultDescriptionHeight);
    
    // Установить размеры и позицию
    [self.descriptionErrorLabel setCenter:centerResultDescription];
    [self.descriptionErrorLabel setBounds:boundsResultDescription];
    
    // Если требуется - добавить вьюшк
    if(! [self.descriptionErrorLabel superview]){
        [self.view addSubview:self.descriptionErrorLabel];
    }
    
    // Установить и расположить иконку результата. Создать, если требуется
    if(! self.descriptionResultIcon){
        
        self.descriptionResultIcon = [UIImageView new];
        self.descriptionResultIcon.alpha = 0.f;
    }
    
    self.descriptionResultIcon.center = CGPointMake(CGRectGetMinX(self.passwordTextField.frame) + SIDE_SIZE_RESULT_ICON, topOriginLoginY + (resultDescriptionHeight / 2.f));
    self.descriptionResultIcon.bounds = CGRectMake(0.f, 0.f, SIDE_SIZE_RESULT_ICON, SIDE_SIZE_RESULT_ICON);
    
    if(! [self.descriptionResultIcon superview]){
        [self.view addSubview:self.descriptionResultIcon];
    }
}

- (void)configDefaultLoginButton{
    
    if(! self.loginButton){
        self.loginButton = [HULoginStyleButton new];
        [self.loginButton setTarget:self actionSelector:@selector(loginButtonPressed)];
    }
    
    // Пересчитать размеры, исходя из текста
    [self.loginButton sizeToFit];
    
    // Вычислить местоположение и позицию
    CGFloat topOriginLoginY = CGRectGetMaxY(self.passwordTextField.frame) + DEFAULT_VERTICAL_SPACING;
    CGFloat topOriginLoginX = CGRectGetMaxX(self.passwordTextField.frame) - CGRectGetWidth(self.loginButton.frame);
    
    CGPoint centerLoginButton = CGPointMake(topOriginLoginX + (CGRectGetWidth(self.loginButton.frame) / 2.f), topOriginLoginY + 26.f);
    CGRect boundsLoginButton = CGRectMake(0.f, 0.f, CGRectGetWidth(self.loginButton.frame), DEFAULT_UI_FIELDS_HEIGHT);
    
    // Установить фрейм
    [self.loginButton setCenter:centerLoginButton];
    [self.loginButton setBounds:boundsLoginButton];
    
    // Задать скругление
    self.loginButton.layer.cornerRadius = CGRectGetHeight(self.loginButton.frame) / 2.f;
    
    if(! [self.loginButton superview]){
        [self.view addSubview:self.loginButton];
    }
}

- (void)configWaitingLoginButton{
    
    // Вычислить местоположение (Если успешная авторизация - задает местоположение кнопки чуть ниже)
    CGFloat topOriginLoginY = CGRectGetMaxY(self.passwordTextField.frame) + DEFAULT_VERTICAL_SPACING;
    
    CGPoint centerLoginButton = CGPointMake(self.view.center.x, topOriginLoginY + 26.f);
    if(isSuccessAuthorization){
        centerLoginButton.y += (DEFAULT_VERTICAL_SPACING + DEFAULT_UI_FIELDS_HEIGHT);
    }
    CGRect boundsLoginButton = CGRectMake(0.f, 0.f, DEFAULT_UI_FIELDS_HEIGHT, DEFAULT_UI_FIELDS_HEIGHT);
    
    // Установить фрейм
    [self.loginButton setCenter:centerLoginButton];
    [self.loginButton setBounds:boundsLoginButton];
    
    // Задать скругление
    self.loginButton.layer.cornerRadius = CGRectGetHeight(self.loginButton.frame) / 2.f;
}

- (void)configTextFields{
    
    // Конфигурировать текстовые поля с реквизитами.
    // 1. Поле ввода email-а
    // 2. Поле ввода пароля
    
    UIColor *backTextFieldColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
    UIColor *borderTextFieldColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.25f];
    
    const CGRect baseTextFieldIconBounds = CGRectMake(0.f, 0.f, SIDE_SIZE_TEXTFIELD_ICON, SIDE_SIZE_TEXTFIELD_ICON);
    const CGRect wrapperImageBounds = CGRectMake(0.f, 0.f, 1.5f * SIDE_SIZE_TEXTFIELD_ICON, SIDE_SIZE_TEXTFIELD_ICON);
    
    NSArray <UITextField*> *textFieldsArray = @[self.emailTextField, self.passwordTextField];
    
    for (UITextField *currentTextField in textFieldsArray) {
        
        currentTextField.delegate = self;
        
        // Каждому полю задать иконку, ему соответствующую
        
        UIImageView *textFieldImageView = [[UIImageView alloc] initWithFrame:baseTextFieldIconBounds];
        textFieldImageView.contentMode = UIViewContentModeScaleToFill;
        textFieldImageView.alpha = 0.6f;
        
        UIImage *textFieldImage = nil;
        if([currentTextField isEqual:self.emailTextField]){
            textFieldImage = [UIImage imageNamed:@"user_icon"];
        }else if([currentTextField isEqual:self.passwordTextField]){
            textFieldImage = [UIImage imageNamed:@"pass_icon"];
        }
        textFieldImageView.image = textFieldImage;
        
        
        UIView *offsetWrapperView = [[UIView alloc] initWithFrame:wrapperImageBounds];
        [textFieldImageView setCenter:CGPointMake(SIDE_SIZE_TEXTFIELD_ICON, SIDE_SIZE_TEXTFIELD_ICON / 2.f)];
        [offsetWrapperView addSubview:textFieldImageView];
        
        currentTextField.leftView = offsetWrapperView;
        currentTextField.leftViewMode = UITextFieldViewModeAlways;
        
        // Сделать текстовые поля с Круглыми краями, и установить соответствующие цвета / границы
        
        currentTextField.layer.cornerRadius = CGRectGetHeight(self.emailTextField.frame) / 2.f;
        [currentTextField setBackgroundColor:backTextFieldColor];
        [currentTextField.layer setBorderColor:borderTextFieldColor.CGColor];
        [currentTextField.layer setBorderWidth:1.0];
    }
    
    // Если требуется - установить тестовые реквизиты успешной аутентификации
#if SIMULATE_FAST_LOGIN_CONFIG == 1
    self.emailTextField.text = @"fpi@bk.ru";
    self.passwordTextField.text = @"123123";
#endif
}

#pragma mark - Splash Screen

- (void)addSplashScreenView{
    
    // В начале выполняется блокировка UI ( разблокировка только когда убирается сплэш-скрин )
    [self lockUserInteraction];
    
    // Добавить новое верхнее UIView (оказалось добавить проще, чем UIWindow), и сверху него слегка искаженный логотип
    temporaryFastenLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 200.f)];
    temporaryFastenLogoImageView.contentMode = UIViewContentModeScaleToFill;
    temporaryFastenLogoImageView.image = [UIImage imageNamed:@"fasten_logo"];
    
    overlaySplashScreenView = [[UIView alloc] initWithFrame:self.view.frame];
    overlaySplashScreenView.backgroundColor = [HUFastenStylization loginScreenColor];
    overlaySplashScreenView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    
    [self.view addSubview:overlaySplashScreenView];
    
    temporaryFastenLogoImageView.center  = overlaySplashScreenView.center;
    [overlaySplashScreenView addSubview:temporaryFastenLogoImageView];
}

- (void)startSplashScreenAnimation{
    
    // Смещение сплэш-скрина на его  позицию, показывает элементы UI вторым этапом
    [UIView animateWithDuration:0.6f animations:^{
        
        temporaryFastenLogoImageView.center = CGPointMake(self.view.center.x, self.view.center.y * 0.5f);
        overlaySplashScreenView.transform = CGAffineTransformIdentity;
        
    }completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.6f animations:^{
            overlaySplashScreenView.alpha = 0.f;
        }completion:^(BOOL finished) {
            
            [overlaySplashScreenView removeFromSuperview];
            overlaySplashScreenView = nil;
            [self unlockUserInteraction];
        }];
    }];
}

#pragma mark - Events handling

- (void)loginButtonPressed {
    
    // Обновить переменные состояния и заблокировать пользовательское взаимодействие
    isLoginProcessing = YES;
    [self lockUserInteraction];
    
    // Каждый раз при старте авторизации - скрывать клавиатуру
    [self hideKeyboard];
    
    // Отменяет таймер ( когда скрывает описание результата аутентификации)
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideResultDescriptionWithAnim:) object:@YES];
    [self hideResultDescriptionWithAnim:@YES];
    
    // Создает модель пользовательских реквизитов, и стартует аутентификацию
    NSString *userEmail = self.emailTextField.text;
    NSString *userPassword = self.passwordTextField.text;
    
    HUWebSocketAuthUserRequisites *currentAuthRequisites = [HUWebSocketAuthUserRequisites userRequisitesWithEmail:userEmail withPassword:userPassword];
    [authService tryAuthentificationWithRequisites:currentAuthRequisites];
    
    // Анимированно кнопку сместить в центр, скрыть тайтл, сделать круговую кнопку
    [UIView animateWithDuration:DEFAULT_LOGIN_ANIMATION_DURATION animations:^{
        
        [self.loginButton setBounds:CGRectMake(0.f, 0.f, 52.f, 52.f)];
        self.loginButton.center = CGPointMake(self.view.center.x, self.loginButton.center.y);
        self.loginButton.titleLabel.alpha = 0.f;
        
    } completion:^(BOOL finished) {
        
        // После окончания анимаци - повесить на кнопку индикатор (после небольшой задержки)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.loginButton showLoginIndicator];
        });
    }];
}

#pragma mark - HUWebSocketAuthServiceDelegate

- (void)didSuccessAuthorizationWithAPIToken:(NSString *)apiToken andWithExpirationDate:(NSDate *)expirationDate{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_WAITING_RESULT_AUTH * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // Выполняется при удачной аутентификации, обновляется состояние isSuccessAuthorization, выполняется анимация, смещающая вниз кнопку Login, и в центре Result Description
        
        isSuccessAuthorization = YES;
        [self showResultDescription:@"Authorization Success" withAnimation:YES withSuccessResult:YES];
        
        [UIView animateWithDuration:DEFAULT_LOGIN_ANIMATION_DURATION animations:^{
            
            CGFloat diffCenters = self.descriptionErrorLabel.center.x - self.descriptionResultIcon.center.x;
            
            self.descriptionErrorLabel.center = CGPointMake(self.loginButton.center.x + 18.f, self.loginButton.center.y);
            self.descriptionResultIcon.center = CGPointMake(self.descriptionErrorLabel.center.x - diffCenters, self.loginButton.center.y);
            
            [self configWaitingLoginButton];
        }completion:^(BOOL finished) {
            
            // По окончании анимации - после небольшой задержки выполняется переход к следующему экрану
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self performSegueWithIdentifier:@"successAuthSegue" sender:self];
            });
        }];
    });
}

- (void)didFailAuthorizationWithErrorDescription:(NSString *)errorDescription{
    
    // Реагирование выполнять не сразу, чтобы анимации на интерфейсе были приятными ( задержка - DELAY_WAITING_RESULT_AUTH )
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_WAITING_RESULT_AUTH * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self showResultDescription:errorDescription withAnimation:YES withSuccessResult:NO];
        
        [self.loginButton hideLoginIndicator];
        isLoginProcessing = NO;
        
        self.loginButton.titleLabel.alpha = 0.f;
        [UIView animateWithDuration:DEFAULT_LOGIN_ANIMATION_DURATION animations:^{

            [self configDefaultLoginButton];
            
        }completion:^(BOOL finished) {
            
            // Тайтл показать только после окончания первой анимации (иначе немного косо получается из-за метода sizeToFit
            [UIView animateWithDuration:0.2f animations:^{
                
                self.loginButton.titleLabel.alpha = 1.f;
                [self unlockUserInteraction];
            }];
        }];
    });
}

- (void)didPreviousActiveSessionWithAPIToken:(NSString*)apiToken andWithExpirationDate:(NSDate*)expirationDate{
    
#if SKIP_AUTO_RESTORE_SESSION != 1
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSplashScreenAnimation) object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_WAITING_RESULT_AUTH * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self performSegueWithIdentifier:@"successAuthSegue" sender:self];
    });
#endif
}

#pragma mark - Result Description add

/**
    @abstract Показать описание результата аутентификации
    @discussion
    Метод, отображающий результат аутентификации, конфигурирующий соответствующий лейбл, и связанную с ним соответствующую иконку. 
 
    @param descriptionText      Текст, который будет отображаться
    @param needAnimate          Требуется ли анимировать отображение результата
    @param isSuccessResult      успешна была аутентификация / или нет (подбирается соответствующий цвет и иконка)
 */
- (void)showResultDescription:(NSString*)descriptionText withAnimation:(BOOL)needAnimate withSuccessResult:(BOOL)isSuccessResult{
    
    self.descriptionErrorLabel.text = descriptionText;
    self.descriptionErrorLabel.textColor = isSuccessResult ? [HUFastenStylization successLoginColor] : [HUFastenStylization failureLoginColor];
    self.descriptionResultIcon.image = isSuccessResult ? [UIImage imageNamed:@"success_icon"] : [UIImage imageNamed:@"error_icon"];
    
    CGFloat descriptionShowAnimationDuration = needAnimate ? DEFAULT_LOGIN_ANIMATION_DURATION : 0.f;
    
    [UIView animateWithDuration:descriptionShowAnimationDuration animations:^{
        self.descriptionErrorLabel.alpha = 1.f;
        self.descriptionResultIcon.alpha = 1.f;
    }];
    
    [self performSelector:@selector(hideResultDescriptionWithAnim:) withObject:@YES afterDelay:DISPLAY_RESULT_DESCRIPTION_TIME];
}

/// Скрывает надпись описания результата аутентификации
- (void)hideResultDescriptionWithAnim:(NSNumber*)needAnimate{
    
    BOOL needAnim = [needAnimate boolValue];
    CGFloat descriptionHideAnimationDuration = needAnim ? DEFAULT_LOGIN_ANIMATION_DURATION : 0.f;
    
    [UIView animateWithDuration:descriptionHideAnimationDuration animations:^{
        self.descriptionErrorLabel.alpha = 0.f;
        self.descriptionResultIcon.alpha = 0.f;
    }];
}

#pragma mark - User Interaction

/// Блокирует пользовательское взаимодействие (на момент попытки аутентификации)
- (void)lockUserInteraction{
    
    self.emailTextField.userInteractionEnabled = NO;
    self.passwordTextField.userInteractionEnabled = NO;
    self.loginButton.userInteractionEnabled = NO;
}

/// Выполняет разблокировку пользовательского взаимодействия
- (void)unlockUserInteraction{
    
    self.emailTextField.userInteractionEnabled = YES;
    self.passwordTextField.userInteractionEnabled = YES;
    self.loginButton.userInteractionEnabled = YES;
}

#pragma mark - Keyboard manage & UITextFieldDelegate

/// Метод, убирающий ответчиков у текстовых полей (сокрывающий клавиатуру)
- (void)hideKeyboard{
    
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self hideKeyboard];
    return YES;
}

#pragma mark - Storyboard Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:SUCCESS_AUTH_SEGUE]){
        
        // Контроллер назначения обязан поддерживать протокол HUActiveSessionInfoProtocol
        // С помощью этого протокола выполняется передача модели текущего состояния сессии - другому контроллеру
        id <HUActiveSessionInfoProtocol> activeSessionInfoDestination = (id <HUActiveSessionInfoProtocol> )segue.destinationViewController;
        activeSessionInfoDestination.activeSessionInfo = [authService getCurrentActiveSessionInfo];
    }
    
    // Назначить переходу делегата анимации (хотя по правде  лучше было бы создать подкласс, выполняющий переход от обычной сеги, чем захламлять viewController)
    if ([segue isKindOfClass:[TLAnimatedSegue class]]) {
        ((TLAnimatedSegue *) segue).delegate = self;
    }
}

#pragma mark - TLAnimatedSegueDelegate

- (BOOL)shouldUseAnimations{
    return YES;
}

- (void)animateSegueFormViewController:(UIViewController*)sourceController toViewController:(UIViewController*)destinationController onComplete:(void(^)(void))onComplente{
    
    // Получить базовые вьюшки
    UIView *sourceMainView = sourceController.view;
    UIView *destinationMainView = destinationController.view;
    UIWindow *baseWindow = (UIWindow*)[sourceMainView superview];
    
    // Добавить вьюшку назнчения на текущее окно под текущую
    [baseWindow insertSubview:destinationMainView atIndex:0];
    
    // В течении 1й секунды
    [UIView animateWithDuration:TRANSITION_SUCCESS_LOGIN_DURATION animations:^{
        
        // Установить новую позицию левее
        CGPoint sourceCenterPosition = sourceMainView.center;
        sourceCenterPosition.x -= CGRectGetWidth(sourceMainView.frame);
        sourceMainView.center = sourceCenterPosition;
        
        // Уменьшить в 2 раза длину и высоту, и уменьшать видимость вьюшки
        sourceMainView.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
        sourceMainView.alpha = 0.f;
    } completion:^(BOOL finished) {
        
        //  По окончании анимации - сделать "невидимый" моментальный переход
        [sourceController presentViewController:destinationController animated:NO completion:nil];
    }];
}

@end
