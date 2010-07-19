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

#import "ContactsModel.h"

@implementation ContactsModel

@synthesize addressBook;
@synthesize people;
@synthesize contacts;

- (void)dealloc {
	CFRelease(addressBook);
	CFRelease(people);
	CFRelease(contacts);
    [super dealloc];
}

- (id)initWithPeople:(BOOL)copyPeople {
	if (self = [super init]) {
		self.addressBook = ABAddressBookCreate();
		self.people = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
		self.contacts = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
		if (copyPeople) {
			CFArrayRef unsortedPeople = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
			for(int i = 0; i < CFArrayGetCount(unsortedPeople); i++)
			{
				ABRecordRef thisPerson = CFArrayGetValueAtIndex(unsortedPeople, i);
				if ([self checkContact:thisPerson]) {
					CFArrayAppendValue(self.people, thisPerson);
				}
			}
			CFRelease(unsortedPeople);
			
			if (CFArrayGetCount(self.people) > 0) {
				CFArraySortValues(self.people,
								  CFRangeMake(0, CFArrayGetCount(self.people)),
								  (CFComparatorFunction) ABPersonComparePeopleByName,
								  (void*) ABPersonGetSortOrdering());
				
				for (int j = 0; j < CFArrayGetCount(self.people); ++j) {
					ABRecordRef thisPerson = CFArrayGetValueAtIndex(self.people, j);
					//CFBooleanRef selected = kCFBooleanTrue;
					CFBooleanRef selected = kCFBooleanFalse;
					
					CFMutableDictionaryRef tempPerson = CFDictionaryCreateMutable(NULL, 2, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
					CFDictionaryAddValue(tempPerson, CFSTR("Person"), thisPerson);
					CFDictionaryAddValue(tempPerson, CFSTR("Selected"), selected);
					
					CFArrayAppendValue(self.contacts, tempPerson);
				}
			}
		}
	}
	return self;
}

- (id)init {
	return [self initWithPeople:NO];
}

- (BOOL)checkContact:(ABRecordRef)thisContact {
	NSDictionary *updateableContactNumbers = [self updateableContactNumbers:thisContact];
	if ([updateableContactNumbers count] > 0) {
		return YES;
	}
	return NO;
}

- (BOOL)convertContactNumbers:(ABRecordRef)thisContact {
	//First object of the returned dictionary will contain the updated numbers
	NSArray *updatedContactNumbers = [[self updateableContactNumbers:thisContact] objectForKey:[NSNumber numberWithInt:1]];
	ABMultiValueRef contactPhoneProperty = ABRecordCopyValue(thisContact, kABPersonPhoneProperty);
	ABMutableMultiValueRef contactPhonePropertyNew = ABMultiValueCreateMutableCopy(contactPhoneProperty);
	CFRelease(contactPhoneProperty);
	
	for (CFIndex i = 0; i < [updatedContactNumbers count]; i++) {
		NSDictionary *updateContactNumberInfo = [[NSDictionary alloc] initWithDictionary:[updatedContactNumbers objectAtIndex:i]];
		NSString *updatedNumber = [updateContactNumberInfo objectForKey:@"Number"];
		NSInteger updatedIndex = [[updateContactNumberInfo objectForKey:@"Index"] intValue];
		[updateContactNumberInfo release];
		
		bool didReplaceValue = ABMultiValueReplaceValueAtIndex(contactPhonePropertyNew, updatedNumber, updatedIndex);
		if (!didReplaceValue) {
			return NO;
		}
	}
	
	CFErrorRef anError = NULL;
	bool didSetValue = ABRecordSetValue(thisContact, kABPersonPhoneProperty, contactPhonePropertyNew, &anError);
	CFRelease(contactPhonePropertyNew);
	if (!didSetValue) {
		return NO;
	}
	
	return YES;
}

- (BOOL)saveAddressBook {
	CFErrorRef anError = NULL;
	bool didSaveAddressBook = ABAddressBookSave(self.addressBook, &anError);
	if (!didSaveAddressBook) {
		return NO;
	}
	return YES;
}

- (UIImage *)contactPicture:(ABRecordRef)thisContact {
	UIImage *retPicture;
	
	if (ABPersonHasImageData(thisContact)) {
		NSData *imageData = (NSData *)ABPersonCopyImageData(thisContact);
		retPicture = [UIImage imageWithData:imageData];
		[imageData release];
	} else {
		retPicture = [UIImage imageNamed:@"unknownContactPicture.png"];
	}

	return retPicture;
}

- (NSString *)contactName:(ABRecordRef)thisContact {
	ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(thisContact, kABPersonPhoneProperty);
	ABMultiValueRef emailProperty = ABRecordCopyValue(thisContact, kABPersonEmailProperty);
	CFStringRef contactName = ABRecordCopyCompositeName(thisContact);
	NSString *retName;
	
	if (contactName != nil) {
		retName = [NSString stringWithString:(NSString *)contactName];
		CFRelease(contactName);
	} else if (ABMultiValueGetCount(emailProperty) > 0) {
		CFStringRef defaultEmail = ABMultiValueCopyValueAtIndex(emailProperty, 0);
		retName = [NSString stringWithString:(NSString *)defaultEmail];
		CFRelease(defaultEmail);
	} else if (ABMultiValueGetCount(phoneNumberProperty) > 0) {
		CFStringRef defaultPhone = ABMultiValueCopyValueAtIndex(phoneNumberProperty, 0);
		retName = [NSString stringWithString:(NSString *)defaultPhone];
		CFRelease(defaultPhone);
	} else {
		retName = [NSString stringWithString:NSLocalizedString(@"No Name", @"No Name")];
	}
	
	CFRelease(phoneNumberProperty);
	CFRelease(emailProperty);
	return retName;
}

- (NSDictionary *)updateableContactNumbers:(ABRecordRef)thisContact {
	NSDictionary *retContactNumbers;
	ABMultiValueRef phoneNumberProperty = ABRecordCopyValue(thisContact, kABPersonPhoneProperty);
	NSMutableArray *tempContactNumbersOriginalArray = [[NSMutableArray alloc] init];
	NSMutableArray *tempContactNumbersUpdatedArray = [[NSMutableArray alloc] init];
	
	if (phoneNumberProperty != NULL) {
		NSUInteger i = 0;
		for (i; i < ABMultiValueGetCount(phoneNumberProperty); i++) {
			CFStringRef numberValue = ABMultiValueCopyValueAtIndex(phoneNumberProperty, i);
			NSString *numberOriginal = [self cleanNumber:(NSString *)numberValue];
			CFRelease(numberValue);
			
			//Get the localized label for that number
			CFStringRef numberLabel = ABMultiValueCopyLabelAtIndex(phoneNumberProperty, i);
			NSString *numberLabelLocalized = (NSString *)ABAddressBookCopyLocalizedLabel(numberLabel);
			CFRelease(numberLabel);
			
			NSString *numberUpdateable = [self _updateableNumber:numberOriginal];
			
			//Get the original numbers and assign them to an array
			NSDictionary *tempContactNumbersOriginalDetails = [[NSDictionary alloc] initWithObjectsAndKeys:numberLabelLocalized, @"Label", numberOriginal, @"Number", [NSNumber numberWithInt:i], @"Index", nil];
			[tempContactNumbersOriginalArray addObject:tempContactNumbersOriginalDetails];
			[tempContactNumbersOriginalDetails release];
			
			if (numberUpdateable) {
				//Get the updated numbers and assign them to an array
				NSDictionary *tempContactNumbersUpdatedDetails = [[NSDictionary alloc] initWithObjectsAndKeys:numberLabelLocalized, @"Label", numberUpdateable, @"Number", [NSNumber numberWithInt:i], @"Index", nil];
				[tempContactNumbersUpdatedArray addObject:tempContactNumbersUpdatedDetails];
				[tempContactNumbersUpdatedDetails release];
			}
			
			[numberLabelLocalized release];
		}
		
		if ([tempContactNumbersUpdatedArray count] > 0) {
			retContactNumbers = [NSDictionary dictionaryWithObjectsAndKeys:tempContactNumbersOriginalArray, [NSNumber numberWithInt:0], tempContactNumbersUpdatedArray, [NSNumber numberWithInt:1], nil];
		} else {
			retContactNumbers = [NSDictionary dictionaryWithObjectsAndKeys:nil];
		}
	}
	
	CFRelease(phoneNumberProperty);
	[tempContactNumbersOriginalArray release];
	[tempContactNumbersUpdatedArray release];
	
	return retContactNumbers;
}

//Remove all unwanted characters from the numbers e.g.'space'()-
- (NSString *)cleanNumber:(NSString *)number {
	NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@" ()-"];
	NSArray *stringArray = [[NSArray alloc] initWithArray:[number componentsSeparatedByCharactersInSet: doNotWant]];
	NSString *cleanString = [stringArray componentsJoinedByString: @""];
	[stringArray release];
	return cleanString;
}

//Private _updateableNumber
- (NSString *)_updateableNumber:(NSString *)number {
	if ((number != nil) && (number.length > 0)) {
		NSString *retNumber = nil;
		NSString *cleanNumber =				[self cleanNumber: number];
		NSMutableString *tempNumberPrefix =	[[NSMutableString alloc] init];
		NSMutableString *tempNumber =		[[NSMutableString alloc] init];
		
		if ([cleanNumber hasPrefix:@"+974"]) {
			[tempNumberPrefix setString:@"+974"];
			[tempNumber setString:[cleanNumber substringFromIndex:4]];
		} else if ([cleanNumber hasPrefix:@"00974"]) {
			[tempNumberPrefix setString:@"00974"];
			[tempNumber setString:[cleanNumber substringFromIndex:5]];
		} else {
			[tempNumberPrefix setString:@""];
			[tempNumber setString:cleanNumber];
		}
		//NSLog(@"prefix = %@, number = %@", tempNumberPrefix, tempNumber);
		if (([tempNumber length] == 7) && (
											([tempNumber hasPrefix:@"3"]) || 
											([tempNumber hasPrefix:@"4"]) || 
											([tempNumber hasPrefix:@"5"]) || 
											([tempNumber hasPrefix:@"6"]) || 
											([tempNumber hasPrefix:@"7"])
										   ))
		{
			retNumber = [NSString stringWithFormat:@"%@%C%@", tempNumberPrefix, [tempNumber characterAtIndex:0], tempNumber];
		}
		
		[tempNumberPrefix release];
		[tempNumber release];
		return retNumber;
	}
	return nil;
}

@end
