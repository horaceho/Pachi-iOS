//
//  PachiViewController.m
//  Pachi-iOS
//
//  Created by Horace Ho on 2013/08/03.
//  Copyright (c) 2013 Horace Ho. All rights reserved.
//

#import "enginePachi.h"
#import "PachiViewController.h"

@interface PachiViewController ()  <UISearchBarDelegate, UITextViewDelegate>

@property (nonatomic, retain) IBOutlet UISearchBar *commandBar;
@property (nonatomic, retain) IBOutlet UITextView  *consoleLog;

@end

@implementation PachiViewController

- (void)setSearchBarName
{
    for (UIView *subview in [self.commandBar subviews]) {
        if ([subview conformsToProtocol:@protocol(UITextInputTraits)] &&
            [subview isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField *)subview;
            textField.enablesReturnKeyAutomatically = NO;
            [textField setReturnKeyType:UIReturnKeySend];
         // [textField setKeyboardAppearance:UIKeyboardAppearanceAlert];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.consoleLog.text = @"";
	[self.consoleLog setFont:[UIFont fontWithName:@"Courier" size:11.0]];
    [self setSearchBarName];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pachMessage:)
                                                 name:@"Pachi"
                                               object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self log:@"engineInit() ..."];
    engineInit();
    [self log:@" OK\n"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self log:@"engineInit() ..."];
    engineDone();
    [self log:@" OK\n"];
}

- (void)log:(NSString *)message
{
    self.consoleLog.text = [NSString stringWithFormat:@"%@%@", self.consoleLog.text, message];
}

#pragma mark -
#pragma mark Pachi notification handler

- (void)pachMessage:(id)sender
{
    NSString *message = [sender object];
    [self log:message];
    [self log:@"\n"];

    if ([self.commandBar isFirstResponder]) {
        ;
    } else {
        self.commandBar.text = @"";
    }
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self.commandBar resignFirstResponder];

    NSUInteger length = self.consoleLog.text.length;
    self.consoleLog.selectedRange = NSMakeRange(length, 0);

    NSString *command = self.commandBar.text;
    [self log:[NSString stringWithFormat:@"%@\n", command]];
    int code = engineCommand([command UTF8String]);
    [self log:[NSString stringWithFormat:@"%@: %d\n", command, code]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self.commandBar resignFirstResponder];
}

@end
