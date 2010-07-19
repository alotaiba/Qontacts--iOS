/*
 * Qontacts Mobile Application
 * Qontacts is a mobile application that updates the address book contacts
 * to the new Qatari numbering scheme.
 * 
 * Copyright (C) 2010  Abdulrahman Saleh Alotaiba
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation version 3 of the License.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "ProgressViewController.h"
#import "QuartzCore/QuartzCore.h"

@implementation ProgressViewController

@synthesize appDelegate;
@synthesize activityIndicator;
@synthesize loadingLabel;

- (void)dealloc {
	[self.appDelegate release];
	[self.activityIndicator release];
	[self.loadingLabel release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.appDelegate = (QontactsAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.view.center = self.appDelegate.window.center;
		self.view.layer.cornerRadius = 7;
    }
    return self;
}

- (void)viewDidLoad {
	[self.activityIndicator startAnimating];
    [super viewDidLoad];
}

- (void)viewDidUnload {
	[self.activityIndicator stopAnimating];
	self.appDelegate = nil;
	self.activityIndicator = nil;
	self.loadingLabel = nil;
}

- (void)showLoadingScreen:(NSString *)customString {
	self.loadingLabel.text = customString;
	[self.appDelegate.window addSubview:self.view];
}

- (void)hideLoadingScreen {
	NSArray *subViews = [[NSArray alloc] initWithArray:[self.appDelegate.window subviews]];
	if ([subViews containsObject:self.view]) {
		[self.view removeFromSuperview];
	}
	[subViews release];
}

@end
