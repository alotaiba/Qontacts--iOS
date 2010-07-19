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
#import "ProgressViewController.h"
#import "ContactNameCell.h"

@implementation ContactsViewController

@synthesize contactsModel;
@synthesize progressViewController;
@synthesize personToRemoveIndexPath;
@synthesize updateSelectedButton;
@synthesize selectButton;
@synthesize thisContact;
@synthesize contacts;
@synthesize selectedContacts;

- (void)dealloc {
	[self.contactsModel release];
	[self.progressViewController release];
	[self.personToRemoveIndexPath release];
	[self.updateSelectedButton release];
	[self.selectButton release];
	[self.selectedContacts release];
	CFRelease(self.contacts);
	CFRelease(self.thisContact);
    [super dealloc];
}

- (void)setSelectButtonState:(int)selectState {
	switch (selectState) {
		case kSelectStateAll:
			[self.selectButton setTitle:NSLocalizedString(@"Select All", @"Select all for toolbar button")];
			[self.selectButton setAction:@selector(selectContacts:)];
			[self.selectButton setTag:kSelectStateAll];
			break;
		case kSelectStateNone:
			[self.selectButton setTitle:NSLocalizedString(@"Select None", @"Select none for toolbar button")];
			[self.selectButton setAction:@selector(selectContacts:)];
			[self.selectButton setTag:kSelectStateNone];
			break;
	}
}

- (void)updateSelectionCount {
	NSArray *selectedRows = [[NSArray alloc] initWithArray:[self indexPathsForSelectedRows]];
	NSString *titleForButton;
	
	if ([selectedRows count] > 0) {
		titleForButton = [[NSString alloc] initWithFormat:NSLocalizedString(@"Update (%d)", @"Update with count number toolbar button"), [selectedRows count]];
		self.updateSelectedButton.enabled = YES;
	} else {
		titleForButton = [[NSString alloc] initWithString:NSLocalizedString(@"Update", @"Update toolbar button")];
		self.updateSelectedButton.enabled = NO;
	}
	
	if ([selectedRows count] == [self.tableView numberOfRowsInSection:0]) {
		[self setSelectButtonState:kSelectStateNone];
	} else {
		[self setSelectButtonState:kSelectStateAll];
	}
	
	updateSelectedButton.title = titleForButton;
	[selectedRows release];
	[titleForButton release];
}

- (void)updateSelectedContactsAddressBook {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableArray *toRemovePeople = [[NSMutableArray alloc] init];
	NSArray *selectedRows = [[NSArray alloc] initWithArray:[self indexPathsForSelectedRows]];
	
	for(NSIndexPath *element in selectedRows)
	{
		CFDictionaryRef thisPersonRecord = CFArrayGetValueAtIndex(self.contacts, (CFIndex)[element row]);
		ABRecordRef thisPerson = CFDictionaryGetValue(thisPersonRecord, CFSTR("Person"));
		[self.contactsModel convertContactNumbers:thisPerson];
		[toRemovePeople addObject:element];
	}
	
	if ([self.contactsModel saveAddressBook]) {
		NSArray *toRemovePeopleSorted = [toRemovePeople sortedArrayUsingSelector:@selector(compare:)];
		
		for (int i = [toRemovePeopleSorted count] -1; i >= 0 ; i--)
		{
			NSIndexPath *indexPath = [toRemovePeopleSorted objectAtIndex:i];
			CFArrayRemoveValueAtIndex(self.contacts, (CFIndex)[indexPath row]);
			[self.selectedContacts removeObject:indexPath];
		}
		
		[self performSelectorOnMainThread:@selector(multiDeleteTableViewRows:) withObject:selectedRows waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(updateSelectionCount) withObject:nil waitUntilDone:YES];
		[self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:YES];
		[self.progressViewController performSelectorOnMainThread:@selector(hideLoadingScreen) withObject:nil waitUntilDone:YES];
	} else {
		[self.progressViewController performSelectorOnMainThread:@selector(hideLoadingScreen) withObject:nil waitUntilDone:YES];
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:NSLocalizedString(@"Error", @"Error")
							  message:NSLocalizedString(@"Error occurred, please try again!", @"Error message when the save contacts failes")
							  delegate:self
							  cancelButtonTitle:@"OK!"
							  otherButtonTitles:nil];
		alert.tag = kAlertViewError;
		[alert show];
		[alert release];
	}
	
	[toRemovePeople release];
	[selectedRows release];
	
	[pool drain];
}

- (void)updateSelected:(NSUInteger)position selectedState:(BOOL)state {
	CFDictionaryRef thisPersonRecord = CFArrayGetValueAtIndex(self.contacts, (CFIndex)position);
	ABRecordRef thisPerson = CFDictionaryGetValue(thisPersonRecord, CFSTR("Person"));
	CFRelease(thisPersonRecord);
	CFBooleanRef selected = (state) ? kCFBooleanTrue : kCFBooleanFalse;
	
	CFMutableDictionaryRef tempPerson = CFDictionaryCreateMutable(NULL, 2, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDictionaryAddValue(tempPerson, CFSTR("Person"), thisPerson);
	CFDictionaryAddValue(tempPerson, CFSTR("Selected"), selected);
	
	CFArraySetValueAtIndex(self.contacts, (CFIndex)position, tempPerson);
}

#pragma mark Actions

- (IBAction)selectContacts:(id)sender {
	NSArray *selectedRows = [[NSArray alloc] initWithArray:[self indexPathsForSelectedRows]];
	
	for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; ++i) {
		CFDictionaryRef thisPersonRecord = CFArrayGetValueAtIndex(self.contacts, (CFIndex)i);
		BOOL selected = CFBooleanGetValue(CFDictionaryGetValue(thisPersonRecord, CFSTR("Selected")));
		switch ([sender tag]) {
			case kSelectStateAll:
				if (!selected) {
					[self updateSelected:i selectedState:YES];
				}
				break;
			case kSelectStateNone:
				if (selected) {
					[self updateSelected:i selectedState:NO];
				}
				break;
		}
	}
	
	[self updateSelectionCount];
	[self updateTable];
	[selectedRows release];
}

- (IBAction)convertSelectedContactsNumbers {
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:NSLocalizedString(@"Are you sure you want to update the selected contacts?", @"Confirmation message title for multi contact update")
								  delegate:self
								  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
								  destructiveButtonTitle:NSLocalizedString(@"Update Selected Contacts", @"Update Selected Contacts button on the action sheet")
								  otherButtonTitles:nil];
	QontactsAppDelegate *appDelegate = (QontactsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[actionSheet showInView:appDelegate.window];
	[actionSheet release];
}

#pragma mark -
#pragma mark View Controller Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = NSLocalizedString(@"Contacts", @"Contacts title for contacts list screen");
		self.selectedContacts = [[NSMutableArray alloc] initWithCapacity:0];
		ProgressViewController *progressView = [[ProgressViewController alloc]
												initWithNibName:@"ProgressView"
												bundle:nil];
		self.progressViewController = progressView;
		[progressView release];
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.prompt = NSLocalizedString(@"The following contact(s) need to be updated:", @"Prompt title on top of the contacts list screen");
	
	UIBarButtonItem *updateSelected = [[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"Update", @"Update toolbar button")
									   style:UIBarButtonItemStyleDone
									   target:self
									   action:@selector(convertSelectedContactsNumbers)];
	updateSelected.enabled = NO;
	self.updateSelectedButton = updateSelected;
	[updateSelected release];
	
	UIBarButtonItem *selectButtonTemp = [[UIBarButtonItem alloc]
										 initWithTitle:@""
										 style:UIBarButtonItemStyleDone
										 target:self
										 action:nil];
	self.selectButton = selectButtonTemp;
	[selectButtonTemp release];
	[self setSelectButtonState:kSelectStateAll];
	
	UIBarButtonItem *space = [[UIBarButtonItem alloc] 
							  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
							  target:nil 
							  action:nil];
	
	NSArray *toolbarButtons = [[NSArray alloc] initWithObjects:self.selectButton, space, self.updateSelectedButton, nil];
	[space release];
	
	[self setToolbarItems:toolbarButtons animated:NO];
	
	[toolbarButtons release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.navigationController setToolbarHidden:NO animated:YES];
	if (self.personToRemoveIndexPath != nil) {
		CFArrayRemoveValueAtIndex(self.contacts, (CFIndex)[self.personToRemoveIndexPath row]);
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:self.personToRemoveIndexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
		self.personToRemoveIndexPath = nil;
		[self updateTable];
	}
	
	[self updateSelectionCount];
	
}

- (void)viewDidUnload {
	self.personToRemoveIndexPath = nil;
	self.updateSelectedButton = nil;
	self.selectButton = nil;
	self.progressViewController = nil;
	self.thisContact = nil;
	self.selectedContacts = nil;
}

#pragma mark -
#pragma mark Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (CFIndex)CFArrayGetCount(self.contacts);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellContactsNamesIdentifier = @"CellContactsNamesIdentifier";
	
	ContactNameCell *cell = (ContactNameCell *)[tableView dequeueReusableCellWithIdentifier:CellContactsNamesIdentifier];
	
    if (cell == nil) {
        cell = (ContactNameCell *)[[[ContactNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellContactsNamesIdentifier] autorelease];
    }
	
	CFDictionaryRef thisPersonRecord = CFArrayGetValueAtIndex(self.contacts, (CFIndex)[indexPath row]);
	ABRecordRef thisPerson = CFDictionaryGetValue(thisPersonRecord, CFSTR("Person"));
	NSDictionary *thisPersonNumbers = [[NSDictionary alloc] initWithDictionary:[self.contactsModel updateableContactNumbers:thisPerson]];
	NSUInteger thisPersonNumbersCount = [[thisPersonNumbers objectForKey:[NSNumber numberWithInt:1]] count];
	[thisPersonNumbers release];
	
	NSUInteger recordID = (NSUInteger)ABRecordGetRecordID(thisPerson);
	
	cell.textLabel.text = [self.contactsModel contactName:thisPerson];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.rootClass = self;
	cell.indexPath = indexPath;
	cell.checked = CFBooleanGetValue(CFDictionaryGetValue(thisPersonRecord, CFSTR("Selected")));
	cell.badgeNumber = thisPersonNumbersCount;
	cell.contactID = recordID;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CFDictionaryRef thisPersonRecord = CFArrayGetValueAtIndex(self.contacts, (CFIndex)[indexPath row]);
	ABRecordRef thisPerson = CFDictionaryGetValue(thisPersonRecord, CFSTR("Person"));
	
	ContactDetailController *contactDetailController = [[ContactDetailController alloc] 
														initWithNibName:@"ContactDetail" 
														bundle:nil];
	contactDetailController.thisContactID = ABRecordGetRecordID(thisPerson);
	contactDetailController.currentPersonIndexPath = indexPath;
	contactDetailController.contactsViewController = self;
	[self.navigationController pushViewController:contactDetailController animated:YES];
	
	[contactDetailController release];
}

- (NSArray *)indexPathsForSelectedRows {
	NSMutableArray *ipSelectedRows = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; ++i) {
		NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
		CFDictionaryRef thisPersonRecord = CFArrayGetValueAtIndex(self.contacts, (CFIndex)i);
		BOOL selected = CFBooleanGetValue(CFDictionaryGetValue(thisPersonRecord, CFSTR("Selected")));
		if (selected) {
			[ipSelectedRows addObject:ip];
		}
	}
	
	return [ipSelectedRows autorelease];
}

- (void)multiDeleteTableViewRows:(NSArray *)indexPaths {
	[self.tableView beginUpdates];
	[self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
	[self.tableView endUpdates];
}

- (void)updateTable {
	if ( (CFArrayGetCount(self.contacts)) == 0 ) {
		self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"updatedContactsBg.png"]];
		self.tableView.separatorColor = [UIColor clearColor];
		self.tableView.backgroundColor = [UIColor clearColor];
		self.navigationItem.rightBarButtonItem = nil;
		self.navigationItem.prompt = nil;
		[self setToolbarItems:nil animated:NO];
	}
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Action Sheet Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [actionSheet cancelButtonIndex]) {
		[self.progressViewController showLoadingScreen:NSLocalizedString(@"Updating contacts...", @"Updating contacts title for multi update loading screen")];
		[self performSelectorInBackground:@selector(updateSelectedContactsAddressBook) withObject:nil];
	}
}

#pragma mark -
#pragma mark Alert View Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (alertView.tag) {
		case kAlertViewError:
			break;
		default:
			break;
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	switch (alertView.tag) {
		case kAlertViewError:
			if (buttonIndex == [alertView cancelButtonIndex]) {
				[self updateTable];
				[self setEditing:NO animated:YES];
			}
			break;
		default:
			break;
	}
}

@end
