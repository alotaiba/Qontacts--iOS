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

#import "RootViewController.h"
#import "ContactsViewController.h"
#import "InfoModalViewController.h"
#import "ProgressViewController.h"
#import "NoContactsViewController.h"

@implementation RootViewController

@synthesize contactsViewController;
@synthesize infoModalViewController;
@synthesize progressViewController;
@synthesize noContactsViewController;
@synthesize analyzeContactsButton;
@synthesize mainTextView;

- (void)dealloc {
	[self.contactsViewController release];
	[self.infoModalViewController release];
	[self.progressViewController release];
	[self.noContactsViewController release];
	[self.analyzeContactsButton release];
	[self.mainTextView release];
    [super dealloc];
}

- (void)loadContacts {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	ContactsModel *contactsModel = [[ContactsModel alloc] initWithPeople:YES];
	ContactsViewController *contactsView = [[ContactsViewController alloc]
											initWithNibName:@"ContactsView"
											bundle:nil];
	contactsView.contactsModel = contactsModel;
	contactsView.contacts = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(contactsModel.contacts), contactsModel.contacts);
	self.contactsViewController = contactsView;
	[contactsModel release];
	[contactsView release];
	
	[self.progressViewController performSelectorOnMainThread:@selector(hideLoadingScreen) withObject:nil waitUntilDone:YES];
	
	[self performSelectorOnMainThread:@selector(showNextScreen) withObject:nil waitUntilDone:YES];
	
	[pool drain];
}

- (void)showNextScreen {
	self.analyzeContactsButton.enabled = YES;
	if (CFArrayGetCount(self.contactsViewController.contacts) > 0) {
		[self.navigationController pushViewController:self.contactsViewController animated:YES];
	} else {
		if (self.noContactsViewController == nil) {
			NoContactsViewController *noContactsView = [[NoContactsViewController alloc]
														initWithNibName:@"NoContactsView"
														bundle:nil];
			self.noContactsViewController = noContactsView;
			[noContactsView release];
		}
		[self.navigationController pushViewController:self.noContactsViewController animated:YES];
	}
}

#pragma mark -
#pragma mark IBActions

- (IBAction)showInfoPage {
	if (self.infoModalViewController == nil) {
		InfoModalViewController *infoView = [[InfoModalViewController alloc]
											 initWithNibName:@"InfoModalView"
											 bundle:nil];
		self.infoModalViewController = infoView;
		[infoView release];
	}
	[self.navigationController presentModalViewController:self.infoModalViewController animated:YES];
}

- (IBAction)analyzeContacts {
	if (self.progressViewController == nil) {
		ProgressViewController *progressView = [[ProgressViewController alloc]
												initWithNibName:@"ProgressView"
												bundle:nil];
		self.progressViewController = progressView;
		[progressView release];
	}
	
	if (self.contactsViewController == nil) {
		self.analyzeContactsButton.enabled = NO;
		[self.progressViewController showLoadingScreen:NSLocalizedString(@"Analyzing Contacts...", @"Analyzing contacts title for loading the screen")];
		[self performSelectorInBackground:@selector(loadContacts) withObject:nil];
	} else {
		[self showNextScreen];
	}
}

#pragma mark -
#pragma mark View Controller Methods

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = NSLocalizedString(@"Qontacts", @"Qontacts title");
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"instructionsText" ofType:@"txt"];
	NSError *error;
	NSString *stringFromFileAtPath = [[NSString alloc]
                                      initWithContentsOfFile:path
                                      encoding:NSUTF8StringEncoding
                                      error:&error];
	NSString *stringTest = [stringFromFileAtPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[stringFromFileAtPath release];
	if (stringTest != nil) {
		[self.mainTextView setText:stringTest];
	}
	/*
	NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"info" ofType:@"html"];
	NSData *htmlData = [NSData dataWithContentsOfFile:htmlFile];
	[infoTextWebView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
	*/
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
	
	UIButton *infoModalViewButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoModalViewButton addTarget:self action:@selector(showInfoPage) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *infoModalBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoModalViewButton];
	self.navigationItem.rightBarButtonItem = infoModalBarButtonItem;
	[infoModalBarButtonItem release];
	
	UIBarButtonItem *analyzeContacts = [[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"Analyze Contacts", @"Analyze Contacts title for the button")
									   style:UIBarButtonItemStyleDone
									   target:self
									   action:@selector(analyzeContacts)];
	
	self.analyzeContactsButton = analyzeContacts;
	
	UIBarButtonItem *space = [[UIBarButtonItem alloc] 
							  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
							  target:nil 
							  action:nil];
	
	NSArray *toolbarButtons = [[NSArray alloc] initWithObjects:space, self.analyzeContactsButton, space, nil];
	
	[self setToolbarItems:toolbarButtons animated:NO];
	
	[analyzeContacts release];
	[toolbarButtons release];
}

- (void)viewDidUnload {
	self.contactsViewController = nil;
	self.infoModalViewController = nil;
	self.progressViewController = nil;
	self.noContactsViewController = nil;
	self.analyzeContactsButton = nil;
	self.mainTextView = nil;
}

@end
