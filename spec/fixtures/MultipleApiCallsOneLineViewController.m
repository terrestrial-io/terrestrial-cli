#import "SettingsTableViewController.h"
#import <Terrestrial/Terrestrial.h>

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bar = @[@"Home".translated, @"History".translated, [@"Settings" translatedWithContext: @"Table setting. For lunch."]];

    
    self.foo = @"This is a random string that should not show up";
}
