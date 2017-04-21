//
//  ViewController.m
//  PayPal
//
//  Created by 李兴东 on 2017/4/18.
//  Copyright © 2017年 xingshao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong, readwrite) PayPalConfiguration *payPalConfiguration;

@end

@implementation ViewController

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _payPalConfiguration = [[PayPalConfiguration alloc] init];
    _payPalConfiguration.merchantName = @"香港泓庚科技有限公司";//公司名称
    _payPalConfiguration.acceptCreditCards = NO;
    _payPalConfiguration.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
    [nextButton setTitle:@"支付" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    nextButton.backgroundColor = [UIColor redColor];
    [nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
}

- (void)nextButtonClicked:(UIButton *)sender
{
    [self pay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Start out working with the test environment! When you are ready, switch to PayPalEnvironmentProduction.
    [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentSandbox];
}


- (void)pay {
    
    // Create a PayPalPayment
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    
    // Amount, currency, and description
    payment.amount = [[NSDecimalNumber alloc] initWithString:@"0.01"];
    payment.currencyCode = @"USD";
    payment.shortDescription = @"Awesome saws";
    
    payment.items = nil;  // if not including multiple items, then leave payment.items as nil
    payment.paymentDetails = nil; // if not including payment details, then leave payment.paymentDetails as nil
    
    // Use the intent property to indicate that this is a "sale" payment,
    // meaning combined Authorization + Capture.
    // To perform Authorization only, and defer Capture to your server,
    // use PayPalPaymentIntentAuthorize.
    // To place an Order, and defer both Authorization and Capture to
    // your server, use PayPalPaymentIntentOrder.
    // (PayPalPaymentIntentOrder is valid only for PayPal payments, not credit card payments.)
    payment.intent = PayPalPaymentIntentSale;
    
    // If your app collects Shipping Address information from the customer,
    // or already stores that information on your server, you may provide it here.
#warning todo
//    payment.shippingAddress = [PayPalShippingAddress new]; // a previously-created PayPalShippingAddress object
    
    // Several other optional fields that you can set here are documented in PayPalPayment.h,
    // including paymentDetails, items, invoiceNumber, custom, softDescriptor, etc.
    
    // Check whether payment is processable.
    if (!payment.processable) {
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.
    }
    
    // continued below...创建然后展示 PayPalPaymentViewController 页面，使用之前创建好的 PayPalPayment 和 PayPalConfiguration。
    
    // Create a PayPalPaymentViewController.    
    PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment configuration:self.payPalConfiguration delegate:self];
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

#pragma mark - PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController
                 didCompletePayment:(PayPalPayment *)completedPayment {
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];
    
    // Dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

//给你的服务器发送支付成功、支付失败等信息请求。
- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment {
    // Send the entire confirmation dictionary
    NSData *confirmation = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation
                                                           options:0
                                                             error:nil];
    
    // Send confirmation to your server; your server should verify the proof of payment
    // and give the user their goods or services. If the server is not reachable, save
    // the confirmation and try again later.
}

@end
