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

#import "InfoModalViewController.h"

@implementation InfoModalViewController

@synthesize versionLabel;
@synthesize okButton;

- (void)viewDidLoad {
	NSString *versionNumber = (NSString *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
	//NSString *buildNumber = (NSString *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *versionString = [[NSString alloc] initWithFormat:@"v.%@", versionNumber];
	self.versionLabel.text = versionString;
	[versionString release];
    
	UIImage *buttonImageNormal = [UIImage imageNamed:@"whiteButton.png"];
	UIImage *buttonImagePressed = [UIImage imageNamed:@"blueButton.png"];
	
	UIImage *stretchableButtonImageNormal = [buttonImageNormal
											 stretchableImageWithLeftCapWidth:12.0
											 topCapHeight:0.0];
	UIImage *strechableButtonImagePressed = [buttonImagePressed
											 stretchableImageWithLeftCapWidth:12.0
											 topCapHeight:0.0];
	
	[self.okButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
	[self.okButton setBackgroundImage:strechableButtonImagePressed forState:UIControlStateHighlighted];
	
	[super viewDidLoad];
}

- (void)viewDidUnload {
	self.versionLabel = nil;
	self.okButton = nil;
}

- (IBAction)dismissInfo:(id)sender {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}


- (void)dealloc {
	[self.versionLabel release];
	[self.okButton release];
    [super dealloc];
}

@end
