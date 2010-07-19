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

#import "QontactsAppDelegate.h"
#import "ContactDetailController.h"
#import "QuartzCore/QuartzCore.h"

@implementation ContactDetailController

@synthesize contactsViewController;
@synthesize contactsModel;
@synthesize thisContact;
@synthesize thisContactID;
@synthesize contactNumbers;
@synthesize currentPersonIndexPath;

//Synthesize the outlets
@synthesize contactNameLabel;
@synthesize contactImageImageView;
@synthesize contactUpdateButton;

- (void)dealloc {
	[self.contactsViewController release];
	[self.contactsModel release];
	[self.contactNumbers release];
	[self.currentPersonIndexPath release];
	
	//CFRelease(thisContact);
	
	//Release all outlets
	[self.contactNameLabel release];
	[self.contactImageImageView release];
	[self.contactUpdateButton release];
    
	[super dealloc];
}

- (IBAction)updateContact {
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:nil
								  delegate:self
								  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
								  destructiveButtonTitle:NSLocalizedString(@"Update Contact", @"Update Contact for confirmation button on single contact update")
								  otherButtonTitles:nil];
	
	QontactsAppDelegate *appDelegate = (QontactsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[actionSheet showInView:appDelegate.window];
	[actionSheet release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = NSLocalizedString(@"Preview", @"Preview");
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.prompt = NSLocalizedString(@"The following contact needs to be updated:", @"Prompt title on top of the single contact screen");
	
	if (self.contactsModel == nil) {
		ContactsModel *model = [[ContactsModel alloc] init];
		self.contactsModel = model;
		[model release];
	}
	
	//Getting the contact from its ID that was passed from previous contacts view
	self.thisContact = ABAddressBookGetPersonWithRecordID(self.contactsModel.addressBook, self.thisContactID);
	
	//Getting the name
	self.contactNameLabel.text = [self.contactsModel contactName:self.thisContact];
	
	//Getting the image
	UIImage *contactPicture = [self.contactsModel contactPicture:self.thisContact];
	self.contactImageImageView.image = contactPicture;
	self.contactImageImageView.layer.masksToBounds = YES;
	self.contactImageImageView.layer.cornerRadius = 4;
	
	//Getting the original & updated numbers
	self.contactNumbers = [self.contactsModel updateableContactNumbers:self.thisContact];
	
	//Setting up the "Update Contact" button
	UIImage *contactUpdateButtonImage = [UIImage imageNamed:@"redButtonGlossy.png"];
	UIImage *stretchablecontactUpdateButtonImage = [contactUpdateButtonImage
													stretchableImageWithLeftCapWidth:8.0
													topCapHeight:8.0];
	[self.contactUpdateButton setBackgroundImage:stretchablecontactUpdateButtonImage forState:UIControlStateNormal];
}

- (void)viewDidUnload {
	self.contactsModel = nil;
	self.contactNumbers = nil;
	self.currentPersonIndexPath = nil;
	
	self.thisContact = NULL;
	
	self.contactNameLabel = nil;
	self.contactImageImageView = nil;
	self.contactUpdateButton = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.contactNumbers count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[self.contactNumbers objectForKey:[NSNumber numberWithInt:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSInteger count = [[self.contactNumbers objectForKey:[NSNumber numberWithInt:section]] count];
	NSString *sectionTitle;
	switch (section) {
		case 0:
			sectionTitle = [NSString stringWithFormat:NSLocalizedString(@"Current Numbers (%d)", @"Current numbers section title with number count"), count];
			break;
		case 1:
			sectionTitle = [NSString stringWithFormat:NSLocalizedString(@"Updated Numbers (%d)", @"Updated numbers section title with number count"), count];
			break;
	}
	return sectionTitle;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ContactNumbersCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	
	NSNumber *rowAsNum = [[NSNumber alloc] initWithInt:row];
	NSNumber *secAsNum = [[NSNumber alloc] initWithInt:section];
	
	cell.detailTextLabel.text = [[[self.contactNumbers objectForKey:secAsNum] objectAtIndex:row] objectForKey:@"Number"];
	cell.textLabel.text = [[[self.contactNumbers objectForKey:secAsNum] objectAtIndex:row] objectForKey:@"Label"];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	[rowAsNum release];
	[secAsNum release];
	
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (!buttonIndex == [actionSheet cancelButtonIndex]) {
		if (([self.contactsModel convertContactNumbers:self.thisContact]) && ([self.contactsModel saveAddressBook])) {
			self.contactsViewController.personToRemoveIndexPath = self.currentPersonIndexPath;
			[self.navigationController popToViewController:self.contactsViewController animated:YES];
		} else {
			UIAlertView *alert = [[UIAlertView alloc]
								 initWithTitle:NSLocalizedString(@"Error", @"Error")
								 message:NSLocalizedString(@"Error occurred, please try again!", @"Error message when the save contacts failes")
								 delegate:self
								 cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
								 otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

@end
